import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../core/platform_util.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

enum PinMode { login, verify, change }

enum _PinErrorKind { cooldown, wrongPin }

class PinEntryScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;
  const PinEntryScreen({super.key, this.mode = PinMode.login, this.onSuccess});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  _PinErrorKind? _errorKind;
  int _errorArg = 0;
  bool _loading = false;

  bool _enteringNew = false;
  String _currentPin = '';

  final _desktopController = TextEditingController();
  final _desktopFocusNode = FocusNode();

  String _titleText(AppLocalizations l10n) {
    if (widget.mode == PinMode.change) {
      return _enteringNew ? l10n.authEnterNewPin : l10n.authEnterCurrentPin;
    }
    return l10n.authEnterPin;
  }

  String? _errorText(AppLocalizations l10n) {
    final kind = _errorKind;
    if (kind == null) return null;
    return switch (kind) {
      _PinErrorKind.cooldown => l10n.authCooldown(_errorArg),
      _PinErrorKind.wrongPin => l10n.authWrongPin(_errorArg),
    };
  }

  @override
  void initState() {
    super.initState();
    if (widget.mode == PinMode.login) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _tryBiometric();
      });
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
    final reason = AppLocalizations.of(context).authBiometricReason;
    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric(reason: reason);
      if (success && mounted) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (widget.mode == PinMode.login) {
          context.go('/home');
        } else {
          context.pop(true);
        }
      }
    }
  }

  void _clearError() {
    _errorKind = null;
    _errorArg = 0;
  }

  void _onDigit(int digit) {
    if (_pin.length >= GonkaConstants.pinLength) return;
    setState(() {
      _pin += digit.toString();
      _clearError();
    });
    if (_pin.length == GonkaConstants.pinLength) {
      _onPinComplete();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _clearError();
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
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else if (widget.mode == PinMode.login) {
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
        if (cooldown > 0) {
          _errorKind = _PinErrorKind.cooldown;
          _errorArg = cooldown;
        } else {
          _errorKind = _PinErrorKind.wrongPin;
          _errorArg =
              GonkaConstants.maxPinAttempts - auth.failedAttempts;
        }
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
          _clearError();
        });
      } else {
        final cooldown = auth.remainingCooldownSeconds;
        _desktopController.clear();
        setState(() {
          _pin = '';
          if (cooldown > 0) {
            _errorKind = _PinErrorKind.cooldown;
            _errorArg = cooldown;
          } else {
            _errorKind = _PinErrorKind.wrongPin;
            _errorArg =
                GonkaConstants.maxPinAttempts - auth.failedAttempts;
          }
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
    final l10n = AppLocalizations.of(context);
    final showBack = widget.mode != PinMode.login;
    final errorText = _errorText(l10n);

    return Scaffold(
      appBar: showBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(false),
              ),
            )
          : null,
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!showBack) const SizedBox(height: 60),
              const SizedBox(height: 20),
              GlowBackground(
                size: 160,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GonkaColors.accentBlue.withValues(alpha: 0.12),
                    border: Border.all(
                      color: GonkaColors.accentBlue.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 42,
                    color: GonkaColors.accentBlue,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _titleText(l10n),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: GonkaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 32),
              if (PlatformUtil.isDesktop)
                _buildDesktopPinInput()
              else
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
                Text(errorText,
                    style: const TextStyle(
                        color: GonkaColors.error,
                        fontWeight: FontWeight.w500)),
              ],
              if (_loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
              const Spacer(),
              if (!PlatformUtil.isDesktop)
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

  Widget _buildDesktopPinInput() {
    final l10n = AppLocalizations.of(context);
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
        decoration: InputDecoration(
          hintText: l10n.authEnterPin,
          counterText: '',
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _pin = value;
            _clearError();
          });
          if (value.length == GonkaConstants.pinLength) {
            _onPinComplete();
          }
        },
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
      if (widget.mode == PinMode.change) {
        return const AspectRatio(aspectRatio: 1.3, child: SizedBox.shrink());
      }
      return _NumPadKey(
        onTap: _tryBiometric,
        child: const Icon(Icons.fingerprint_rounded,
            size: 28, color: GonkaColors.accentBlue),
      );
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
