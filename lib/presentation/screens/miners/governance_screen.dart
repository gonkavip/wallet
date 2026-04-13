import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../core/network/node_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/governance_provider.dart';
import '../../widgets/gonka_widgets.dart';
import '../../widgets/responsive_center.dart';

class GovernanceScreen extends ConsumerWidget {
  const GovernanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final proposalsAsync = ref.watch(proposalsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.governanceTitle),
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
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.governanceTabAll),
              Tab(text: l10n.governanceTabActive),
              Tab(text: l10n.governanceTabClosed),
            ],
          ),
        ),
        body: ResponsiveCenter(child: proposalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: GonkaColors.error),
                const SizedBox(height: 12),
                Text(l10n.governanceErrorLoad(e.toString())),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.read(proposalsProvider.notifier).refresh(),
                  child: Text(l10n.commonRetry),
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
                  emptyMessage: l10n.governanceEmptyAll,
                  onRefresh: () =>
                      ref.read(proposalsProvider.notifier).refresh(),
                ),
                _ProposalList(
                  proposals: active,
                  emptyMessage: l10n.governanceEmptyActive,
                  onRefresh: () =>
                      ref.read(proposalsProvider.notifier).refresh(),
                ),
                _ProposalList(
                  proposals: closed,
                  emptyMessage: l10n.governanceEmptyClosed,
                  onRefresh: () =>
                      ref.read(proposalsProvider.notifier).refresh(),
                ),
              ],
            );
          },
        )),
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
                    const Icon(Icons.how_to_vote_outlined,
                        size: 48, color: GonkaColors.textMuted),
                    const SizedBox(height: 12),
                    Text(emptyMessage,
                        style: const TextStyle(color: GonkaColors.textMuted)),
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
      child: Builder(
        builder: (context) => ListView.builder(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
          itemCount: proposals.length,
          itemBuilder: (context, index) {
            final proposal = proposals[index];
            return _ProposalCard(proposal: proposal);
          },
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalItem proposal;

  const _ProposalCard({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    final String timeInfo;
    if (proposal.isVotingPeriod && proposal.votingEndTime != null) {
      final remaining = proposal.votingEndTime!.difference(DateTime.now());
      if (remaining.isNegative) {
        timeInfo = l10n.governanceEndingSoon;
      } else if (remaining.inDays > 0) {
        timeInfo = l10n.governanceEndsInDays(
            remaining.inDays, remaining.inHours % 24);
      } else if (remaining.inHours > 0) {
        timeInfo = l10n.governanceEndsInHours(
            remaining.inHours, remaining.inMinutes % 60);
      } else {
        timeInfo = l10n.governanceEndsInMinutes(remaining.inMinutes);
      }
    } else if (proposal.votingEndTime != null) {
      final dt = proposal.votingEndTime!.toLocal();
      final formatted =
          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      timeInfo = l10n.governanceEndedOn(formatted);
    } else {
      timeInfo = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(color: GonkaColors.borderSubtle, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/miners/governance/${proposal.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('#${proposal.id}',
                          style: const TextStyle(
                              color: GonkaColors.textMuted,
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(proposal.title,
                            style: const TextStyle(
                                color: GonkaColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Icon(Icons.chevron_right,
                          color: GonkaColors.textMuted),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      StatusPill(label: badgeText, color: badgeColor),
                      if (timeInfo.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Text(timeInfo,
                            style: const TextStyle(
                                fontSize: 12,
                                color: GonkaColors.textMuted)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
