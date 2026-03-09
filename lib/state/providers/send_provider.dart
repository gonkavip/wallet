import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/transaction/broadcast_service.dart';
import '../../data/services/secure_storage_service.dart';
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
    ref.watch(secureStorageProvider),
  );
});

class SendNotifier extends StateNotifier<SendResult> {
  final BroadcastService _broadcast;
  final SecureStorageService _storage;

  SendNotifier(this._broadcast, this._storage)
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
      final mnemonic = await _storage.getMnemonic(walletId);
      if (mnemonic == null) {
        state = SendResult(state: SendState.error, error: 'Mnemonic not found');
        return;
      }

      state = SendResult(state: SendState.broadcasting);

      final result = await _broadcast.send(
        mnemonic: mnemonic,
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
