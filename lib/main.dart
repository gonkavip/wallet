import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart' show GonkaWalletApp;
import 'config/design_tokens.dart';
import 'config/gonka_theme.dart';
import 'core/platform_util.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/node_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/secure_storage_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/device_security_service.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/auth/pin_entry_screen.dart';
import 'state/providers/wallet_provider.dart';
import 'state/providers/node_provider.dart';
import 'state/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final walletRepo = WalletRepository();
  await walletRepo.init();

  final nodeRepo = NodeRepository();
  await nodeRepo.init();

  final settingsRepo = SettingsRepository();
  await settingsRepo.init();

  final wallets = walletRepo.getWallets();
  final secureStorage = SecureStorageService();
  final authService = AuthService(secureStorage);
  final isPinSet = await authService.isPinSet();

  final bool needsInitialAuth = wallets.isNotEmpty && isPinSet;

  String initialRoute;
  if (wallets.isEmpty) {
    initialRoute = '/onboarding/create';
  } else {
    initialRoute = '/home';
  }

  runApp(
    ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(walletRepo),
        nodeRepositoryProvider.overrideWithValue(nodeRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
      ],
      child: _AppInitializer(
        initialRoute: initialRoute,
        needsInitialAuth: needsInitialAuth,
      ),
    ),
  );
}

class _AppInitializer extends ConsumerStatefulWidget {
  final String initialRoute;
  final bool needsInitialAuth;
  const _AppInitializer({
    required this.initialRoute,
    required this.needsInitialAuth,
  });

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer>
    with WidgetsBindingObserver {
  bool _wasPaused = false;
  late bool _isLocked = widget.needsInitialAuth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(walletsProvider.notifier).load();
      ref.read(nodesProvider.notifier).load();
      _checkDeviceSecurity();
    });
  }

  Future<void> _checkDeviceSecurity() async {
    final compromised = await DeviceSecurityService.isDeviceCompromised();
    if (compromised && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber, color: GonkaColors.error),
                const SizedBox(width: 8),
                Text(l10n.securityWarningTitle),
              ],
            ),
            content: Text(l10n.securityWarningBody),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.securityWarningAck),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final triggerState = PlatformUtil.isDesktop
        ? AppLifecycleState.hidden
        : AppLifecycleState.paused;

    if (state == triggerState) {
      _wasPaused = true;
    } else if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      if (widget.initialRoute != '/onboarding/create') {
        setState(() => _isLocked = true);
      }
    }
  }

  void _onUnlock() {
    setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          GonkaWalletApp(initialRoute: widget.initialRoute),
          if (_isLocked)
            UncontrolledProviderScope(
              container: ProviderScope.containerOf(context),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: buildGonkaDarkTheme(),
                darkTheme: buildGonkaDarkTheme(),
                themeMode: ThemeMode.dark,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: PinEntryScreen(onSuccess: _onUnlock),
              ),
            ),
        ],
      ),
    );
  }
}
