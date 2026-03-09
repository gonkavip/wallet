import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  static const String _boxName = 'wallets';
  static const String _activeKey = 'active_wallet_id';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> createWallet(WalletModel wallet) async {
    await _box.put(wallet.id, jsonEncode(wallet.toJson()));
    if (_box.length == 2) {
      await setActiveWallet(wallet.id);
    }
  }

  List<WalletModel> getWallets() {
    return _box.keys
        .where((key) => key != _activeKey)
        .map((key) {
          final json = _box.get(key);
          if (json == null) return null;
          return WalletModel.fromJson(jsonDecode(json));
        })
        .whereType<WalletModel>()
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  WalletModel? getWallet(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return WalletModel.fromJson(jsonDecode(json));
  }

  String? getActiveWalletId() => _box.get(_activeKey);

  WalletModel? getActiveWallet() {
    final id = getActiveWalletId();
    if (id == null) return null;
    return getWallet(id);
  }

  Future<void> setActiveWallet(String id) async {
    await _box.put(_activeKey, id);
  }

  Future<void> deleteWallet(String id) async {
    await _box.delete(id);
    if (getActiveWalletId() == id) {
      final wallets = getWallets();
      if (wallets.isNotEmpty) {
        await setActiveWallet(wallets.first.id);
      } else {
        await _box.delete(_activeKey);
      }
    }
  }

  Future<void> renameWallet(String id, String newName) async {
    final wallet = getWallet(id);
    if (wallet == null) return;
    final updated = wallet.copyWith(name: newName);
    await _box.put(id, jsonEncode(updated.toJson()));
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  bool get hasWallets => getWallets().isNotEmpty;
}
