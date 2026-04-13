import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          mOptions: MacOsOptions(useDataProtectionKeyChain: false),
        );

  Future<void> saveMnemonic(String walletId, String mnemonic) =>
      _storage.write(key: 'mnemonic_$walletId', value: mnemonic);

  Future<String?> getMnemonic(String walletId) =>
      _storage.read(key: 'mnemonic_$walletId');

  Future<void> deleteMnemonic(String walletId) =>
      _storage.delete(key: 'mnemonic_$walletId');

  Future<void> savePrivateKeyHex(String walletId, String hex) =>
      _storage.write(key: 'pk_$walletId', value: hex);

  Future<String?> getPrivateKeyHex(String walletId) =>
      _storage.read(key: 'pk_$walletId');

  Future<void> deletePrivateKeyHex(String walletId) =>
      _storage.delete(key: 'pk_$walletId');

  Future<void> savePinHash(String hash) =>
      _storage.write(key: 'pin_hash', value: hash);

  Future<String?> getPinHash() => _storage.read(key: 'pin_hash');

  Future<void> saveSalt(String salt) =>
      _storage.write(key: 'pin_salt', value: salt);

  Future<String?> getSalt() => _storage.read(key: 'pin_salt');

  Future<void> saveFailedAttempts(int count) =>
      _storage.write(key: 'failed_attempts', value: count.toString());

  Future<int> getFailedAttempts() async {
    final value = await _storage.read(key: 'failed_attempts');
    return value != null ? int.tryParse(value) ?? 0 : 0;
  }

  Future<void> saveCooldownUntil(DateTime? time) => time != null
      ? _storage.write(key: 'cooldown_until', value: time.toIso8601String())
      : _storage.delete(key: 'cooldown_until');

  Future<DateTime?> getCooldownUntil() async {
    final value = await _storage.read(key: 'cooldown_until');
    return value != null ? DateTime.tryParse(value) : null;
  }

  Future<void> setWipeOnFailedAttempts(bool enabled) =>
      _storage.write(key: 'wipe_on_failed_attempts', value: enabled.toString());

  Future<bool> isWipeOnFailedAttempts() async {
    final value = await _storage.read(key: 'wipe_on_failed_attempts');
    return value != 'false';
  }

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: 'biometric_enabled', value: enabled.toString());

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  Future<void> deleteWallet(String walletId) async {
    await deleteMnemonic(walletId);
    await deletePrivateKeyHex(walletId);
  }

  Future<void> deleteAll() => _storage.deleteAll();
}
