import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/responsive_center.dart';
import 'onboarding_secret.dart';

class NameWalletScreen extends ConsumerStatefulWidget {
  final OnboardingSecret secret;

  const NameWalletScreen({super.key, required this.secret});

  @override
  ConsumerState<NameWalletScreen> createState() => _NameWalletScreenState();
}

class _NameWalletScreenState extends ConsumerState<NameWalletScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _defaultApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_defaultApplied) {
      _controller.text = AppLocalizations.of(context).onboardingNameDefault;
      _defaultApplied = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingNameTitle)),
      body: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.onboardingNameHeading,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: GonkaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingNameSubtext,
                style: const TextStyle(
                    color: GonkaColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.onboardingNameLabel,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.onboardingNameValidationEmpty;
                  }
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.push(
                        '/onboarding/pin',
                        extra: <String, Object>{
                          'secret': widget.secret,
                          'name': _controller.text.trim(),
                        },
                      );
                    }
                  },
                  child: Text(l10n.onboardingNameContinue),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
