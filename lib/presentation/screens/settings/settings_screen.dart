import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/node_provider.dart';
import '../../widgets/responsive_center.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final activeNode = ref.watch(nodesProvider).activeNode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: ResponsiveCenter(child: ListView(
        padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.paddingOf(context).bottom),
        children: [
          ListTile(
            leading: const Icon(Icons.dns),
            title: Text(l10n.settingsNodeSettings),
            subtitle: activeNode != null
                ? Text(
                    '${activeNode.label} (${activeNode.isHealthy ? l10n.nodeStatusLatency(activeNode.latencyMs) : activeNode.isOnline ? l10n.nodeStatusNotSynced : l10n.nodeStatusOffline})')
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/nodes'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(l10n.settingsSecurity),
            subtitle: Text(l10n.settingsSecuritySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/security'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsTerms),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://gonka.vip/terms/'),
                mode: LaunchMode.externalApplication),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacy),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://gonka.vip/privacy/'),
                mode: LaunchMode.externalApplication),
          ),
        ],
      )),
    );
  }
}
