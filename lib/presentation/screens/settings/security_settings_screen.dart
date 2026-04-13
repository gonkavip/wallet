import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool? _biometricEnabled;
  bool? _biometricAvailable;
  bool? _wipeEnabled;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageProvider);
    final auth = ref.read(authServiceProvider);
    final enabled = await storage.isBiometricEnabled();
    final available = await auth.isBiometricAvailable();
    final wipe = await storage.isWipeOnFailedAttempts();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricAvailable = available;
        _wipeEnabled = wipe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.securityTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
      ),
      body: ResponsiveCenter(child: ListView(
        padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.paddingOf(context).bottom),
        children: [
          ListTile(
            leading: const Icon(Icons.pin),
            title: Text(l10n.securityChangePin),
            onTap: _changePin,
          ),
          if (_biometricAvailable == true)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: Text(l10n.securityBiometric),
              value: _biometricEnabled ?? false,
              onChanged: _toggleBiometric,
            ),
          SwitchListTile(
            secondary: const Icon(Icons.delete_forever),
            title: Text(l10n.securityWipe),
            subtitle: Text(
              l10n.securityWipeSubtitle(GonkaConstants.maxPinAttempts),
            ),
            value: _wipeEnabled ?? true,
            onChanged: _toggleWipe,
          ),
        ],
      )),
    );
  }

  void _changePin() async {
    final success = await context.push<bool>('/auth/pin-change') ?? false;
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? l10n.securityPinChanged : l10n.securityPinNotChanged),
        ),
      );
    }
  }

  void _toggleWipe(bool value) async {
    final storage = ref.read(secureStorageProvider);
    await storage.setWipeOnFailedAttempts(value);
    setState(() => _wipeEnabled = value);
  }

  void _toggleBiometric(bool value) async {
    final storage = ref.read(secureStorageProvider);
    if (value) {
      final auth = ref.read(authServiceProvider);
      final reason = AppLocalizations.of(context).authBiometricReason;
      final success = await auth.authenticateBiometric(reason: reason);
      if (success) {
        await storage.setBiometricEnabled(true);
        setState(() => _biometricEnabled = true);
      }
    } else {
      await storage.setBiometricEnabled(false);
      setState(() => _biometricEnabled = false);
    }
  }

}
