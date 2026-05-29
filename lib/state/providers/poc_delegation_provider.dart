import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/node_client.dart';
import '../../core/transaction/broadcast_service.dart';
import 'node_provider.dart';
import 'send_provider.dart';
import 'wallet_provider.dart';

class NotParticipantException implements Exception {
  final bool isSender;
  const NotParticipantException({required this.isSender});

  @override
  String toString() => isSender
      ? 'Sender is not a registered participant'
      : 'Delegate is not a registered participant';
}

class PocDelegationState {
  final List<String> models;
  final bool modelsLoading;
  final bool isLoading;
  final String? error;
  final BroadcastResult? lastTxResult;

  PocDelegationState({
    this.models = const [],
    this.modelsLoading = false,
    this.isLoading = false,
    this.error,
    this.lastTxResult,
  });

  PocDelegationState copyWith({
    List<String>? models,
    bool? modelsLoading,
    bool? isLoading,
    String? error,
    BroadcastResult? lastTxResult,
    bool clearError = false,
    bool clearTxResult = false,
  }) {
    return PocDelegationState(
      models: models ?? this.models,
      modelsLoading: modelsLoading ?? this.modelsLoading,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastTxResult: clearTxResult ? null : (lastTxResult ?? this.lastTxResult),
    );
  }
}

final pocDelegationProvider =
    StateNotifierProvider<PocDelegationNotifier, PocDelegationState>((ref) {
  return PocDelegationNotifier(
    ref.watch(broadcastServiceProvider),
    ref.watch(walletsProvider.notifier),
    ref.watch(nodeManagerProvider),
  );
});

final isParticipantProvider =
    FutureProvider.family<bool?, String>((ref, address) async {
  final nodeManager = ref.watch(nodeManagerProvider);
  final client = nodeManager.client;
  if (client == null) return null;
  return client.isParticipant(address);
});

class PocDelegationNotifier extends StateNotifier<PocDelegationState> {
  final BroadcastService _broadcast;
  final WalletsNotifier _wallets;
  final dynamic _nodeManager;

  PocDelegationNotifier(this._broadcast, this._wallets, this._nodeManager)
      : super(PocDelegationState());

  Future<void> loadModels() async {
    state = state.copyWith(modelsLoading: true, clearError: true);
    try {
      final client = _nodeManager.client as NodeClient?;
      if (client == null) throw Exception('No active node');

      final models = await client.getModels();
      if (mounted) {
        state = state.copyWith(models: models, modelsLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(modelsLoading: false, error: e.toString());
      }
    }
  }

  Future<void> delegate({
    required String walletId,
    required String fromAddress,
    required String modelId,
    required String delegateTo,
  }) async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearTxResult: true);
    try {
      final client = _nodeManager.client as NodeClient?;
      if (client == null) throw Exception('No active node');

      if (!await client.isParticipant(fromAddress)) {
        throw const NotParticipantException(isSender: true);
      }
      if (delegateTo.isNotEmpty && !await client.isParticipant(delegateTo)) {
        throw const NotParticipantException(isSender: false);
      }

      final pkHex = await _wallets.getPrivateKeyHex(walletId);
      if (pkHex == null) throw Exception('Private key not found');

      final result = await _broadcast.setPocDelegation(
        privateKeyHex: pkHex,
        fromAddress: fromAddress,
        modelId: modelId,
        delegateTo: delegateTo,
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
