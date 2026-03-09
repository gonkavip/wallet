import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';
import '../../data/models/balance_model.dart';
import '../../data/repositories/balance_repository.dart';
import 'node_provider.dart';
import 'wallet_provider.dart';

final balanceRepositoryProvider = Provider<BalanceRepository>((ref) {
  return BalanceRepository(ref.watch(nodeManagerProvider));
});

final balanceProvider =
    StateNotifierProvider<BalanceNotifier, AsyncValue<BalanceModel>>((ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  final wallet = ref.watch(activeWalletProvider);
  return BalanceNotifier(repo, wallet?.address);
});

class BalanceNotifier extends StateNotifier<AsyncValue<BalanceModel>> {
  final BalanceRepository _repo;
  final String? _address;
  Timer? _timer;

  BalanceNotifier(this._repo, this._address) : super(const AsyncValue.loading()) {
    if (_address != null) {
      refresh();
      _startAutoRefresh();
    }
  }

  Future<void> refresh() async {
    if (_address == null) return;
    try {
      final balance = await _repo.getBalance(_address);
      if (mounted) state = AsyncValue.data(balance);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: GonkaConstants.balanceRefreshSeconds),
      (_) => refresh(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
