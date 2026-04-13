import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/network/node_client.dart';
import '../../../core/transaction/msg_vote.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/governance_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../error_l10n.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

String _voteLabel(AppLocalizations l10n, VoteOption option) =>
    switch (option) {
      VoteOption.yes => l10n.proposalVoteYes,
      VoteOption.abstain => l10n.proposalVoteAbstain,
      VoteOption.no => l10n.proposalVoteNo,
      VoteOption.noWithVeto => l10n.proposalVoteNoWithVeto,
    };

class ProposalDetailScreen extends ConsumerStatefulWidget {
  final String proposalId;

  const ProposalDetailScreen({super.key, required this.proposalId});

  @override
  ConsumerState<ProposalDetailScreen> createState() =>
      _ProposalDetailScreenState();
}

class _ProposalDetailScreenState extends ConsumerState<ProposalDetailScreen> {
  VoteOption? _selectedOption;
  bool _authenticating = false;
  bool _broadcasting = false;
  bool _done = false;
  bool _success = false;
  String _txhash = '';
  String _error = '';

  Future<void> _authenticate() async {
    if (_selectedOption == null) return;
    setState(() => _authenticating = true);
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final reason = AppLocalizations.of(context).authBiometricReason;

    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric(reason: reason);
      if (success) {
        setState(() => _authenticating = false);
        _execute();
        return;
      }
    }

