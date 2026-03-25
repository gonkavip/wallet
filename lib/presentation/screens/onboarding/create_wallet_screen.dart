import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/responsive_center.dart';

class CreateWalletScreen extends StatelessWidget {
  const CreateWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canGoBack = context.canPop();
    return Scaffold(
      appBar: canGoBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/logo.svg',
                width: 100,
                height: 100,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Gonka Wallet',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Secure wallet for the Gonka blockchain',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => context.push('/onboarding/backup'),
                  child: const Text('Create New Wallet'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.push('/onboarding/import'),
                  child: const Text('Import Existing Wallet'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse('https://gonka.vip/terms/'), mode: LaunchMode.externalApplication),
                    child: Text(
                      'Terms of Use',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.underline),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('|', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse('https://gonka.vip/privacy/'), mode: LaunchMode.externalApplication),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], decoration: TextDecoration.underline),
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
