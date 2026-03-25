import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../widgets/responsive_center.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  final String mnemonic;
  final String walletName;

  const SetPinScreen({
    super.key,
    required this.mnemonic,
    required this.walletName,
  });

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String _pin = '';
  String? _firstPin;
  bool _isConfirming = false;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkIfPinExists();
  }

  Future<void> _checkIfPinExists() async {
    final auth = ref.read(authServiceProvider);
    final pinSet = await auth.isPinSet();
    if (pinSet) {
      setState(() => _loading = true);
      try {
        final wallets = ref.read(walletsProvider.notifier);
        await wallets.importWallet(widget.walletName, widget.mnemonic);
        if (mounted) context.go('/home');
      } catch (e) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
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

  void _onPinComplete() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
      return;
    }

    if (_pin != _firstPin) {
      setState(() {
        _pin = '';
        _error = 'PINs do not match. Try again.';
        _isConfirming = false;
        _firstPin = null;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.createPin(_pin);

      final wallets = ref.read(walletsProvider.notifier);
      await wallets.importWallet(widget.walletName, widget.mnemonic);

      final bioAvailable = await auth.isBiometricAvailable();
      if (bioAvailable && mounted) {
        final enableBio = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Enable Biometrics?'),
            content: const Text(
                'Use Face ID / fingerprint to unlock your wallet?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Skip'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Enable'),
              ),
            ],
          ),
        );
        if (enableBio == true) {
          await ref
              .read(secureStorageProvider)
              .setBiometricEnabled(true);
        }
      }

      if (mounted) context.go('/home');
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set PIN')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveCenter(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    _isConfirming ? 'Confirm your PIN' : 'Create a 6-digit PIN',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
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
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                  const Spacer(),
                  Center(child: SizedBox(width: 320, child: _buildNumPad())),
                  const SizedBox(height: 32),
                ],
              ),
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
              for (var col = 0; col < 3; col++)
                _buildNumKey(row, col),
            ],
          ),
      ],
    );
  }

  Widget _buildNumKey(int row, int col) {
    if (row == 3 && col == 0) return const SizedBox(width: 80, height: 80);
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
