import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/address_book_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../error_l10n.dart';
import '../../widgets/responsive_center.dart';
import 'onboarding_secret.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  final OnboardingSecret secret;
  final String walletName;

  const SetPinScreen({
    super.key,
    required this.secret,
    required this.walletName,
  });

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  String _pin = '';
  String? _firstPin;
  bool _isConfirming = false;
  bool _mismatch = false;
  String? _errorText;
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
        await _persistWallet();
        if (mounted) context.go('/home');
      } catch (e) {
        setState(() {
          _loading = false;
          _errorText = e.toString();
        });
      }
    }
  }

  Future<void> _persistWallet() async {
    final wallets = ref.read(walletsProvider.notifier);
    final wallet = widget.secret.isMnemonic
        ? await wallets.importWallet(
            widget.walletName, widget.secret.mnemonic!)
        : await wallets.importWalletFromPrivateKeyHex(
            widget.walletName, widget.secret.privateKeyHex!);
    final book = ref.read(addressBookProvider.notifier);
    if (!book.containsAddress(wallet.address)) {
      await book.add(widget.walletName, wallet.address);
    }
  }

  void _onDigit(int digit) {
    if (_pin.length >= GonkaConstants.pinLength) return;
    setState(() {
      _pin += digit.toString();
      _mismatch = false;
      _errorText = null;
    });
    if (_pin.length == GonkaConstants.pinLength) {
      _onPinComplete();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _mismatch = false;
      _errorText = null;
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
        _mismatch = true;
        _isConfirming = false;
        _firstPin = null;
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.createPin(_pin);

      await _persistWallet();

      final bioAvailable = await auth.isBiometricAvailable();
      if (bioAvailable && mounted) {
        final enableBio = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx);
            return AlertDialog(
              title: Text(l10n.onboardingPinBiometricTitle),
              content: Text(l10n.onboardingPinBiometricBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.onboardingPinBiometricSkip),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.onboardingPinBiometricEnable),
                ),
              ],
            );
          },
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
        _errorText = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final errorText = _mismatch
        ? l10n.onboardingPinMismatch
        : (_errorText != null ? localizeError(l10n, _errorText) : null);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingPinTitle)),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveCenter(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    _isConfirming
                        ? l10n.onboardingPinConfirmHeading
                        : l10n.onboardingPinCreateHeading,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: GonkaColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(GonkaConstants.pinLength, (i) {
                      final filled = i < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: filled ? 18 : 14,
                        height: filled ? 18 : 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? GonkaColors.accentBlue
                              : Colors.transparent,
                          border: Border.all(
                            color: filled
                                ? GonkaColors.accentBlue
                                : GonkaColors.borderStrong,
                            width: filled ? 0 : 1.5,
                          ),
                          boxShadow: filled
                              ? [
                                  BoxShadow(
                                    color: GonkaColors.accentBlue
                                        .withValues(alpha: 0.5),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    }),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      errorText,
                      style: const TextStyle(
                          color: GonkaColors.error,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                  const Spacer(),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: _buildNumPad(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildNumPad() {
    const gap = 10.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row > 0) const SizedBox(height: gap),
          Row(
            children: [
              for (var col = 0; col < 3; col++) ...[
                if (col > 0) const SizedBox(width: gap),
                Expanded(child: _buildNumKey(row, col)),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNumKey(int row, int col) {
    if (row == 3 && col == 0) {
      return const AspectRatio(aspectRatio: 1.3, child: SizedBox.shrink());
    }
    if (row == 3 && col == 2) {
      return _NumPadKey(
        onTap: _onDelete,
        child: const Icon(Icons.backspace_outlined,
            size: 26, color: GonkaColors.textPrimary),
      );
    }
    final digit = row == 3 ? 0 : row * 3 + col + 1;
    return _NumPadKey(
      onTap: () => _onDigit(digit),
      child: Text(
        '$digit',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: GonkaColors.textPrimary,
        ),
      ),
    );
  }
}

class _NumPadKey extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _NumPadKey({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Material(
        color: GonkaColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GonkaRadius.md),
          side: const BorderSide(
              color: GonkaColors.borderSubtle, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GonkaRadius.md),
          splashColor: GonkaColors.accentBlue.withValues(alpha: 0.15),
          highlightColor: GonkaColors.accentBlue.withValues(alpha: 0.08),
          child: Center(child: child),
        ),
      ),
    );
  }
}
