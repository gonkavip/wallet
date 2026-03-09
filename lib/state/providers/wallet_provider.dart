import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/services/secure_storage_service.dart';
import '../../core/crypto/mnemonic_service.dart';
import '../../core/crypto/address_service.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final walletsProvider =
    StateNotifierProvider<WalletsNotifier, List<WalletModel>>((ref) {
  return WalletsNotifier(
    ref.watch(walletRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});

final activeWalletProvider = Provider<WalletModel?>((ref) {
  final wallets = ref.watch(walletsProvider);
  final repo = ref.watch(walletRepositoryProvider);
  final activeId = repo.getActiveWalletId();
  if (activeId == null && wallets.isNotEmpty) return wallets.first;
  return wallets.where((w) => w.id == activeId).firstOrNull;
});

class WalletsNotifier extends StateNotifier<List<WalletModel>> {
  final WalletRepository _repo;
  final SecureStorageService _storage;

  WalletsNotifier(this._repo, this._storage) : super([]);

  void load() {
    state = _repo.getWallets();
  }

  Future<WalletModel> createWallet(String name) async {
    final mnemonic = MnemonicService.generate();
    return await _importWallet(name, mnemonic);
  }

  Future<WalletModel> importWallet(String name, String mnemonic) async {
    if (!MnemonicService.validate(mnemonic)) {
      throw Exception('Invalid mnemonic');
    }
    return await _importWallet(name, mnemonic);
  }

  Future<WalletModel> _importWallet(String name, String mnemonic) async {
    final address = AddressService.fromMnemonic(mnemonic);
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final wallet = WalletModel(id: id, name: name, address: address);
    await _repo.createWallet(wallet);
    await _storage.saveMnemonic(id, mnemonic);
    await _repo.setActiveWallet(id);

    state = _repo.getWallets();
    return wallet;
  }

  Future<void> deleteWallet(String id) async {
    await _storage.deleteWallet(id);
    await _repo.deleteWallet(id);
    state = _repo.getWallets();
  }

  Future<void> renameWallet(String id, String newName) async {
    await _repo.renameWallet(id, newName);
    state = _repo.getWallets();
  }

  void setActive(String id) {
    _repo.setActiveWallet(id);
    state = [...state]; // trigger rebuild
  }

  Future<String?> getMnemonic(String walletId) =>
      _storage.getMnemonic(walletId);
}
