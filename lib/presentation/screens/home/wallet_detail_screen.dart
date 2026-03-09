import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../data/models/balance_model.dart';
import '../../../core/transaction/msg_vote.dart';
import '../../../data/models/tx_history_model.dart';
import '../../../state/providers/wallet_provider.dart';
import '../../../state/providers/auth_provider.dart';
import '../../../state/providers/balance_provider.dart';
import '../../../state/providers/tx_history_provider.dart';
import '../../widgets/address_display.dart';
import '../../widgets/balance_card.dart';
import '../../../data/services/device_security_service.dart';

class WalletDetailScreen extends ConsumerStatefulWidget {
  final String walletId;

  const WalletDetailScreen({super.key, required this.walletId});

  @override
  ConsumerState<WalletDetailScreen> createState() =>
      _WalletDetailScreenState();
}

class _WalletDetailScreenState extends ConsumerState<WalletDetailScreen> {
  bool _useGnk = true;

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final wallet = wallets.where((w) => w.id == widget.walletId).firstOrNull;

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wallet')),
        body: const Center(child: Text('Wallet not found')),
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
                case 'rename':
                  _renameWallet(context, ref, wallet.id, wallet.name);
                case 'delete':
                  _deleteWallet(
                      context, ref, wallet.id, wallet.name, wallets.length);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                  value: 'seed', child: Text('Show Seed Phrase')),
              const PopupMenuItem(
                  value: 'rename', child: Text('Rename Wallet')),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete Wallet',
                    style: TextStyle(color: Colors.red.shade400)),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(balanceProvider.notifier).refresh();
          ref.invalidate(txHistoryProvider(wallet.address));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Failed to load balance: $e'),
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
                    label: const Text('Send'),
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
                    label: const Text('Receive'),
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
                label: const Text('For Host'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text('Transaction History',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            txHistoryAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No transactions yet',
                            style: TextStyle(color: Colors.grey[500])),
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
                  child: Text('Failed to load history',
                      style: TextStyle(color: Colors.grey[500])),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMnemonic(
      BuildContext context, WidgetRef ref, String walletId) async {
    final auth = ref.read(authServiceProvider);
    final storage = ref.read(secureStorageProvider);

    bool authenticated = false;
    final bioEnabled = await storage.isBiometricEnabled();
    if (bioEnabled) {
      authenticated = await auth.authenticateBiometric();
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
        title: const Text('Seed Phrase'),
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text('${i + 1}. ${words[i]}',
                    style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    await DeviceSecurityService.disableSecureScreen();
  }

  void _renameWallet(
      BuildContext context, WidgetRef ref, String id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Wallet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(walletsProvider.notifier).renameWallet(id, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteWallet(BuildContext context, WidgetRef ref, String id,
      String name, int totalWallets) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: Text(
          'Are you sure you want to delete "$name"?\n\n'
          'This will remove the wallet and its seed phrase from this device. '
          'Make sure you have backed up your seed phrase!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(walletsProvider.notifier).deleteWallet(id);
              if (totalWallets <= 1) {
                context.go('/onboarding/create');
              } else {
                context.go('/home');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TxHistoryTile extends StatelessWidget {
  final TxHistoryItem tx;
  final String myAddress;

  const _TxHistoryTile({required this.tx, required this.myAddress});

  @override
  Widget build(BuildContext context) {
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

    if (isVote) {
      final voteOption = VoteOption.fromString(tx.memo);
      icon = Icons.how_to_vote;
      color = Colors.blue;
      title = 'Vote: ${voteOption?.displayName ?? tx.memo}';
      subtitle = tx.toAddress; // "Proposal #N"
    } else if (isUnjail) {
      icon = Icons.lock_open;
      color = Colors.amber;
      title = 'Unjail';
      subtitle = _formatDate(tx.timestamp);
    } else if (isGrant) {
      icon = Icons.vpn_key;
      color = Colors.blueGrey;
      title = 'Grant Permissions';
      final addr = tx.toAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    } else if (isCollateralDeposit) {
      icon = Icons.shield_outlined;
      color = Colors.blue;
      title = 'Collateral Deposit';
      subtitle = _formatDate(tx.timestamp);
    } else if (isCollateralWithdraw) {
      icon = Icons.shield_outlined;
      color = Colors.teal;
      title = 'Collateral Withdraw';
      subtitle = _formatDate(tx.timestamp);
    } else if (isVesting) {
      icon = Icons.stars;
      color = Colors.cyan;
      title = tx.epochIndex != null
          ? 'Epoch ${tx.epochIndex} Reward'
          : 'Vesting Reward';
      subtitle = _formatDate(tx.timestamp);
    } else if (isReceive) {
      icon = Icons.arrow_downward;
      color = Colors.green;
      title = 'Received';
      final addr = tx.fromAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    } else {
      icon = Icons.arrow_upward;
      color = Colors.orange;
      title = 'Sent';
      final addr = tx.toAddress;
      subtitle = addr.length > 20
          ? '${addr.substring(0, 10)}...${addr.substring(addr.length - 6)}'
          : addr;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
            Text(_formatDate(tx.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        trailing: isGrant || isUnjail || isVote
            ? null
            : Text(
                '${isCollateral ? '' : (isReceive ? '+' : '-')}${formatGnk(tx.amountNgonka)} GNK',
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
        isThreeLine: true,
        dense: true,
        onTap: () => _showTxDetail(context),
      ),
    );
  }

  void _showTxDetail(BuildContext context) {
    final isVesting = tx.type == TxType.vestingReward;
    final isCollateral = tx.isCollateral;
    final isGrant = tx.isGrant;
    final isUnjail = tx.isUnjail;
    final isVoteTx = tx.isVote;

    final String sheetTitle;
    if (isVoteTx) {
      sheetTitle = 'Vote';
    } else if (isUnjail) {
      sheetTitle = 'Unjail Validator';
    } else if (isGrant) {
      sheetTitle = 'Grant Permissions';
    } else if (isVesting) {
      sheetTitle = 'Vesting Reward';
    } else if (isCollateral) {
      sheetTitle = tx.type == TxType.collateralDeposit
          ? 'Collateral Deposit'
          : 'Collateral Withdraw';
    } else {
      sheetTitle = 'Transaction Details';
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sheetTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (isVoteTx) ...[
              _detailRow('Type', 'Vote'),
              _detailRow('Status', tx.success ? 'Success' : 'Failed'),
              _detailRow('Proposal', tx.toAddress),
              _detailRow('Option', VoteOption.fromString(tx.memo)?.displayName ?? tx.memo),
              _detailRow('Height', tx.height.toString()),
              _detailRow('Time', tx.timestamp.toLocal().toString()),
              _detailRow('Hash', tx.txhash),
            ] else if (isUnjail) ...[
              _detailRow('Type', 'Unjail'),
              _detailRow('Status', tx.success ? 'Success' : 'Failed'),
              _detailRow('Validator', tx.fromAddress),
              _detailRow('Height', tx.height.toString()),
              _detailRow('Time', tx.timestamp.toLocal().toString()),
              _detailRow('Hash', tx.txhash),
            ] else if (isGrant) ...[
              _detailRow('Type', 'Grant Permissions'),
              _detailRow('Status', tx.success ? 'Success' : 'Failed'),
              _detailRow('Granter', tx.fromAddress),
              _detailRow('Grantee', tx.toAddress),
              _detailRow('Height', tx.height.toString()),
              _detailRow('Time', tx.timestamp.toLocal().toString()),
              _detailRow('Hash', tx.txhash),
            ] else if (isCollateral) ...[
              _detailRow('Type', tx.type == TxType.collateralDeposit
                  ? 'Collateral Deposit'
                  : 'Collateral Withdraw'),
              _detailRow('Status', tx.success ? 'Success' : 'Failed'),
              _detailRow('Amount', '${formatGnk(tx.amountNgonka)} GNK'),
              _detailRow('Address', tx.fromAddress),
              _detailRow('Height', tx.height.toString()),
              _detailRow('Time', tx.timestamp.toLocal().toString()),
              _detailRow('Hash', tx.txhash),
            ] else if (isVesting) ...[
              _detailRow('Type', 'Vesting Reward'),
              _detailRow('Status', tx.success ? 'Success' : 'Failed'),
              if (tx.epochIndex != null)
                _detailRow('Epoch', tx.epochIndex.toString()),
              _detailRow('Amount', '${formatGnk(tx.amountNgonka)} GNK'),
              _detailRow('Height', tx.height.toString()),
              _detailRow('Time', tx.timestamp.toLocal().toString()),
              _detailRow('Hash', tx.txhash),
            ] else ...[
              _detailRow('Status', tx.success ? 'Success' : 'Failed'),
              _detailRow(
                  'Type', tx.isReceive(myAddress) ? 'Received' : 'Sent'),
              _detailRow('Amount', '${formatGnk(tx.amountNgonka)} GNK'),
              _detailRow('From', tx.fromAddress),
              _detailRow('To', tx.toAddress),
              _detailRow('Height', tx.height.toString()),
              _detailRow('Time', tx.timestamp.toLocal().toString()),
              if (tx.memo.isNotEmpty) _detailRow('Memo', tx.memo),
              _detailRow('Hash', tx.txhash),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
  }
}
