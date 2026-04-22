import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/walletconnect/wc_service.dart';
import '../../data/models/wc_proposal_view.dart';
import '../../data/models/wc_session.dart';
import '../../data/models/wc_sign_request_view.dart';
import '../../data/repositories/wc_session_repository.dart';

final wcServiceProvider = Provider<WcService>((ref) {
  throw UnimplementedError('wcServiceProvider must be overridden in main');
});

final wcSessionRepositoryProvider = Provider<WcSessionRepository>((ref) {
  throw UnimplementedError(
    'wcSessionRepositoryProvider must be overridden in main',
  );
});

final wcActiveProposalProvider = StateProvider<WcProposalView?>((ref) => null);

final wcActiveSignRequestProvider =
    StateProvider<WcSignRequestView?>((ref) => null);

final wcPendingWalletIdProvider = StateProvider<String?>((ref) => null);

final wcSessionsProvider =
    StateNotifierProvider<WcSessionsNotifier, List<WcSession>>((ref) {
  return WcSessionsNotifier(
    ref.watch(wcSessionRepositoryProvider),
    ref.watch(wcServiceProvider),
  );
});

final wcSessionsByWalletProvider =
    Provider.family<List<WcSession>, String>((ref, walletId) {
  final all = ref.watch(wcSessionsProvider);
  return all.where((s) => s.walletId == walletId).toList();
});

class WcSessionsNotifier extends StateNotifier<List<WcSession>> {
  final WcSessionRepository _repo;
  final WcService _wc;

  WcSessionsNotifier(this._repo, this._wc) : super([]) {
    refresh();
  }

  void refresh() {
    final fromHive = _repo.all();
    if (!_wc.isInitialized) {
      state = fromHive;
      return;
    }
    final active = _wc.getActiveSessions();
    final reconciled =
        fromHive.where((s) => active.containsKey(s.topic)).toList();
    if (reconciled.length != fromHive.length) {
      for (final s in fromHive) {
        if (!active.containsKey(s.topic)) {
          _repo.delete(s.topic);
        }
      }
    }
    state = reconciled;
  }

  Future<void> addSession(WcSession session) async {
    await _repo.save(session);
    refresh();
  }

  Future<void> removeSession(String topic) async {
    await _repo.delete(topic);
    refresh();
  }
}
