import 'package:flutter/foundation.dart';
import '../../config/constants.dart';
import '../../data/models/node_model.dart';
import 'api_endpoints.dart';
import 'node_client.dart';

const List<String> _initialNodeHosts = [
  'node1.gonka.ai',
  'node2.gonka.ai',
  'node3.gonka.ai',
  '47.236.26.199',
  '47.236.19.22',
  'gonka.spv.re',
];

class NodeManager extends ChangeNotifier {
  List<NodeModel> _nodes = [];
  int _activeIndex = 0;
  int _consecutiveErrors = 0;
  NodeClient? _activeClient;
  bool _isSequentialCheckRunning = false;

  List<NodeModel> get nodes => List.unmodifiable(_nodes);
  NodeModel? get activeNode => _nodes.isEmpty ? null : _nodes[_activeIndex];
  NodeClient? get client => _activeClient;

  void init(List<NodeModel> savedNodes) {
    if (savedNodes.isNotEmpty) {
      _nodes = savedNodes;
    } else {
      _nodes = _initialNodeHosts
          .map((host) => NodeModel(
                url: 'http://$host:${ApiEndpoints.defaultNodePort}',
                label: host,
                proxyMode: true,
              ))
          .toList();
    }
    _connectToActive();
  }

  void _connectToActive() {
    _activeClient?.dispose();
    if (_nodes.isEmpty) return;
    final node = _nodes[_activeIndex];
    _activeClient = NodeClient(
      nodeUrl: node.url,
      proxyMode: node.proxyMode,
    );
    _consecutiveErrors = 0;
  }

  void addNode(NodeModel node) {
    if (_nodes.any((n) => n.url == node.url)) return;
    _nodes.add(node);
    notifyListeners();
  }

  void removeNode(int index) {
    if (_nodes.length <= 1) return;
    _nodes.removeAt(index);
    if (index < _activeIndex) {
      _activeIndex--;
    }
    if (_activeIndex >= _nodes.length) {
      _activeIndex = 0;
    }
    _connectToActive();
    notifyListeners();
  }

  void setActive(int index) {
    if (index < 0 || index >= _nodes.length) return;
    _activeIndex = index;
    _connectToActive();
    notifyListeners();
  }

  void reportError() {
    _consecutiveErrors++;
    if (_consecutiveErrors >= GonkaConstants.maxConsecutiveErrors) {
      _switchToNext();
    }
  }

  void reportSuccess() {
    _consecutiveErrors = 0;
  }

  void _switchToNext() {
    if (_nodes.length <= 1) return;
    final healthyIndex = _nodes.indexWhere(
        (n) => n.isHealthy && _nodes.indexOf(n) != _activeIndex);
    if (healthyIndex >= 0) {
      _activeIndex = healthyIndex;
    } else {
      _activeIndex = (_activeIndex + 1) % _nodes.length;
    }
    _connectToActive();
    notifyListeners();
  }

  Future<bool> checkActiveNode() async {
    final node = activeNode;
    if (node == null) return false;

    final idx = _activeIndex;
    _nodes[idx] = _nodes[idx].copyWith(isChecking: true);
    _onNodeUpdated?.call();

    await _checkSingleNode(node.url, node.proxyMode);

    return _nodes[_activeIndex].url == node.url &&
        _nodes[_activeIndex].isHealthy;
  }

  Future<void> performFullScan() async {
    if (_isSequentialCheckRunning) return;
    _isSequentialCheckRunning = true;
    try {
      _nodes.clear();
      _activeIndex = 0;
      _onNodeUpdated?.call();

      final allHosts = <String>{..._initialNodeHosts};

      for (final host in _initialNodeHosts) {
        try {
          final client = NodeClient(
            nodeUrl: 'http://$host:${ApiEndpoints.defaultNodePort}',
            proxyMode: true,
          );
          final hosts = await client.fetchParticipantHosts();
          client.dispose();
          if (hosts.isNotEmpty) {
            allHosts.addAll(hosts);
            break;
          }
        } catch (_) {
          continue;
        }
      }

      for (final host in allHosts) {
        final url = 'http://$host:${ApiEndpoints.defaultNodePort}';
        if (!_nodes.any((n) => n.url == url)) {
          _nodes.add(NodeModel(
            url: url,
            label: host,
            proxyMode: true,
            isChecking: true,
          ));
        }
      }
      _onNodeUpdated?.call();

      final toCheck = _nodes
          .map((n) => _NodeCheckTask(n.url, n.proxyMode))
          .toList();

      for (var i = 0; i < toCheck.length; i += 10) {
        final batch = toCheck.sublist(
            i, i + 10 > toCheck.length ? toCheck.length : i + 10);
        await Future.wait(
            batch.map((task) => _checkSingleNode(task.url, task.proxy)));
      }

      _sortAndFixActive(null);
      if (_nodes.isNotEmpty) _connectToActive();
      _onNodeUpdated?.call();
    } finally {
      _isSequentialCheckRunning = false;
    }
  }

  Future<void> _checkSingleNode(String url, bool proxyMode) async {
    final idx = _nodes.indexWhere((n) => n.url == url);
    if (idx < 0) return;

    try {
      final client = NodeClient(nodeUrl: url, proxyMode: proxyMode);
      final status = await client.getNodeStatus();
      client.dispose();
      final newIdx = _nodes.indexWhere((n) => n.url == url);
      if (newIdx < 0) return;
      _nodes[newIdx] = _nodes[newIdx].copyWith(
        latencyMs: status.latencyMs,
        isOnline: true,
        isSyncing: status.catchingUp,
        chainId: status.chainId,
        isHealthy: status.isHealthy,
        isChecking: false,
      );
    } catch (_) {
      final newIdx = _nodes.indexWhere((n) => n.url == url);
      if (newIdx < 0) return;
      _nodes[newIdx] = _nodes[newIdx].copyWith(
        isOnline: false,
        isHealthy: false,
        isChecking: false,
      );
    }

    final activeUrl = activeNode?.url;
    _sortAndFixActive(activeUrl);
    _onNodeUpdated?.call();
  }

  void _sortAndFixActive(String? activeUrl) {
    _nodes.sort((a, b) {
      if (a.isChecking != b.isChecking) return a.isChecking ? -1 : 1;
      if (a.isHealthy != b.isHealthy) return a.isHealthy ? -1 : 1;
      if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
      return a.latencyMs.compareTo(b.latencyMs);
    });

    if (activeUrl != null) {
      final newIndex = _nodes.indexWhere((n) => n.url == activeUrl);
      _activeIndex = newIndex >= 0 ? newIndex : 0;
    }

    if (_nodes.isNotEmpty &&
        !_nodes[_activeIndex].isHealthy &&
        !_nodes[_activeIndex].isChecking) {
      final healthyIndex = _nodes.indexWhere((n) => n.isHealthy);
      if (healthyIndex >= 0) {
        _activeIndex = healthyIndex;
        _connectToActive();
      }
    }
  }

  void Function()? _onNodeUpdated;
  set onNodeUpdated(void Function()? cb) => _onNodeUpdated = cb;

  @override
  void dispose() {
    _activeClient?.dispose();
    super.dispose();
  }
}

class _NodeCheckTask {
  final String url;
  final bool proxy;
  _NodeCheckTask(this.url, this.proxy);
}
