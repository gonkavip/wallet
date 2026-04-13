import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/design_tokens.dart';
import '../../../core/transaction/msg_vote.dart';
import '../../../data/models/balance_model.dart';
import '../../../data/models/tx_history_model.dart';
import '../../../data/services/device_security_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/balance_provider.dart';
import '../../../state/providers/tx_history_provider.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/responsive_center.dart';

String _voteLabel(AppLocalizations l10n, VoteOption option) =>
    switch (option) {
      VoteOption.yes => l10n.proposalVoteYes,
      VoteOption.abstain => l10n.proposalVoteAbstain,
      VoteOption.no => l10n.proposalVoteNo,
      VoteOption.noWithVeto => l10n.proposalVoteNoWithVeto,
    };

class WalletDetailScreen extends ConsumerStatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() =>
      _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  bool _useGnk = true;
  bool _hasMnemonic = true;

  @override
  void initState() {
    super.initState();
    _loadHasMnemonic();
  }

  Future<void> _loadHasMnemonic() async {
    final result = await ref
        .read(walletsProvider.notifier)
        .hasMnemonic(widget.walletId);
    if (mounted) setState(() => _hasMnemonic = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wallets = ref.watch(walletsProvider);
    final wallet = wallets.where((w) => w.id == widget.walletId).firstOrNull;

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.walletDetailTitle)),
        body: Center(child: Text(l10n.walletDetailNotFound)),
      );
    }

    final balanceAsync = ref.watch(balanceProvider);
    final txHistoryAsync = ref.watch(txHistoryProvider(wallet.address));

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'seed':
                  _showMnemonic(context, ref, wallet.id);
                case 'pk':
                  _exportPrivateKey(context, ref, wallet.id);
                case 'rename':
                  _renameWallet(context, ref, wallet.id, wallet.name);
                case 'delete':
                  _deleteWallet(
                      context, ref, wallet.id, wallet.name, wallets.length);
              }
            },
            itemBuilder: (ctx) => [
              if (_hasMnemonic)
                PopupMenuItem(
                    value: 'seed', child: Text(l10n.walletDetailShowSeed)),
              PopupMenuItem(
                  value: 'pk', child: Text(l10n.walletDetailExportPk)),
              PopupMenuItem(
                  value: 'rename', child: Text(l10n.walletDetailRename)),
              PopupMenuItem(
                value: 'delete',
                child: Text(l10n.walletDetailDelete,
                    style: const TextStyle(color: GonkaColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: ResponsiveCenter(child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(balanceProvider.notifier).refresh();
          ref.invalidate(txHistoryProvider(wallet.address));
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
          children: [
            Center(child: AddressDisplay(address: wallet.address)),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => setState(() => _useGnk = !_useGnk),
              child: balanceAsync.when(
                data: (balance) =>
                    BalanceCard(balance: balance, useGnk: _useGnk),
                loading: () => BalanceCard(balance: BalanceModel.zero()),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: GonkaColors.error),
                        const SizedBox(height: 8),
                        Text(l10n.walletDetailBalanceError(e.toString())),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/send'),
                    icon: const Icon(Icons.arrow_upward),
                    label: Text(l10n.walletDetailSend),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/receive'),
                    icon: const Icon(Icons.arrow_downward),
                    label: Text(l10n.walletDetailReceive),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/miners'),
                icon: const Icon(Icons.engineering_outlined),
                label: Text(l10n.walletDetailHostTools),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(l10n.walletDetailTxHistory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: GonkaColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 12),

            txHistoryAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 48, color: GonkaColors.textMuted),
                        const SizedBox(height: 12),
                        Text(l10n.walletDetailNoTx,
                            style: const TextStyle(
                                color: GonkaColors.textMuted)),
                      ],
                    ),
                  );
                }
                return Column(
                  children: txs
                      .map((tx) =>
                          _TxHistoryTile(tx: tx, myAddress: wallet.address))
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(l10n.walletDetailTxError,
                      style: const TextStyle(color: GonkaColors.textMuted)),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _showMnemonic(
      BuildContext context, WidgetRef ref, String walletId) async {
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final reason = AppLocalizations.of(context).authBiometricReason;

    bool authenticated = false;
    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      authenticated = await auth.authenticateBiometric(reason: reason);
    }

    if (!authenticated && mounted) {
      authenticated = await context.push<bool>('/auth/pin-verify') ?? false;
    }

    if (!authenticated || !mounted) return;

    final mnemonic =
        await ref.read(walletsProvider.notifier).getMnemonic(walletId);
    if (mnemonic == null || !mounted) return;

    final words = mnemonic.split(' ');
    await DeviceSecurityService.enableSecureScreen();
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).walletDetailSeedDialogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: words.length,
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: GonkaColors.bgCard,
                borderRadius: BorderRadius.circular(GonkaRadius.sm),
                border: Border.all(
                    color: GonkaColors.borderSubtle, width: 1),
              ),
              child: Center(
                child: Text('${i + 1}. ${words[i]}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: GonkaColors.textPrimary,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx).commonClose),
          ),
        ],
      ),
    );
    await DeviceSecurityService.disableSecureScreen();
  }

  void _exportPrivateKey(
      BuildContext context, WidgetRef ref, String walletId) async {
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);
    final reason = AppLocalizations.of(context).authBiometricReason;

    bool authenticated = false;
    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      authenticated = await auth.authenticateBiometric(reason: reason);
    }

    if (!authenticated && mounted) {
      authenticated = await context.push<bool>('/auth/pin-verify') ?? false;
    }

    if (!authenticated || !mounted) return;

    final hex =
        await ref.read(walletsProvider.notifier).getPrivateKeyHex(walletId);
    if (hex == null || !mounted) return;

    await DeviceSecurityService.enableSecureScreen();
    if (!mounted) return;
    try {
      await showDialog(
        context: context,
        builder: (ctx) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(l10n.walletDetailExportPkDialogTitle),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.walletDetailExportPkWarning,
                    style: const TextStyle(
                      color: GonkaColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GonkaColors.bgCard,
                      borderRadius: BorderRadius.circular(GonkaRadius.sm),
                      border: Border.all(
                          color: GonkaColors.borderSubtle, width: 1),
                    ),
                    child: SelectableText(
                      hex,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: GonkaColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.commonClose),
              ),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: hex));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.walletDetailExportPkCopied)),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(l10n.commonCopy),
              ),
            ],
          );
        },
      );
    } finally {
      await DeviceSecurityService.disableSecureScreen();
    }
  }

  void _renameWallet(
      BuildContext context, WidgetRef ref, String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.walletDetailRenameDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: l10n.walletDetailRenameLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(walletsProvider.notifier).renameWallet(id, name);
                  Navigator.pop(ctx);
                }
              },
              child: Text(l10n.commonSave),
            ),
          ],
        );
      },
    );
  }

  void _deleteWallet(BuildContext context, WidgetRef ref, String id,
      String name, int totalWallets) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.walletDetailDelete),
          content: Text(l10n.walletDetailDeleteDialogBody(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: GonkaColors.error),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(walletsProvider.notifier).deleteWallet(id);
                if (totalWallets <= 1) {
                  context.go('/onboarding/create');
                } else {
                  context.go('/home');
                }
              },
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
  }
}

