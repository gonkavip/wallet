import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/wc_session.dart';

class WcSessionRepository {
  static const String _boxName = 'wc_sessions';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> save(WcSession session) async {
    await _box.put(session.topic, jsonEncode(session.toJson()));
  }

  WcSession? get(String topic) {
    final raw = _box.get(topic);
    if (raw == null) return null;
    try {
      return WcSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  List<WcSession> all() {
    final result = <WcSession>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        result.add(WcSession.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.approvedAt.compareTo(a.approvedAt));
    return result;
  }

  List<WcSession> byWalletId(String walletId) =>
      all().where((s) => s.walletId == walletId).toList();

  Future<void> delete(String topic) => _box.delete(topic);

  Future<void> clearAll() => _box.clear();
}
