import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/platform_util.dart';
import '../../../data/models/wc_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wc_connect_provider.dart';
import '../../../state/providers/wc_provider.dart';
import '../../widgets/responsive_center.dart';
import 'wc_qr_scan_page.dart';

class WcPermissionsScreen extends ConsumerWidget {
  final String walletId;
  const WcPermissionsScreen({super.key, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(wcSessionsByWalletProvider(walletId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wcPermissionsTitle),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref, l10n),
        child: const Icon(Icons.add),
      ),
      body: ResponsiveCenter(
        child: sessions.isEmpty
            ? _empty(context, ref, l10n)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (_, i) =>
                    _sessionCard(context, ref, sessions[i], l10n),
              ),
      ),
    );
  }

  Widget _sessionCard(BuildContext context, WidgetRef ref, WcSession s,
      AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(color: GonkaColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apps, color: GonkaColors.accentBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.dappName.isEmpty ? '—' : s.dappName,
                        style: const TextStyle(
                            color: GonkaColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    if (s.dappUrl != null && s.dappUrl!.isNotEmpty)
                      Text(s.dappUrl!,
                          style: const TextStyle(
                              color: GonkaColors.textMuted, fontSize: 12)),
                    Text(
                      l10n.wcPermissionsApproved(_fmtDate(s.approvedAt)),
                      style: const TextStyle(
                          color: GonkaColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _kv(l10n.wcApproveChainsLabel, s.chains.join(', ')),
          const SizedBox(height: 6),
          _kv(l10n.wcApproveMethodsLabel, s.methods.join(', ')),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDisconnect(context, ref, s, l10n),
              icon: const Icon(Icons.link_off, size: 18),
              label: Text(l10n.wcPermissionsDisconnect),
              style: OutlinedButton.styleFrom(
                foregroundColor: GonkaColors.error,
                side: const BorderSide(color: GonkaColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: const TextStyle(
                  color: GonkaColors.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(v.isEmpty ? '—' : v,
              style: const TextStyle(
                  color: GonkaColors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 13)),
        ],
      );

  Widget _empty(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off,
                size: 48, color: GonkaColors.textMuted),
            const SizedBox(height: 12),
            Text(l10n.wcPermissionsEmpty,
                style: const TextStyle(color: GonkaColors.textMuted)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddSheet(context, ref, l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.wcPermissionsAddSession),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.wcPermissionsAddSession,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              if (!PlatformUtil.isDesktop)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addViaScan(context, ref, l10n);
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.wcConnectScan),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52)),
                ),
              if (!PlatformUtil.isDesktop) const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _addViaPaste(context, ref, l10n);
                },
                icon: const Icon(Icons.paste),
                label: Text(l10n.wcConnectPaste),
                style:
                    OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addViaScan(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const WcQrScanPage()),
    );
    if (result == null || result.isEmpty) return;
    await _addSession(context, ref, l10n, result);
  }

  Future<void> _addViaPaste(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final uri = await showDialog<String>(
      context: context,
      builder: (ctx) => _PasteUriDialog(l10n: l10n),
    );
    if (uri == null || uri.isEmpty) return;
    if (!context.mounted) return;
    await _addSession(context, ref, l10n, uri);
  }

  Future<void> _addSession(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, String rawUri) async {
    ref.read(wcPendingWalletIdProvider.notifier).state = walletId;
    try {
      await ref.read(wcConnectProvider.notifier).pair(rawUri);
    } on WcConnectError catch (e) {
      if (!context.mounted) return;
      final msg = switch (e.code) {
        'invalidUri' => l10n.wcConnectInvalidUri,
        'expiredUri' => l10n.wcConnectExpiredUri,
        _ => l10n.wcErrorGeneric(e.code),
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.wcErrorGeneric('$e'))));
    }
  }

  Future<void> _confirmDisconnect(BuildContext context, WidgetRef ref,
      WcSession session, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.wcPermissionsDisconnect),
        content: Text(l10n.wcPermissionsDisconnectConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: GonkaColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.wcPermissionsDisconnect),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(wcConnectProvider.notifier).disconnect(session.topic);
    } catch (_) {}
  }

  String _fmtDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
  }
}

class _PasteUriDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _PasteUriDialog({required this.l10n});

  @override
  State<_PasteUriDialog> createState() => _PasteUriDialogState();
}

class _PasteUriDialogState extends State<_PasteUriDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.wcConnectPaste),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.wcConnectUriHint,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  _controller.text = data!.text!.trim();
                }
              },
              icon: const Icon(Icons.paste, size: 16),
              label: Text(l10n.wcConnectPaste),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) Navigator.pop(context, text);
          },
          child: Text(l10n.wcConnectContinue),
        ),
      ],
    );
  }
}
