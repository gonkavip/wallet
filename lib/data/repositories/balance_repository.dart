import '../models/balance_model.dart';
import '../../core/network/node_manager.dart';

class BalanceRepository {
  final NodeManager _nodeManager;
  final Map<String, BalanceModel> _cache = {};

  BalanceRepository(this._nodeManager);

  Future<BalanceModel> getBalance(String address) async {
    final client = _nodeManager.client;
    if (client == null) {
      return _cache[address] ?? BalanceModel.zero();
    }

    try {
      final spendable = await client.getSpendableBalance(address);
      final vesting = await client.getVesting(address);
      final balance = BalanceModel(spendable: spendable, vesting: vesting);
      _cache[address] = balance;
      _nodeManager.reportSuccess();
      return balance;
    } catch (e) {
      _nodeManager.reportError();
      return _cache[address] ?? BalanceModel.zero();
    }
  }

  BalanceModel? getCached(String address) => _cache[address];

  void clearCache() => _cache.clear();
}
