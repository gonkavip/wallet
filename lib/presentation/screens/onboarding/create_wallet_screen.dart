import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

class CreateWalletScreen extends StatelessWidget {
  const CreateWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canGoBack = context.canPop();
    return Scaffold(
      appBar: canGoBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              GlowBackground(
                size: 240,
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width: 100,
                  height: 100,
                  colorFilter: const ColorFilter.mode(
                    GonkaColors.accentBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GradientText(
                l10n.onboardingCreateTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.onboardingCreateSubtitle,
                style: const TextStyle(
                  color: GonkaColors.textMuted,
                  fontSize: 15,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/onboarding/backup'),
                  child: Text(l10n.onboardingCreateNewWallet),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/onboarding/import'),
                  child: Text(l10n.onboardingCreateImportWallet),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(
                        Uri.parse('https://gonka.vip/terms/'),
                        mode: LaunchMode.externalApplication),
                    child: Text(
                      l10n.onboardingCreateTerms,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GonkaColors.textMuted,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('|',
                        style: TextStyle(
                            fontSize: 12, color: GonkaColors.textMuted)),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(
                        Uri.parse('https://gonka.vip/privacy/'),
                        mode: LaunchMode.externalApplication),
                    child: Text(
                      l10n.onboardingCreatePrivacy,
                      style: const TextStyle(
                        fontSize: 12,
                        color: GonkaColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
