import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/crypto/address_service.dart';
import '../../core/network/node_client.dart';
import '../../core/transaction/broadcast_service.dart';
import '../../data/services/secure_storage_service.dart';
import 'send_provider.dart';
import 'node_provider.dart';
import 'wallet_provider.dart';

class UnjailState {
  final bool isLoading;
  final String? error;
  final BroadcastResult? lastTxResult;

  UnjailState({
    this.isLoading = false,
    this.error,
    this.lastTxResult,
  });

  UnjailState copyWith({
    bool? isLoading,
    String? error,
    BroadcastResult? lastTxResult,
    bool clearError = false,
    bool clearTxResult = false,
  }) {
    return UnjailState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastTxResult: clearTxResult ? null : (lastTxResult ?? this.lastTxResult),
    );
  }
}

final unjailProvider =
    StateNotifierProvider<UnjailNotifier, UnjailState>((ref) {
  return UnjailNotifier(
    ref.watch(broadcastServiceProvider),
    ref.watch(secureStorageProvider),
  );
});

final validatorJailedProvider =
    FutureProvider.family<bool?, String>((ref, address) async {
  final nodeManager = ref.watch(nodeManagerProvider);
  final client = nodeManager.client;
  if (client == null) return null;

  final valoperAddr = AddressService.toValoperAddress(address);
  final info = await client.getValidatorInfo(valoperAddr);
  return info?.jailed;
});

class UnjailNotifier extends StateNotifier<UnjailState> {
  final BroadcastService _broadcast;
  final SecureStorageService _storage;

  UnjailNotifier(this._broadcast, this._storage) : super(UnjailState());

  Future<void> unjail({
    required String walletId,
    required String fromAddress,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearTxResult: true);
    try {
      final mnemonic = await _storage.getMnemonic(walletId);
      if (mnemonic == null) throw Exception('Mnemonic not found');

      final result = await _broadcast.unjail(
        mnemonic: mnemonic,
        fromAddress: fromAddress,
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
