import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../core/platform_util.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

enum PinMode { login, verify, change }

class PinEntryScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  const PinEntryScreen({super.key, this.mode = PinMode.login});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  String? _error;
  bool _loading = false;

  bool _enteringNew = false;
  String _currentPin = '';

  final _desktopController = TextEditingController();
  final _desktopFocusNode = FocusNode();

  String get _title {
    if (widget.mode == PinMode.change) {
      return _enteringNew ? 'Enter New PIN' : 'Enter Current PIN';
    }
    return 'Enter PIN';
  }

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinMode.login) {
      _tryBiometric();
    }
  }

  @override
  void dispose() {
    _desktopController.dispose();
    _desktopFocusNode.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric();
      if (success && mounted) {
        if (widget.mode == PinMode.login) {
          context.go('/home');
        } else {
          context.pop(true);
        }
      }
    }
  }

  void _onDigit(int digit) {
    if (_pin.length >= GonkaConstants.pinLength) return;
    setState(() {
      _pin += digit.toString();
      _error = null;
    });
    if (_pin.length == GonkaConstants.pinLength) {
      _onPinComplete();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _onPinComplete() async {
    if (widget.mode == PinMode.change) {
      await _handleChangePin();
    } else {
      await _handleVerifyPin();
    }
  }

  Future<void> _handleVerifyPin() async {
    setState(() => _loading = true);
    final auth = ref.read(authServiceProvider);
    final success = await auth.verifyPin(_pin);
    setState(() => _loading = false);

    if (success) {
      if (!mounted) return;
      if (widget.mode == PinMode.login) {
        context.go('/home');
      } else {
        context.pop(true);
      }
    } else {
      if (!mounted) return;
      final stillHasPin = await auth.isPinSet();
      if (!stillHasPin) {
        ref.read(walletsProvider.notifier).load();
        context.go('/onboarding/create');
        return;
      }
      final cooldown = auth.remainingCooldownSeconds;
      _desktopController.clear();
      setState(() {
        _pin = '';
        _error = cooldown > 0
            ? 'Too many attempts. Wait ${cooldown}s.'
            : 'Wrong PIN. ${GonkaConstants.maxPinAttempts - auth.failedAttempts} attempts remaining.';
      });
    }
  }

  Future<void> _handleChangePin() async {
    if (!_enteringNew) {
      setState(() => _loading = true);
      final auth = ref.read(authServiceProvider);
      final success = await auth.verifyPin(_pin);
      setState(() => _loading = false);

      if (success) {
        _desktopController.clear();
        setState(() {
          _currentPin = _pin;
          _pin = '';
          _enteringNew = true;
          _error = null;
        });
      } else {
        final cooldown = auth.remainingCooldownSeconds;
        _desktopController.clear();
        setState(() {
          _pin = '';
          _error = cooldown > 0
              ? 'Too many attempts. Wait ${cooldown}s.'
              : 'Wrong PIN. ${GonkaConstants.maxPinAttempts - auth.failedAttempts} attempts remaining.';
        });
      }
    } else {
      setState(() => _loading = true);
      final auth = ref.read(authServiceProvider);
      final success = await auth.changePin(_currentPin, _pin);
      setState(() => _loading = false);

      if (!mounted) return;
      context.pop(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBack = widget.mode != PinMode.login;

    return Scaffold(
      appBar: showBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(false),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!showBack) const SizedBox(height: 60),
              const SizedBox(height: 20),
              Icon(
                Icons.lock,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              if (PlatformUtil.isDesktop)
                _buildDesktopPinInput()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(GonkaConstants.pinLength, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ],
              if (_loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
              const Spacer(),
              if (!PlatformUtil.isDesktop)
                Center(child: SizedBox(width: 320, child: _buildNumPad())),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPinInput() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: _desktopController,
        focusNode: _desktopFocusNode,
        autofocus: true,
        obscureText: true,
        textAlign: TextAlign.center,
        maxLength: GonkaConstants.pinLength,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          hintText: 'Enter PIN',
          counterText: '',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _pin = value;
            _error = null;
          });
          if (value.length == GonkaConstants.pinLength) {
            _onPinComplete();
          }
        },
      ),
    );
  }

  Widget _buildNumPad() {
    return Column(
      children: [
        for (var row = 0; row < 4; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var col = 0; col < 3; col++) _buildNumKey(row, col),
            ],
          ),
      ],
    );
  }

  Widget _buildNumKey(int row, int col) {
    if (row == 3 && col == 0) {
      if (widget.mode == PinMode.change) {
        return const SizedBox(width: 80, height: 80);
      }
      return SizedBox(
        width: 80,
        height: 80,
        child: IconButton(
          onPressed: _tryBiometric,
          icon: const Icon(Icons.fingerprint, size: 28),
        ),
      );
    }
    if (row == 3 && col == 2) {
      return SizedBox(
        width: 80,
        height: 80,
        child: IconButton(
          onPressed: _onDelete,
          icon: const Icon(Icons.backspace_outlined, size: 28),
        ),
      );
    }
    final digit = row == 3 ? 0 : row * 3 + col + 1;
    return SizedBox(
      width: 80,
      height: 80,
      child: TextButton(
        onPressed: () => _onDigit(digit),
        child: Text(
          '$digit',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
