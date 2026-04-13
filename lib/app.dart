import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/gonka_theme.dart';
import 'l10n/app_localizations.dart';
import 'state/providers/locale_provider.dart';
import 'presentation/screens/onboarding/create_wallet_screen.dart';
import 'presentation/screens/onboarding/backup_mnemonic_screen.dart';
import 'presentation/screens/onboarding/import_wallet_screen.dart';
import 'presentation/screens/onboarding/name_wallet_screen.dart';
import 'presentation/screens/onboarding/set_pin_screen.dart';
import 'presentation/screens/onboarding/onboarding_secret.dart';
import 'presentation/screens/auth/pin_entry_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/home/wallet_detail_screen.dart';
import 'presentation/screens/send/send_screen.dart';
import 'presentation/screens/send/confirm_send_screen.dart';
import 'presentation/screens/send/send_result_screen.dart';
import 'presentation/screens/receive/receive_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/settings/node_settings_screen.dart';
import 'presentation/screens/settings/security_settings_screen.dart';
import 'presentation/screens/miners/miners_screen.dart';
import 'presentation/screens/miners/collateral_screen.dart';
import 'presentation/screens/miners/collateral_amount_screen.dart';
import 'presentation/screens/miners/collateral_confirm_screen.dart';
import 'presentation/screens/miners/collateral_result_screen.dart';
import 'presentation/screens/miners/grant_screen.dart';
import 'presentation/screens/miners/grant_confirm_screen.dart';
import 'presentation/screens/miners/grant_result_screen.dart';
import 'presentation/screens/miners/unjail_screen.dart';
import 'presentation/screens/miners/governance_screen.dart';
import 'presentation/screens/miners/proposal_detail_screen.dart';

late GoRouter appRouter;

GoRouter _buildRouter(String initialRoute) {
  appRouter = GoRouter(
    initialLocation: initialRoute,
    routes: [
    GoRoute(
      path: '/onboarding/create',
      builder: (_, __) => const CreateWalletScreen(),
    ),
    GoRoute(
      path: '/onboarding/backup',
      builder: (_, __) => const BackupMnemonicScreen(),
    ),
    GoRoute(
      path: '/onboarding/import',
      builder: (_, __) => const ImportWalletScreen(),
    ),
    GoRoute(
      path: '/onboarding/name',
      builder: (_, state) {
        final secret = state.extra as OnboardingSecret;
        return NameWalletScreen(secret: secret);
      },
    ),
    GoRoute(
      path: '/onboarding/pin',
      builder: (_, state) {
        final data = state.extra as Map<String, Object>;
        return SetPinScreen(
          secret: data['secret'] as OnboardingSecret,
          walletName: data['name'] as String,
        );
      },
    ),

    GoRoute(
      path: '/auth/pin',
      builder: (_, __) => const PinEntryScreen(),
    ),
    GoRoute(
      path: '/auth/pin-verify',
      builder: (_, __) => const PinEntryScreen(mode: PinMode.verify),
    ),
    GoRoute(
      path: '/auth/pin-change',
      builder: (_, __) => const PinEntryScreen(mode: PinMode.change),
    ),

    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

    GoRoute(
      path: '/wallet/:id',
      builder: (_, state) {
        final walletId = state.pathParameters['id']!;
        return WalletDetailScreen(walletId: walletId);
      },
    ),

    GoRoute(path: '/send', builder: (_, __) => const SendScreen()),
    GoRoute(
      path: '/send/confirm',
      builder: (_, state) {
        final data = state.extra as Map<String, String>;
        return ConfirmSendScreen(
          toAddress: data['toAddress']!,
          amountNgonka: data['amountNgonka']!,
        );
      },
    ),
    GoRoute(
      path: '/send/result',
      builder: (_, state) {
        final data = state.extra as Map<String, dynamic>;
        return SendResultScreen(
          success: data['success'] as bool,
          txhash: data['txhash'] as String? ?? '',
          error: data['error'] as String? ?? '',
        );
      },
    ),

    GoRoute(path: '/receive', builder: (_, __) => const ReceiveScreen()),

    GoRoute(path: '/miners', builder: (_, __) => const MinersScreen()),
    GoRoute(
      path: '/miners/collateral',
      builder: (_, __) => const CollateralScreen(),
    ),
    GoRoute(
      path: '/miners/collateral/deposit',
      builder: (_, __) => const CollateralAmountScreen(isDeposit: true),
    ),
    GoRoute(
      path: '/miners/collateral/withdraw',
      builder: (_, __) => const CollateralAmountScreen(isDeposit: false),
    ),
    GoRoute(
      path: '/miners/collateral/confirm',
      builder: (_, state) {
        final data = state.extra as Map<String, dynamic>;
        return CollateralConfirmScreen(
          amountNgonka: data['amountNgonka'] as String,
          isDeposit: data['isDeposit'] as bool,
        );
      },
    ),
    GoRoute(
      path: '/miners/collateral/result',
      builder: (_, state) {
        final data = state.extra as Map<String, dynamic>;
        return CollateralResultScreen(
          success: data['success'] as bool,
          txhash: data['txhash'] as String? ?? '',
          error: data['error'] as String? ?? '',
          isDeposit: data['isDeposit'] as bool,
        );
      },
    ),

    GoRoute(
      path: '/miners/grant',
      builder: (_, __) => const GrantScreen(),
    ),
    GoRoute(
      path: '/miners/grant/confirm',
      builder: (_, state) {
        final data = state.extra as Map<String, String>;
        return GrantConfirmScreen(
          granteeAddress: data['granteeAddress']!,
        );
      },
    ),
    GoRoute(
      path: '/miners/grant/result',
      builder: (_, state) {
        final data = state.extra as Map<String, dynamic>;
        return GrantResultScreen(
          success: data['success'] as bool,
          txhash: data['txhash'] as String? ?? '',
          error: data['error'] as String? ?? '',
        );
      },
    ),

    GoRoute(
      path: '/miners/unjail',
      builder: (_, __) => const UnjailScreen(),
    ),

    GoRoute(
      path: '/miners/governance',
      builder: (_, __) => const GovernanceScreen(),
    ),
    GoRoute(
      path: '/miners/governance/:id',
      builder: (_, state) => ProposalDetailScreen(
        proposalId: state.pathParameters['id']!,
      ),
    ),

    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(
      path: '/settings/nodes',
      builder: (_, __) => const NodeSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/security',
      builder: (_, __) => const SecuritySettingsScreen(),
    ),
  ],
  );
  return appRouter;
}

class GonkaWalletApp extends ConsumerStatefulWidget {
  final String initialRoute;
  const GonkaWalletApp({super.key, required this.initialRoute});

  @override
  ConsumerState<GonkaWalletApp> createState() => _GonkaWalletAppState();
}

class _GonkaWalletAppState extends ConsumerState<GonkaWalletApp> {
  late final GoRouter _router = _buildRouter(widget.initialRoute);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildGonkaDarkTheme(),
      darkTheme: buildGonkaDarkTheme(),
      themeMode: ThemeMode.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
