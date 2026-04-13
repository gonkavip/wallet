import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/node_client.dart';
import '../../core/transaction/broadcast_service.dart';
import 'send_provider.dart';
import 'wallet_provider.dart';

class GrantState {
  final bool isLoading;
  final String? error;
  final BroadcastResult? lastTxResult;

  GrantState({
    this.isLoading = false,
    this.error,
    this.lastTxResult,
  });

  GrantState copyWith({
    bool? isLoading,
    String? error,
    BroadcastResult? lastTxResult,
    bool clearError = false,
    bool clearTxResult = false,
  }) {
    return GrantState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastTxResult: clearTxResult ? null : (lastTxResult ?? this.lastTxResult),
    );
  }
}

final grantProvider =
    StateNotifierProvider<GrantNotifier, GrantState>((ref) {
  return GrantNotifier(
    ref.watch(broadcastServiceProvider),
    ref.watch(walletsProvider.notifier),
  );
});

class GrantNotifier extends StateNotifier<GrantState> {
  final BroadcastService _broadcast;
  final WalletsNotifier _wallets;

  GrantNotifier(this._broadcast, this._wallets) : super(GrantState());

  Future<void> grantPermissions({
    required String walletId,
    required String fromAddress,
    required String granteeAddress,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearTxResult: true);
    try {
      final pkHex = await _wallets.getPrivateKeyHex(walletId);
      if (pkHex == null) throw Exception('Private key not found');

      final result = await _broadcast.grantMlOpsPermissions(
        privateKeyHex: pkHex,
        fromAddress: fromAddress,
        granteeAddress: granteeAddress,
      );

      if (mounted) {
        state = state.copyWith(isLoading: false, lastTxResult: result);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void clearResult() {
    state = state.copyWith(clearTxResult: true, clearError: true);
  }
}
