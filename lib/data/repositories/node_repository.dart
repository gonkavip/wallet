import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/node_model.dart';

class NodeRepository {
  static const String _boxName = 'nodes';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveNodes(List<NodeModel> nodes) async {
    final activeUrl = _box.get('_activeUrl');
    await _box.clear();
    if (activeUrl != null) {
      await _box.put('_activeUrl', activeUrl);
    }
    for (var i = 0; i < nodes.length; i++) {
      await _box.put('node_$i', jsonEncode(nodes[i].toJson()));
    }
  }

  Future<void> saveActiveUrl(String url) async {
    await _box.put('_activeUrl', url);
  }

  String? loadActiveUrl() {
    return _box.get('_activeUrl');
  }

  List<NodeModel> loadNodes() {
    final nodes = <NodeModel>[];
    for (final key in _box.keys) {
      if (key.toString().startsWith('_')) continue;
      try {
        nodes.add(NodeModel.fromJson(jsonDecode(_box.get(key)!)));
      } catch (_) {}
    }
    return nodes;
  }
}
