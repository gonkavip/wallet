import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/node_client.dart';
import '../../core/transaction/broadcast_service.dart';
import '../../data/services/secure_storage_service.dart';
import 'node_provider.dart';
import 'send_provider.dart';
import 'wallet_provider.dart';

class CollateralState {
  final BigInt collateral;
  final List<UnbondingEntry> unbonding;
  final bool isLoading;
  final String? error;
  final BroadcastResult? lastTxResult;

  CollateralState({
    BigInt? collateral,
    this.unbonding = const [],
    this.isLoading = false,
    this.error,
    this.lastTxResult,
  }) : collateral = collateral ?? BigInt.zero;

  CollateralState copyWith({
    BigInt? collateral,
    List<UnbondingEntry>? unbonding,
    bool? isLoading,
    String? error,
    BroadcastResult? lastTxResult,
    bool clearError = false,
    bool clearTxResult = false,
  }) {
    return CollateralState(
      collateral: collateral ?? this.collateral,
      unbonding: unbonding ?? this.unbonding,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastTxResult: clearTxResult ? null : (lastTxResult ?? this.lastTxResult),
    );
  }
}

final collateralProvider =
    StateNotifierProvider<CollateralNotifier, CollateralState>((ref) {
  return CollateralNotifier(
    ref.watch(broadcastServiceProvider),
    ref.watch(secureStorageProvider),
    ref.watch(nodeManagerProvider),
  );
});

class CollateralNotifier extends StateNotifier<CollateralState> {
  final BroadcastService _broadcast;
  final SecureStorageService _storage;
  final dynamic _nodeManager;

  CollateralNotifier(this._broadcast, this._storage, this._nodeManager)
      : super(CollateralState());

  Future<void> load(String address) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final client = _nodeManager.client as NodeClient?;
      if (client == null) throw Exception('No active node');

      final collateral = await client.getCollateral(address);
      final unbonding = await client.getUnbondingCollateral(address);

      if (mounted) {
        state = state.copyWith(
          collateral: collateral,
          unbonding: unbonding,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> deposit({
    required String walletId,
    required String address,
    required String amountNgonka,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearTxResult: true);
    try {
      final mnemonic = await _storage.getMnemonic(walletId);
      if (mnemonic == null) throw Exception('Mnemonic not found');

      final result = await _broadcast.depositCollateral(
        mnemonic: mnemonic,
        fromAddress: address,
        amount: amountNgonka,
      );

      if (mounted) {
        state = state.copyWith(isLoading: false, lastTxResult: result);
        if (result.isSuccess) {
          await load(address);
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> withdraw({
    required String walletId,
    required String address,
    required String amountNgonka,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearTxResult: true);
    try {
      final mnemonic = await _storage.getMnemonic(walletId);
      if (mnemonic == null) throw Exception('Mnemonic not found');

      final result = await _broadcast.withdrawCollateral(
        mnemonic: mnemonic,
        fromAddress: address,
        amount: amountNgonka,
      );

      if (mounted) {
        state = state.copyWith(isLoading: false, lastTxResult: result);
        if (result.isSuccess) {
          await load(address);
        }
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
