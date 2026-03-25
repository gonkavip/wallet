import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/node_client.dart';
import '../../../core/transaction/msg_vote.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/governance_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/responsive_center.dart';

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

    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      final success = await auth.authenticateBiometric();
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
    final proposalAsync = ref.watch(proposalDetailProvider(widget.proposalId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Proposal #${widget.proposalId}'),
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
                child: Text('Failed to load proposal: $e'),
              ),
              data: (proposal) {
                if (proposal == null) {
                  return const Center(child: Text('Proposal not found'));
                }
                return _buildDetail(context, proposal);
              },
            )),
    );
  }

  Widget _buildDetail(BuildContext context, ProposalItem proposal) {
    final theme = Theme.of(context);
    final tally = proposal.tally;
    final totalVotes = tally.totalVotes;

    final Color badgeColor;
    final String badgeText;
    if (proposal.isVotingPeriod) {
      badgeColor = Colors.green;
      badgeText = 'Active';
    } else if (proposal.isPassed) {
      badgeColor = Colors.blue;
      badgeText = 'Passed';
    } else if (proposal.isRejected) {
      badgeColor = Colors.red;
      badgeText = 'Rejected';
    } else {
      badgeColor = Colors.grey;
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
      padding: const EdgeInsets.all(24),
      children: [
        Text(proposal.title,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(badgeText,
                  style: TextStyle(
                      color: badgeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (proposal.summary.isNotEmpty) ...[
          Text('Summary', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(proposal.summary, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
        ],

        const Divider(),
        const SizedBox(height: 12),

        if (msgTypeShort.isNotEmpty) ...[
          _infoRow('Type', msgTypeShort),
          const SizedBox(height: 8),
        ],

        if (proposal.proposer.isNotEmpty) ...[
          _infoRow(
              'Proposer',
              proposal.proposer.length > 20
                  ? '${proposal.proposer.substring(0, 10)}...${proposal.proposer.substring(proposal.proposer.length - 6)}'
                  : proposal.proposer),
          const SizedBox(height: 8),
        ],

        if (proposal.votingStartTime != null &&
            proposal.votingEndTime != null) ...[
          _infoRow(
            'Voting Period',
            '${_formatDateTime(proposal.votingStartTime!)} — ${_formatDateTime(proposal.votingEndTime!)}',
          ),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),

        Text('Tally Results', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        _tallyBar('Yes', tally.yesCount, totalVotes, Colors.green),
        const SizedBox(height: 8),
        _tallyBar('Abstain', tally.abstainCount, totalVotes, Colors.grey),
        const SizedBox(height: 8),
        _tallyBar('No', tally.noCount, totalVotes, Colors.red),
        const SizedBox(height: 8),
        _tallyBar(
            'No with Veto', tally.noWithVetoCount, totalVotes, Colors.orange),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        if (proposal.isVotingPeriod) ...[
          Text('Cast Your Vote', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _voteButton(VoteOption.yes, Colors.green),
          const SizedBox(height: 8),
          _voteButton(VoteOption.abstain, Colors.grey),
          const SizedBox(height: 8),
          _voteButton(VoteOption.no, Colors.red),
          const SizedBox(height: 8),
          _voteButton(VoteOption.noWithVeto, Colors.orange),
          const SizedBox(height: 24),
          if (_broadcasting)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _selectedOption != null && !_authenticating
                    ? _authenticate
                    : null,
                child: Text(_authenticating
                    ? 'Authenticating...'
                    : 'Submit Vote'),
              ),
            ),
        ] else ...[
          Card(
            color: Colors.grey.withValues(alpha: 0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Voting has ended for this proposal.'),
                  ),
                ],
              ),
            ),
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
                  color: Colors.grey, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13)),
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
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('$percentage%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withValues(alpha: 0.1),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _voteButton(VoteOption option, Color color) {
    final selected = _selectedOption == option;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => setState(() => _selectedOption = option),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              selected ? color.withValues(alpha: 0.15) : null,
          side: BorderSide(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          option.displayName,
          style: TextStyle(
            color: selected ? color : null,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Icon(
            _success ? Icons.check_circle : Icons.error,
            size: 80,
            color: _success ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            _success ? 'Vote Submitted' : 'Vote Failed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_success && _txhash.isNotEmpty) ...[
            Text('Transaction Hash',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _txhash));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hash copied to clipboard')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _txhash,
                  style:
                      const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          if (!_success && _error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _error,
              style: TextStyle(color: Colors.red[300], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/miners/governance');
                }
              },
              child: const Text('Done'),
            ),
          ),
          if (!_success) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _retry,
                child: const Text('Retry'),
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
