import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/transaction/broadcast_service.dart';
import 'node_provider.dart';
import 'wallet_provider.dart';

final broadcastServiceProvider = Provider<BroadcastService>((ref) {
  return BroadcastService(ref.watch(nodeManagerProvider));
});

enum SendState { idle, signing, broadcasting, success, error }

class SendResult {
  final SendState state;
  final String? txhash;
  final String? error;
  SendResult({required this.state, this.txhash, this.error});
}

final sendProvider =
    StateNotifierProvider<SendNotifier, SendResult>((ref) {
  return SendNotifier(
    ref.watch(broadcastServiceProvider),
    ref.watch(walletsProvider.notifier),
  );
});

class SendNotifier extends StateNotifier<SendResult> {
  final BroadcastService _broadcast;
  final WalletsNotifier _wallets;

  SendNotifier(this._broadcast, this._wallets)
      : super(SendResult(state: SendState.idle));

  Future<void> send({
    required String walletId,
    required String fromAddress,
    required String toAddress,
    required String amountNgonka,
    String memo = '',
  }) async {
    state = SendResult(state: SendState.signing);

    try {
      final pkHex = await _wallets.getPrivateKeyHex(walletId);
      if (pkHex == null) {
        state = SendResult(state: SendState.error, error: 'Private key not found');
        return;
      }

      state = SendResult(state: SendState.broadcasting);

      final result = await _broadcast.send(
        privateKeyHex: pkHex,
        fromAddress: fromAddress,
        toAddress: toAddress,
        amount: amountNgonka,
        memo: memo,
      );

      if (result.isSuccess) {
        state = SendResult(state: SendState.success, txhash: result.txhash);
      } else {
        state = SendResult(state: SendState.error, error: result.rawLog);
      }
    } catch (e) {
      state = SendResult(state: SendState.error, error: e.toString());
    }
  }

  void reset() {
    state = SendResult(state: SendState.idle);
  }
}
