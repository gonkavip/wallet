import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers/wallet_provider.dart';
import '../../state/providers/auth_provider.dart';
import '../widgets/gonka_widgets.dart';

enum _SplashStatus { loading, checkingNodes }

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  _SplashStatus _status = _SplashStatus.loading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final wallets = ref.read(walletsProvider);
    final authService = ref.read(authServiceProvider);
    final router = GoRouter.of(context);

    setState(() => _status = _SplashStatus.checkingNodes);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final isPinSet = await authService.isPinSet();
    if (!mounted) return;

    if (wallets.isEmpty) {
      router.go('/onboarding/create');
    } else if (isPinSet) {
      router.go('/auth/pin');
    } else {
      router.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusText = switch (_status) {
      _SplashStatus.loading => l10n.splashLoading,
      _SplashStatus.checkingNodes => l10n.splashCheckingNodes,
    };
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlowBackground(
              size: 220,
              child: SvgPicture.asset(
                'assets/logo.svg',
                width: 80,
                height: 80,
                colorFilter: const ColorFilter.mode(
                  GonkaColors.accentBlue,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientText(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              statusText,
              style: const TextStyle(
                color: GonkaColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
