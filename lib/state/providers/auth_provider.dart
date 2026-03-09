import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import 'wallet_provider.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final auth = AuthService(ref.watch(secureStorageProvider));
  auth.onWipe = () async {
    final repo = ref.read(walletRepositoryProvider);
    await repo.clearAll();
  };
  return auth;
});

final isPinSetProvider = FutureProvider<bool>((ref) {
  return ref.watch(authServiceProvider).isPinSet();
});

final isBiometricAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(authServiceProvider).isBiometricAvailable();
});
