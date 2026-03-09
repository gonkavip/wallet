import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/node_client.dart';
import '../../../state/providers/governance_provider.dart';

class GovernanceScreen extends ConsumerWidget {
  const GovernanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposalsAsync = ref.watch(proposalsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Governance'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/miners');
              }
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        body: proposalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load proposals: $e'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.read(proposalsProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (proposals) {
            final active = proposals.where((p) => p.isVotingPeriod).toList();
            final closed = proposals.where((p) => !p.isVotingPeriod).toList();

            return TabBarView(
              children: [
                _ProposalList(
                  proposals: proposals,
                  emptyMessage: 'No proposals found',
                  onRefresh: () => ref.read(proposalsProvider.notifier).refresh(),
                ),
                _ProposalList(
                  proposals: active,
                  emptyMessage: 'No active proposals',
                  onRefresh: () => ref.read(proposalsProvider.notifier).refresh(),
                ),
                _ProposalList(
                  proposals: closed,
                  emptyMessage: 'No closed proposals',
                  onRefresh: () => ref.read(proposalsProvider.notifier).refresh(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProposalList extends StatelessWidget {
  final List<ProposalItem> proposals;
  final String emptyMessage;
  final Future<void> Function() onRefresh;

  const _ProposalList({
    required this.proposals,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.how_to_vote_outlined,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(emptyMessage,
                        style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: proposals.length,
        itemBuilder: (context, index) {
          final proposal = proposals[index];
          return _ProposalCard(proposal: proposal);
        },
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalItem proposal;

  const _ProposalCard({required this.proposal});

  @override
  Widget build(BuildContext context) {
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

    final String timeInfo;
    if (proposal.isVotingPeriod && proposal.votingEndTime != null) {
      final remaining = proposal.votingEndTime!.difference(DateTime.now());
      if (remaining.isNegative) {
        timeInfo = 'Ending soon';
      } else if (remaining.inDays > 0) {
        timeInfo = 'Ends in ${remaining.inDays}d ${remaining.inHours % 24}h';
      } else if (remaining.inHours > 0) {
        timeInfo = 'Ends in ${remaining.inHours}h ${remaining.inMinutes % 60}m';
      } else {
        timeInfo = 'Ends in ${remaining.inMinutes}m';
      }
    } else if (proposal.votingEndTime != null) {
      final dt = proposal.votingEndTime!.toLocal();
      timeInfo =
          'Ended ${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } else {
      timeInfo = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Text('#${proposal.id}',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(proposal.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badgeText,
                    style: TextStyle(
                        color: badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              if (timeInfo.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(timeInfo,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/miners/governance/${proposal.id}'),
      ),
    );
  }
}
