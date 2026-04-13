import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/design_tokens.dart';
import '../../../data/models/node_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers/node_provider.dart';
import '../../widgets/responsive_center.dart';

class NodeSettingsScreen extends ConsumerStatefulWidget {
  const NodeSettingsScreen({super.key});

  @override
  ConsumerState<NodeSettingsScreen> createState() => _NodeSettingsScreenState();
}

class _NodeSettingsScreenState extends ConsumerState<NodeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nodeState = ref.watch(nodesProvider);
    final nodes = nodeState.nodes;
    final activeNode = nodeState.activeNode;
    final isScanning = nodeState.isScanning || nodes.any((n) => n.isChecking);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nodeSettingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/settings');
            }
          },
        ),
        actions: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.nodeSettingsRefresh,
              onPressed: () =>
                  ref.read(nodesProvider.notifier).triggerHealthCheck(),
            ),
        ],
      ),
      body: ResponsiveCenter(child: ListView(
        padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.paddingOf(context).bottom),
        children: [
          ...nodes.asMap().entries.map((entry) {
            final i = entry.key;
            final node = entry.value;
            final isActive = activeNode?.url == node.url;

            return ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: node.isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: node.isHealthy
                                ? GonkaColors.success
                                : node.isOnline
                                    ? GonkaColors.warning
                                    : GonkaColors.error,
                            boxShadow: [
                              BoxShadow(
                                color: (node.isHealthy
                                        ? GonkaColors.success
                                        : node.isOnline
                                            ? GonkaColors.warning
                                            : GonkaColors.error)
                                    .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              title: Text(node.label),
              subtitle: Text(
                node.isChecking
                    ? '${node.url}\n${l10n.nodeStatusChecking}'
                    : '${node.url}\n${node.isHealthy ? l10n.nodeStatusLatency(node.latencyMs) : node.isOnline ? (node.isSyncing ? l10n.nodeStatusSyncing : l10n.nodeStatusNotSynced) : l10n.nodeStatusOffline}',
              ),
              isThreeLine: true,
              selected: isActive,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isActive)
                    Chip(label: Text(l10n.nodeActive)),
                  if (!isActive)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () =>
                          ref.read(nodesProvider.notifier).setActive(i),
                    ),
                  if (nodes.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(nodesProvider.notifier).removeNode(i),
                    ),
                ],
              ),
            );
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.nodeAdd),
            onTap: _addNode,
          ),
        ],
      )),
    );
  }

  void _addNode() {
    final urlController = TextEditingController();
    final labelController = TextEditingController();
    bool proxyMode = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final l10n = AppLocalizations.of(ctx);
          return AlertDialog(
            title: Text(l10n.nodeAdd),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: l10n.nodeUrlLabel,
                    hintText: l10n.nodeUrlHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelController,
                  decoration: InputDecoration(
                    labelText: l10n.nodeLabelLabel,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(l10n.nodeProxyMode),
                  subtitle: Text(l10n.nodeProxyModeSubtitle),
                  value: proxyMode,
                  onChanged: (v) => setDialogState(() => proxyMode = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  final url = urlController.text.trim();
                  if (url.isEmpty) return;
                  ref.read(nodesProvider.notifier).addNode(NodeModel(
                        url: url,
                        label: labelController.text.trim().isEmpty
                            ? l10n.nodeDefaultLabel
                            : labelController.text.trim(),
                        proxyMode: proxyMode,
                      ));
                  Navigator.pop(ctx);
                },
                child: Text(l10n.nodeAddButton),
              ),
            ],
          );
        },
      ),
    );
  }

}
