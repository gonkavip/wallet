import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import '../../config/constants.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage;
  final LocalAuthentication _localAuth;
  int _failedAttempts = 0;
  DateTime? _cooldownUntil;
  bool _loaded = false;
  Future<void> Function()? onWipe;

  AuthService(this._storage) : _localAuth = LocalAuthentication();

  Future<void> _loadState() async {
    if (_loaded) return;
    _failedAttempts = await _storage.getFailedAttempts();
    _cooldownUntil = await _storage.getCooldownUntil();
    _loaded = true;
  }

  Future<void> _saveState() async {
    await _storage.saveFailedAttempts(_failedAttempts);
    await _storage.saveCooldownUntil(_cooldownUntil);
  }

  Future<void> createPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(salt, pin);
    await _storage.saveSalt(salt);
    await _storage.savePinHash(hash);
    _failedAttempts = 0;
    _cooldownUntil = null;
    await _saveState();
  }

  Future<bool> verifyPin(String pin) async {
    await _loadState();
    if (_isInCooldown()) return false;

    final salt = await _storage.getSalt();
    final storedHash = await _storage.getPinHash();
    if (salt == null || storedHash == null) return false;

    final hash = _hashPin(salt, pin);
    if (hash == storedHash) {
      _failedAttempts = 0;
      _cooldownUntil = null;
      await _saveState();
      return true;
    }

    _failedAttempts++;
    if (_failedAttempts >= GonkaConstants.maxPinAttempts) {
      final shouldWipe = await _storage.isWipeOnFailedAttempts();
      if (shouldWipe) {
        await _storage.deleteAll();
        _failedAttempts = 0;
        _cooldownUntil = null;
        _loaded = false;
        if (onWipe != null) await onWipe!();
        return false;
      }
      _cooldownUntil = DateTime.now().add(
        Duration(seconds: GonkaConstants.pinCooldownSeconds),
      );
    }
    await _saveState();
    return false;
  }

  Future<bool> changePin(String currentPin, String newPin) async {
    if (!await verifyPin(currentPin)) return false;
    await createPin(newPin);
    return true;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric({
    String reason = 'Authenticate to access your wallet',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> isPinSet() async {
    final hash = await _storage.getPinHash();
    return hash != null;
  }

  bool _isInCooldown() {
    if (_cooldownUntil == null) return false;
    if (DateTime.now().isAfter(_cooldownUntil!)) {
      _cooldownUntil = null;
      _failedAttempts = 0;
      return false;
    }
    return true;
  }

  int get remainingCooldownSeconds {
    if (_cooldownUntil == null) return 0;
    final remaining = _cooldownUntil!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  int get failedAttempts => _failedAttempts;

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String _hashPin(String salt, String pin) {
    final saltBytes = base64Decode(salt);
    final pinBytes = Uint8List.fromList(utf8.encode(pin));

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(saltBytes, 100000, 32));

    final derived = pbkdf2.process(pinBytes);
    return base64Encode(derived);
  }
}
