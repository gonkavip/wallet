import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/platform_util.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wc_connect_provider.dart';
import '../../widgets/responsive_center.dart';
import 'wc_qr_scan_page.dart';

class WcConnectScreen extends ConsumerStatefulWidget {
  const WcConnectScreen({super.key});

  @override
  ConsumerState<WcConnectScreen> createState() => _WcConnectScreenState();
}

class _WcConnectScreenState extends ConsumerState<WcConnectScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      _controller.text = text.trim();
    }
  }

  Future<void> _scan() async {
    if (PlatformUtil.isDesktop) {
      await _paste();
      return;
    }
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const WcQrScanPage()),
    );
    if (result != null) _controller.text = result.trim();
  }

  Future<void> _continue() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(wcConnectProvider.notifier).pair(raw);
    } on WcConnectError catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final msg = switch (e.code) {
        'invalidUri' => l10n.wcConnectInvalidUri,
        'expiredUri' => l10n.wcConnectExpiredUri,
        'noWallets' => l10n.wcErrorNoWallets,
        _ => l10n.wcErrorGeneric(e.code),
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).wcErrorGeneric('$e')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.wcConnectTitle),
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
      body: ResponsiveCenter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _paste,
                      icon: const Icon(Icons.paste),
                      label: Text(l10n.wcConnectPaste),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _scan,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.wcConnectScan),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _continue,
                style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 56)),
                child: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.wcConnectContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
