import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/node_manager.dart';
import '../../data/models/node_model.dart';
import '../../data/repositories/node_repository.dart';

final nodeRepositoryProvider = Provider<NodeRepository>((ref) {
  return NodeRepository();
});

final nodeManagerProvider = Provider<NodeManager>((ref) {
  return NodeManager();
});

class NodeState {
  final List<NodeModel> nodes;
  final NodeModel? activeNode;
  final bool isScanning;

  const NodeState({
    this.nodes = const [],
    this.activeNode,
    this.isScanning = false,
  });
}

final nodesProvider =
    StateNotifierProvider<NodesNotifier, NodeState>((ref) {
  return NodesNotifier(
    ref.watch(nodeManagerProvider),
    ref.watch(nodeRepositoryProvider),
  );
});

class NodesNotifier extends StateNotifier<NodeState> {
  final NodeManager _manager;
  final NodeRepository _repo;

  NodesNotifier(this._manager, this._repo) : super(const NodeState());

  void load() {
    final saved = _repo.loadNodes();
    final isFirstLaunch = saved.isEmpty;
    _manager.init(saved);
    final activeUrl = _repo.loadActiveUrl();
    if (activeUrl != null) {
      final idx = _manager.nodes.indexWhere((n) => n.url == activeUrl);
      if (idx >= 0) {
        _manager.setActive(idx);
      }
    }
    _syncState();

    _manager.onNodeUpdated = () {
      _syncState();
      if (!_manager.nodes.any((n) => n.isChecking)) {
        _scanning = false;
        _save();
        if (_manager.activeNode != null) {
          _repo.saveActiveUrl(_manager.activeNode!.url);
        }
      }
    };

    if (isFirstLaunch) {
      _setScanning(true);
      _manager.performFullScan();
    } else {
      _checkActiveOrFallback();
    }
  }

  Future<void> _checkActiveOrFallback() async {
    final healthy = await _manager.checkActiveNode();
    if (!healthy) {
      _setScanning(true);
      _manager.performFullScan();
    }
  }

  void triggerHealthCheck() {
    _setScanning(true);
    _manager.performFullScan();
  }

  void addNode(NodeModel node) {
    _manager.addNode(node);
    _syncState();
    _save();
  }

  void removeNode(int index) {
    _manager.removeNode(index);
    _syncState();
    _save();
  }

  void setActive(int index) {
    _manager.setActive(index);
    _syncState();
    if (_manager.activeNode != null) {
      _repo.saveActiveUrl(_manager.activeNode!.url);
    }
  }

  bool _scanning = false;

  void _setScanning(bool v) {
    _scanning = v;
    _syncState();
  }

  void _syncState() {
    if (!mounted) return;
    state = NodeState(
      nodes: _manager.nodes,
      activeNode: _manager.activeNode,
      isScanning: _scanning,
    );
  }

  void _save() {
    _repo.saveNodes(state.nodes);
  }
}
