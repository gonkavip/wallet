import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/node_manager.dart';
import '../../data/models/tx_history_model.dart';
import 'node_provider.dart';

final txHistoryProvider = StateNotifierProvider.family<TxHistoryNotifier,
    AsyncValue<List<TxHistoryItem>>, String>((ref, address) {
  final nodeManager = ref.watch(nodeManagerProvider);
  return TxHistoryNotifier(nodeManager, address);
});

class TxHistoryNotifier
    extends StateNotifier<AsyncValue<List<TxHistoryItem>>> {
  final NodeManager _nodeManager;
  final String _address;

  TxHistoryNotifier(this._nodeManager, this._address)
      : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    final client = _nodeManager.client;
    if (client == null) {
      if (mounted) state = const AsyncValue.data([]);
      return;
    }

    try {
      if (mounted) state = const AsyncValue.loading();

      final results = await Future.wait([
        client.getTxHistory(_address),
        client.getVestingRewards(_address),
        client.getCollateralTxHistory(_address),
        client.getGrantTxHistory(_address),
        client.getUnjailTxHistory(_address),
        client.getVoteTxHistory(_address),
      ]);

      final rawTransfers = results[0] as List;
      final rawVesting = results[1] as List;
      final rawCollateral = results[2] as List;
      final rawGrants = results[3] as List;
      final rawUnjails = results[4] as List;
      final rawVotes = results[5] as List;

      final items = <TxHistoryItem>[];

      for (final raw in rawTransfers) {
        final item = TxHistoryItem.fromTxResponse(raw.tx, raw.txResponse);
        items.add(TxHistoryItem(
          txhash: item.txhash,
          fromAddress: item.fromAddress,
          toAddress: item.toAddress,
          amountNgonka: item.amountNgonka,
          denom: item.denom,
          timestamp: item.timestamp,
          height: item.height,
          success: item.success,
          memo: item.memo,
          type: item.toAddress == _address ? TxType.receive : TxType.send,
        ));
      }

      for (final raw in rawVesting) {
        items.add(TxHistoryItem.fromVestingReward(
            raw.tx, raw.txResponse, _address));
      }

      for (final raw in rawCollateral) {
        items.add(TxHistoryItem.fromCollateralTx(raw.tx, raw.txResponse));
      }

      for (final raw in rawGrants) {
        items.add(TxHistoryItem.fromGrantTx(raw.tx, raw.txResponse));
      }

      for (final raw in rawUnjails) {
        items.add(TxHistoryItem.fromUnjailTx(raw.tx, raw.txResponse));
      }

      for (final raw in rawVotes) {
        items.add(TxHistoryItem.fromVoteTx(raw.tx, raw.txResponse));
      }

      final seen = <String>{};
      final unique = <TxHistoryItem>[];
      for (final item in items) {
        if (seen.add(item.txhash)) {
          unique.add(item);
        }
      }
      unique.sort((a, b) => b.height.compareTo(a.height));

      if (mounted) state = AsyncValue.data(unique);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}