    if (!mounted) return;
    final success = await context.push<bool>('/auth/pin-verify') ?? false;
    if (success) {
      setState(() => _authenticating = false);
      _execute();
      return;
    }
    setState(() => _authenticating = false);
  }

  void _execute() async {
    final wallet = ref.read(activeWalletProvider);
    if (wallet == null || _selectedOption == null) return;

    setState(() => _broadcasting = true);

    final proposalIdInt = int.tryParse(widget.proposalId) ?? 0;

    await ref.read(voteProvider.notifier).vote(
          walletId: wallet.id,
          fromAddress: wallet.address,
          proposalId: proposalIdInt,
          option: _selectedOption!,
        );

    if (!mounted) return;
    final state = ref.read(voteProvider);
    final result = state.lastTxResult;

    setState(() {
      _broadcasting = false;
      _done = true;
      _success = result != null && result.isSuccess;
      _txhash = result?.txhash ?? '';
      _error = state.error ?? result?.rawLog ?? '';
    });
  }

  void _retry() {
    ref.read(voteProvider.notifier).clearResult();
    setState(() {
      _done = false;
      _success = false;
      _txhash = '';
      _error = '';
      _selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final proposalIdInt = int.tryParse(widget.proposalId) ?? 0;
    final proposalAsync = ref.watch(proposalDetailProvider(widget.proposalId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proposalDetailTitle(proposalIdInt)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/miners/governance');
            }
          },
        ),
      ),
      body: ResponsiveCenter(child: _done
          ? _buildResult(context)
          : proposalAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(l10n.proposalDetailErrorLoad(e.toString())),
              ),
              data: (proposal) {
                if (proposal == null) {
                  return Center(child: Text(l10n.proposalDetailNotFound));
                }
                return _buildDetail(context, proposal);
              },
            )),
    );
  }

  Widget _buildDetail(BuildContext context, ProposalItem proposal) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tally = proposal.tally;
    final totalVotes = tally.totalVotes;

    final Color badgeColor;
    final String badgeText;
    if (proposal.isVotingPeriod) {
      badgeColor = GonkaColors.success;
      badgeText = l10n.governanceStatusActive;
    } else if (proposal.isPassed) {
      badgeColor = GonkaColors.info;
      badgeText = l10n.governanceStatusPassed;
    } else if (proposal.isRejected) {
      badgeColor = GonkaColors.error;
      badgeText = l10n.governanceStatusRejected;
    } else {
      badgeColor = GonkaColors.textMuted;
      badgeText = proposal.status
          .replaceAll('PROPOSAL_STATUS_', '')
          .replaceAll('_', ' ')
          .toLowerCase();
    }

    final msgTypeShort = proposal.messageType
        .split('.')
        .lastOrNull
        ?.replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}') ??
        proposal.messageType;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.paddingOf(context).bottom),
      children: [
        Text(proposal.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: GonkaColors.textPrimary,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 14),

        Row(
          children: [
            StatusPill(label: badgeText, color: badgeColor),
          ],
        ),
        const SizedBox(height: 20),

        if (proposal.summary.isNotEmpty) ...[
          Text(l10n.proposalDetailSummary,
              style: const TextStyle(
                color: GonkaColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              )),
          const SizedBox(height: 6),
          Text(proposal.summary,
              style: const TextStyle(
                  fontSize: 14,
                  color: GonkaColors.textPrimary,
                  height: 1.5)),
          const SizedBox(height: 20),
        ],

        const Divider(),
        const SizedBox(height: 12),

        if (msgTypeShort.isNotEmpty) ...[
          _infoRow(l10n.commonType, msgTypeShort),
          const SizedBox(height: 8),
        ],

        if (proposal.proposer.isNotEmpty) ...[
          _infoRow(
              l10n.proposalDetailProposer,
              proposal.proposer.length > 20
                  ? '${proposal.proposer.substring(0, 10)}...${proposal.proposer.substring(proposal.proposer.length - 6)}'
                  : proposal.proposer),
          const SizedBox(height: 8),
        ],

        if (proposal.votingStartTime != null &&
            proposal.votingEndTime != null) ...[
          _infoRow(
            l10n.proposalDetailVotingPeriod,
            '${_formatDateTime(proposal.votingStartTime!)} — ${_formatDateTime(proposal.votingEndTime!)}',
          ),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),

        Text(l10n.proposalDetailTally,
            style: theme.textTheme.titleMedium?.copyWith(
                color: GonkaColors.textPrimary,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        _tallyBar(l10n.proposalVoteYes, tally.yesCount, totalVotes,
            GonkaColors.success),
        const SizedBox(height: 10),
        _tallyBar(l10n.proposalVoteAbstain, tally.abstainCount, totalVotes,
            GonkaColors.textMuted),
        const SizedBox(height: 10),
        _tallyBar(l10n.proposalVoteNo, tally.noCount, totalVotes,
            GonkaColors.error),
        const SizedBox(height: 10),
        _tallyBar(l10n.proposalVoteNoWithVeto, tally.noWithVetoCount,
            totalVotes, GonkaColors.warning),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        if (proposal.isVotingPeriod) ...[
          Text(l10n.proposalCastYourVote,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: GonkaColors.textPrimary,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _voteButton(l10n, VoteOption.yes, GonkaColors.success),
          const SizedBox(height: 8),
          _voteButton(l10n, VoteOption.abstain, GonkaColors.textMuted),
          const SizedBox(height: 8),
          _voteButton(l10n, VoteOption.no, GonkaColors.error),
          const SizedBox(height: 8),
          _voteButton(l10n, VoteOption.noWithVeto, GonkaColors.warning),
          const SizedBox(height: 24),
          if (_broadcasting)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedOption != null && !_authenticating
                    ? _authenticate
                    : null,
                child: Text(_authenticating
                    ? l10n.confirmSendAuthenticating
                    : l10n.proposalSubmitVote),
              ),
            ),
        ] else ...[
          InfoBanner(
            variant: InfoBannerVariant.info,
            message: l10n.proposalVotingEnded,
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  color: GonkaColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, color: GonkaColors.textPrimary)),
        ),
      ],
    );
  }

  Widget _tallyBar(String label, BigInt count, BigInt total, Color color) {
    final percentage =
        total > BigInt.zero ? (count * BigInt.from(100)) ~/ total : BigInt.zero;
    final fraction = total > BigInt.zero
        ? count.toDouble() / total.toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: GonkaColors.textPrimary)),
            Text('$percentage%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: GonkaColors.bgCard,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _voteButton(
      AppLocalizations l10n, VoteOption option, Color color) {
    final selected = _selectedOption == option;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedOption = option),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          side: BorderSide(
            color: selected ? color : GonkaColors.borderSubtle,
            width: selected ? 1.5 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GonkaRadius.md),
          ),
        ),
        child: Text(
          _voteLabel(l10n, option),
          style: TextStyle(
            color: selected ? color : GonkaColors.textPrimary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          ResultIcon(success: _success),
          const SizedBox(height: 28),
          Text(
            _success ? l10n.proposalVoteSubmitted : l10n.proposalVoteFailed,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: GonkaColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          if (_success && _txhash.isNotEmpty) TxHashDisplay(hash: _txhash),
          if (!_success && _error.isNotEmpty)
            InfoBanner(
              variant: InfoBannerVariant.error,
              message: localizeError(l10n, _error),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/miners/governance');
                }
              },
              child: Text(l10n.commonDone),
            ),
          ),
          if (!_success) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _retry,
                child: Text(l10n.commonRetry),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