class _TxHistoryTile extends StatelessWidget {
  final TxHistoryItem tx;
  final String myAddress;

  const _TxHistoryTile({required this.tx, required this.myAddress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVesting = tx.type == TxType.vestingReward;
    final isCollateralDeposit = tx.type == TxType.collateralDeposit;
    final isCollateralWithdraw = tx.type == TxType.collateralWithdraw;
    final isCollateral = isCollateralDeposit || isCollateralWithdraw;
    final isGrant = tx.isGrant;
    final isReceive = tx.isReceive(myAddress);

    final IconData icon;
    final Color color;
    final String title;
    final String subtitle;

    final isUnjail = tx.isUnjail;
    final isVote = tx.isVote;

    final isContract = tx.isContract;
    final isContractWithdraw = tx.type == TxType.contractWithdraw;

    if (isContract) {
      final action = isContractWithdraw
          ? l10n.txTypeContractWithdraw
          : l10n.txTypeContractDeposit;
      icon = isContractWithdraw ? Icons.arrow_downward : Icons.rocket_launch;
      color = isContractWithdraw
          ? GonkaColors.txContractWithdraw
          : GonkaColors.txContract;
      title = action;
      final addr = tx.toAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    } else if (isVote) {
      final voteOption = VoteOption.fromString(tx.memo);
      icon = Icons.how_to_vote;
      color = GonkaColors.txVote;
      title = l10n.txTypeVote(
          voteOption != null ? _voteLabel(l10n, voteOption) : tx.memo);
      subtitle = tx.toAddress;
    } else if (isUnjail) {
      icon = Icons.lock_open;
      color = GonkaColors.txUnjail;
      title = l10n.txTypeUnjail;
      subtitle = _shortHash(tx.txhash);
    } else if (isGrant) {
      icon = Icons.vpn_key;
      color = GonkaColors.txGrant;
      title = l10n.txTypeGrant;
      final addr = tx.toAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    } else if (isCollateralDeposit) {
      icon = Icons.shield_outlined;
      color = GonkaColors.txCollateralDeposit;
      title = l10n.txTypeCollateralDeposit;
      subtitle = _shortHash(tx.txhash);
    } else if (isCollateralWithdraw) {
      icon = Icons.shield_outlined;
      color = GonkaColors.txCollateralWithdraw;
      title = l10n.txTypeCollateralWithdraw;
      subtitle = _shortHash(tx.txhash);
    } else if (isVesting) {
      icon = Icons.stars;
      color = GonkaColors.txVesting;
      title = tx.epochIndex != null
          ? l10n.txTypeEpochReward(tx.epochIndex!)
          : l10n.txTypeVestingReward;
      subtitle = _shortHash(tx.txhash);
    } else if (isReceive) {
      icon = Icons.arrow_downward;
      color = GonkaColors.txReceive;
      title = l10n.txTypeReceived;
      final addr = tx.fromAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    } else {
      icon = Icons.arrow_upward;
      color = GonkaColors.txSend;
      title = l10n.txTypeSent;
      final addr = tx.toAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            onTap: () => _showTxDetail(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(
                          color: color.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: GonkaColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: GonkaColors.textMuted)),
                        Text(_formatDate(l10n, tx.timestamp),
                            style: const TextStyle(
                                fontSize: 11,
                                color: GonkaColors.textMuted)),
                      ],
                    ),
                  ),
                  if (!(isGrant || isUnjail || isVote))
                    Text(
                      '${isContractWithdraw ? '+' : (isCollateral || isContract ? '-' : (isReceive ? '+' : '-'))}${formatGnk(tx.amountNgonka)} GNK',
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTxDetail(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isVesting = tx.type == TxType.vestingReward;
    final isCollateral = tx.isCollateral;
    final isGrant = tx.isGrant;
    final isUnjail = tx.isUnjail;
    final isVoteTx = tx.isVote;
    final isContractTx = tx.isContract;
    final isContractWithdrawTx = tx.type == TxType.contractWithdraw;
    final contractActionLabel = isContractWithdrawTx
        ? l10n.txTypeContractWithdraw
        : l10n.txTypeContractDeposit;

    final String sheetTitle;
    if (isContractTx) {
      sheetTitle = contractActionLabel;
    } else if (isVoteTx) {
      sheetTitle = l10n.commonOption;
    } else if (isUnjail) {
      sheetTitle = l10n.unjailTitle;
    } else if (isGrant) {
      sheetTitle = l10n.txTypeGrant;
    } else if (isVesting) {
      sheetTitle = l10n.txTypeVestingReward;
    } else if (isCollateral) {
      sheetTitle = tx.type == TxType.collateralDeposit
          ? l10n.txTypeCollateralDeposit
          : l10n.txTypeCollateralWithdraw;
    } else {
      sheetTitle = l10n.walletDetailTxHistory;
    }

    final statusText = tx.success ? l10n.commonSuccess : l10n.commonFailed;
    final amountText = '${formatGnk(tx.amountNgonka)} GNK';
    final heightText = tx.height.toString();
    final timeText = tx.timestamp.toLocal().toString();

    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sheetTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (isContractTx) ...[
              _detailRow(l10n.commonType, contractActionLabel),
              _detailRow(l10n.commonStatus, statusText),
              _detailRow(l10n.commonAmount, amountText),
              _detailRow(l10n.commonFrom, tx.fromAddress),
              _detailRow(l10n.commonContract, tx.toAddress),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ] else if (isVoteTx) ...[
              _detailRow(l10n.commonType, l10n.commonOption),
              _detailRow(l10n.commonStatus, statusText),
              _detailRow(l10n.commonProposal, tx.toAddress),
              _detailRow(
                  l10n.commonOption,
                  () {
                    final opt = VoteOption.fromString(tx.memo);
                    return opt != null ? _voteLabel(l10n, opt) : tx.memo;
                  }()),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ] else if (isUnjail) ...[
              _detailRow(l10n.commonType, l10n.txTypeUnjail),
              _detailRow(l10n.commonStatus, statusText),
              _detailRow(l10n.commonValidator, tx.fromAddress),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ] else if (isGrant) ...[
              _detailRow(l10n.commonType, l10n.txTypeGrant),
              _detailRow(l10n.commonStatus, statusText),
              _detailRow(l10n.commonGranter, tx.fromAddress),
              _detailRow(l10n.commonGrantee, tx.toAddress),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ] else if (isCollateral) ...[
              _detailRow(
                  l10n.commonType,
                  tx.type == TxType.collateralDeposit
                      ? l10n.txTypeCollateralDeposit
                      : l10n.txTypeCollateralWithdraw),
              _detailRow(l10n.commonStatus, statusText),
              _detailRow(l10n.commonAmount, amountText),
              _detailRow(l10n.commonAddress, tx.fromAddress),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ] else if (isVesting) ...[
              _detailRow(l10n.commonType, l10n.txTypeVestingReward),
              _detailRow(l10n.commonStatus, statusText),
              if (tx.epochIndex != null)
                _detailRow(l10n.commonEpoch, tx.epochIndex.toString()),
              _detailRow(l10n.commonAmount, amountText),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ] else ...[
              _detailRow(l10n.commonStatus, statusText),
              _detailRow(
                  l10n.commonType,
                  tx.isReceive(myAddress)
                      ? l10n.txTypeReceived
                      : l10n.txTypeSent),
              _detailRow(l10n.commonAmount, amountText),
              _detailRow(l10n.commonFrom, tx.fromAddress),
              _detailRow(l10n.commonTo, tx.toAddress),
              _detailRow(l10n.commonHeight, heightText),
              _detailRow(l10n.commonTime, timeText),
              if (tx.memo.isNotEmpty) _detailRow(l10n.commonMemo, tx.memo),
              _detailRow(l10n.commonHash, tx.txhash, isHash: true),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isHash = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(label,
                style: const TextStyle(
                    color: GonkaColors.textMuted,
                    fontWeight: FontWeight.w500,
                    fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: GonkaColors.textPrimary)),
          ),
          if (isHash) _CopyButton(value: value),
        ],
      ),
    );
  }

  String _shortHash(String hash) {
    if (hash.length <= 20) return hash;
    return '${hash.substring(0, 10)}...${hash.substring(hash.length - 6)}';
  }

  String _formatDate(AppLocalizations l10n, DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return l10n.txTimeJustNow;
    if (diff.inMinutes < 60) return l10n.txTimeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.txTimeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.txTimeDaysAgo(diff.inDays);

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
  }
}

class _CopyButton extends StatefulWidget {
  final String value;
  const _CopyButton({required this.value});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  void _onTap() {
    Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Icon(
          _copied ? Icons.check : Icons.copy,
          size: 16,
          color: _copied ? GonkaColors.success : GonkaColors.textMuted,
        ),
      ),
    );
  }
}
