import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart' show GonkaWalletApp, appRouter;
import 'core/platform_util.dart';
import 'data/repositories/wallet_repository.dart';
import 'data/repositories/node_repository.dart';
import 'data/services/secure_storage_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/device_security_service.dart';
import 'state/providers/wallet_provider.dart';
import 'state/providers/node_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final walletRepo = WalletRepository();
  await walletRepo.init();

  final nodeRepo = NodeRepository();
  await nodeRepo.init();

  final wallets = walletRepo.getWallets();
  final secureStorage = SecureStorageService();
  final authService = AuthService(secureStorage);
  final isPinSet = await authService.isPinSet();

  String initialRoute;
  if (wallets.isEmpty) {
    initialRoute = '/onboarding/create';
  } else if (isPinSet) {
    initialRoute = '/auth/pin';
  } else {
    initialRoute = '/home';
  }

  runApp(
    ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(walletRepo),
        nodeRepositoryProvider.overrideWithValue(nodeRepo),
      ],
      child: _AppInitializer(initialRoute: initialRoute),
    ),
  );
}

class _AppInitializer extends ConsumerStatefulWidget {
  final String initialRoute;
  const _AppInitializer({required this.initialRoute});

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer>
    with WidgetsBindingObserver {
  bool _wasPaused = false;

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
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 8),
              Text('Security Warning'),
            ],
          ),
          content: const Text(
            'This device appears to be rooted or jailbroken. '
            'Your wallet keys may be at risk.\n\n'
            'We strongly recommend using a non-compromised device '
            'to store cryptocurrency.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('I understand the risks'),
            ),
          ],
        ),
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
        appRouter.go('/auth/pin');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GonkaWalletApp(initialRoute: widget.initialRoute);
  }
}
