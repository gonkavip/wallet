import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/node_client.dart';
import '../../core/network/node_manager.dart';
import '../../core/transaction/broadcast_service.dart';
import '../../core/transaction/msg_vote.dart';
import 'node_provider.dart';
import 'send_provider.dart';
import 'wallet_provider.dart';

final proposalsProvider =
    StateNotifierProvider<ProposalsNotifier, AsyncValue<List<ProposalItem>>>(
        (ref) {
  final nodeManager = ref.watch(nodeManagerProvider);
  return ProposalsNotifier(nodeManager);
});

class ProposalsNotifier
    extends StateNotifier<AsyncValue<List<ProposalItem>>> {
  final NodeManager _nodeManager;

  ProposalsNotifier(this._nodeManager)
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
        client.getProposals(status: 2),
        client.getProposals(status: 3),
        client.getProposals(status: 4),
      ]);

      final all = <ProposalItem>[
        ...results[0],
        ...results[1],
        ...results[2],
      ];

      final seen = <String>{};
      final unique = <ProposalItem>[];
      for (final p in all) {
        if (seen.add(p.id)) unique.add(p);
      }
      unique.sort((a, b) {
        final aId = int.tryParse(a.id) ?? 0;
        final bId = int.tryParse(b.id) ?? 0;
        return bId.compareTo(aId);
      });

      if (mounted) state = AsyncValue.data(unique);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
}

final proposalDetailProvider =
    FutureProvider.family<ProposalItem?, String>((ref, proposalId) async {
  final nodeManager = ref.watch(nodeManagerProvider);
  final client = nodeManager.client;
  if (client == null) return null;
  return client.getProposal(proposalId);
});

class VoteState {
  final bool isLoading;
  final String? error;
  final BroadcastResult? lastTxResult;

  VoteState({
    this.isLoading = false,
    this.error,
    this.lastTxResult,
  });

  VoteState copyWith({
    bool? isLoading,
    String? error,
    BroadcastResult? lastTxResult,
    bool clearError = false,
    bool clearTxResult = false,
  }) {
    return VoteState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastTxResult:
          clearTxResult ? null : (lastTxResult ?? this.lastTxResult),
    );
  }
}

final voteProvider =
    StateNotifierProvider<VoteNotifier, VoteState>((ref) {
  return VoteNotifier(
    ref.watch(broadcastServiceProvider),
    ref.watch(walletsProvider.notifier),
  );
});

class VoteNotifier extends StateNotifier<VoteState> {
  final BroadcastService _broadcast;
  final WalletsNotifier _wallets;

  VoteNotifier(this._broadcast, this._wallets) : super(VoteState());

  Future<void> vote({
    required String walletId,
    required String fromAddress,
    required int proposalId,
    required VoteOption option,
  }) async {
    state = state.copyWith(
        isLoading: true, clearError: true, clearTxResult: true);
    try {
      final pkHex = await _wallets.getPrivateKeyHex(walletId);
      if (pkHex == null) throw Exception('Private key not found');

      final result = await _broadcast.vote(
        privateKeyHex: pkHex,
        fromAddress: fromAddress,
        proposalId: proposalId,
        option: option,
      );

      if (mounted) {
        state = state.copyWith(isLoading: false, lastTxResult: result);
      }
    } catch (e) {
      if (mounted) {
        String error;
        if (e is DioException && e.response?.statusCode == 404) {
          error = 'Account not found on chain. Make sure your account has received tokens before voting.';
        } else {
          error = e.toString();
        }
        state = state.copyWith(isLoading: false, error: error);
      }
    }
  }

  void clearResult() {
    state = state.copyWith(clearTxResult: true, clearError: true);
  }
}
