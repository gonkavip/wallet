import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hex/hex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/crypto/hd_key_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

class MinersScreen extends ConsumerWidget {
  const MinersScreen({super.key});

  Future<void> _showPubKey(BuildContext context, WidgetRef ref) async {
    final wallet = ref.read(activeWalletProvider);
    if (wallet == null) return;
    final pkHex = await ref.read(walletsProvider.notifier).getPrivateKeyHex(wallet.id);
    if (pkHex == null || !context.mounted) return;

    final privBytes = Uint8List.fromList(HEX.decode(pkHex));
    final pubKeyBase64 =
        base64Encode(HDKeyService.publicKeyFromPrivate(privBytes));

    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.minersPubKey,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  pubKeyBase64,
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pubKeyBase64));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.minersPubKeyCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(l10n.commonCopy),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.minersTitle),
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
            leading: const Icon(Icons.key_outlined),
            title: Text(l10n.minersPubKey),
            subtitle: Text(l10n.minersPubKeySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPubKey(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(l10n.minersCollateral),
            subtitle: Text(l10n.minersCollateralSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/collateral'),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: Text(l10n.minersGrant),
            subtitle: Text(l10n.minersGrantSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/grant'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_open_outlined),
            title: Text(l10n.minersUnjail),
            subtitle: Text(l10n.minersUnjailSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/unjail'),
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote_outlined),
            title: Text(l10n.minersGovernance),
            subtitle: Text(l10n.minersGovernanceSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/governance'),
          ),
          ListTile(
            leading: const Icon(Icons.track_changes_outlined),
            title: Text(l10n.minersTracker),
            subtitle: Text(l10n.minersTrackerSubtitle),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://tracker.gonka.vip/'),
                mode: LaunchMode.externalApplication),
          ),
        ],
      )),
    );
  }
}
