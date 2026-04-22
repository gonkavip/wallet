import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/models/wc_proposal_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/wc_connect_provider.dart';
import '../../../state/providers/wc_provider.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/wc_dapp_header.dart';

class WcApproveSessionScreen extends ConsumerStatefulWidget {
  final String? preSelectedWalletId;
  const WcApproveSessionScreen({super.key, this.preSelectedWalletId});

  @override
  ConsumerState<WcApproveSessionScreen> createState() =>
      _WcApproveSessionScreenState();
}

class _WcApproveSessionScreenState
    extends ConsumerState<WcApproveSessionScreen> {
  String? _selectedWalletId;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final proposal = ref.watch(wcActiveProposalProvider);
    final wallets = ref.watch(walletsProvider);

    if (proposal == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.wcApproveTitle)),
        body: Center(
          child: Text(l10n.wcErrorGeneric('no pending proposal')),
        ),
      );
    }

    _selectedWalletId ??=
        widget.preSelectedWalletId ??
        (wallets.isNotEmpty ? wallets.first.id : null);
    final canApprove = proposal.validation == WcValidationResult.ok &&
        _selectedWalletId != null;
    final showWalletPicker =
        widget.preSelectedWalletId == null && wallets.length > 1;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) await _reject(proposal.id);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.wcApproveTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await _reject(proposal.id);
              if (!context.mounted) return;
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ),
        body: ResponsiveCenter(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              WcDappHeader(
                name: proposal.dappName,
                url: proposal.dappUrl,
                iconUrl: proposal.dappIcon,
                description: proposal.dappDescription,
              ),
              const SizedBox(height: 16),
              if (proposal.validation != WcValidationResult.ok)
                _warningBanner(
                  proposal.validation == WcValidationResult.unsupportedChain
                      ? l10n.wcApproveUnsupportedChain
                      : l10n.wcApproveUnsupportedMethod,
                ),
              const SizedBox(height: 8),
              _section(
                context,
                l10n.wcApproveChainsLabel,
                _joinList(proposal.requiredChains, proposal.optionalChains),
              ),
              _section(
                context,
                l10n.wcApproveMethodsLabel,
                _joinList(proposal.requiredMethods, proposal.optionalMethods),
              ),
              const SizedBox(height: 16),
              if (showWalletPicker) ...[
                Text(
                  l10n.wcApproveChooseWallet,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedWalletId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: wallets
                      .map((w) => DropdownMenuItem<String>(
                            value: w.id,
                            child: Text(
                              '${w.name} — ${_shortAddr(w.address)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedWalletId = v),
                ),
              ] else if (_selectedWalletId != null) ...[
                () {
                  final w = wallets.where((w) => w.id == _selectedWalletId).firstOrNull;
                  if (w == null) return const SizedBox.shrink();
                  return _section(
                    context,
                    l10n.wcApproveChooseWallet,
                    '${w.name} — ${_shortAddr(w.address)}',
                  );
                }(),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => _onReject(proposal.id),
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56)),
                      child: Text(l10n.wcApproveReject),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: canApprove && !_busy
                          ? () => _onApprove(proposal, wallets)
                          : null,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 56)),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(l10n.wcApproveApprove),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _joinList(List<String> required, List<String> optional) {
    final all = [...required, ...optional];
    if (all.isEmpty) return '—';
    return all.join('\n');
  }

  String _shortAddr(String a) {
    if (a.length <= 16) return a;
    return '${a.substring(0, 10)}…${a.substring(a.length - 4)}';
  }

  Widget _section(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: GonkaColors.textMuted,
                fontSize: 12,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: GonkaColors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 13,
              )),
        ],
      ),
    );
  }

  Widget _warningBanner(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GonkaColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(GonkaRadius.sm),
          border: Border.all(
              color: GonkaColors.error.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: GonkaColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: GonkaColors.error)),
            ),
          ],
        ),
      );

  Future<void> _reject(int id) async {
    try {
      await ref.read(wcConnectProvider.notifier).reject(id);
    } catch (_) {}
    ref.read(wcActiveProposalProvider.notifier).state = null;
  }

  Future<void> _onReject(int id) async {
    await _reject(id);
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _onApprove(
      WcProposalView proposal, List<WalletModel> wallets) async {
    final chosen = wallets.firstWhere((w) => w.id == _selectedWalletId);
    setState(() => _busy = true);
    try {
      await ref.read(wcConnectProvider.notifier).approve(
            proposalId: proposal.id,
            pairingTopic: proposal.pairingTopic,
            wallet: chosen,
            dappName: proposal.dappName,
            dappUrl: proposal.dappUrl,
            dappIcon: proposal.dappIcon,
            dappDescription: proposal.dappDescription,
          );
      ref.read(wcActiveProposalProvider.notifier).state = null;
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
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
}
