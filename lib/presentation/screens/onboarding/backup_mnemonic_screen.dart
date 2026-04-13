import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/crypto/mnemonic_service.dart';
import '../../../data/services/device_security_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';
import 'onboarding_secret.dart';

final _tempMnemonicProvider = StateProvider<String>((ref) => '');

class BackupMnemonicScreen extends ConsumerStatefulWidget {
  const BackupMnemonicScreen({super.key});

  @override
  ConsumerState<BackupMnemonicScreen> createState() =>
      _BackupMnemonicScreenState();
}

class _BackupMnemonicScreenState extends ConsumerState<BackupMnemonicScreen> {
  late String _mnemonic;
  late List<String> _words;
  bool _confirmed = false;
  bool _verifying = false;
  int _verifyIndex = 0;
  final _verifyController = TextEditingController();
  bool _showVerifyError = false;

  @override
  void initState() {
    super.initState();
    _mnemonic = MnemonicService.generate();
    _words = _mnemonic.split(' ');
    DeviceSecurityService.enableSecureScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_tempMnemonicProvider.notifier).state = _mnemonic;
    });
  }

  @override
  void dispose() {
    DeviceSecurityService.disableSecureScreen();
    _verifyController.dispose();
    super.dispose();
  }

  void _startVerification() {
    setState(() {
      _verifying = true;
      _verifyIndex = Random.secure().nextInt(_words.length);
      _verifyController.clear();
      _showVerifyError = false;
    });
  }

  void _checkVerification() {
    if (_verifyController.text.trim().toLowerCase() ==
        _words[_verifyIndex].toLowerCase()) {
      context.push('/onboarding/name',
          extra: OnboardingSecret.mnemonic(_mnemonic));
    } else {
      setState(() {
        _showVerifyError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_verifying) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.onboardingBackupVerifyTitle)),
        body: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingBackupVerifyPrompt(_verifyIndex + 1),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _verifyController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText:
                      l10n.onboardingBackupVerifyHint(_verifyIndex + 1),
                  errorText: _showVerifyError
                      ? l10n.onboardingBackupVerifyError
                      : null,
                ),
                onSubmitted: (_) => _checkVerification(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _checkVerification,
                  child: Text(l10n.onboardingBackupVerifyButton),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingBackupTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding/create');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoBanner(
              variant: InfoBannerVariant.warning,
              message: l10n.onboardingBackupWarning,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: GonkaColors.bgCard,
                      borderRadius: BorderRadius.circular(GonkaRadius.sm),
                      border: Border.all(
                          color: GonkaColors.borderSubtle, width: 1),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: const TextStyle(
                            color: GonkaColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _words[index],
                            style: const TextStyle(
                              color: GonkaColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!_confirmed) ...[
              CheckboxListTile(
                value: false,
                onChanged: (v) {
                  if (v == true) {
                    setState(() => _confirmed = true);
                  }
                },
                title: Text(l10n.onboardingBackupCheckbox),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
            if (_confirmed)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _startVerification,
                  child: Text(l10n.onboardingBackupContinue),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
