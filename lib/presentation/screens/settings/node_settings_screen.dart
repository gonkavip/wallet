import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/node_model.dart';
import '../../../state/providers/node_provider.dart';

class NodeSettingsScreen extends ConsumerStatefulWidget {
  const NodeSettingsScreen({super.key});

  @override
  ConsumerState<NodeSettingsScreen> createState() => _NodeSettingsScreenState();
}

class _NodeSettingsScreenState extends ConsumerState<NodeSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final nodeState = ref.watch(nodesProvider);
    final nodes = nodeState.nodes;
    final activeNode = nodeState.activeNode;
    final isScanning = nodeState.isScanning || nodes.any((n) => n.isChecking);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Node Settings'),
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
              tooltip: 'Refresh Nodes',
              onPressed: () =>
                  ref.read(nodesProvider.notifier).triggerHealthCheck(),
            ),
        ],
      ),
      body: ListView(
        children: [
          ...nodes.asMap().entries.map((entry) {
            final i = entry.key;
            final node = entry.value;
            final isActive = activeNode?.url == node.url;

            return ListTile(
              leading: node.isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.circle,
                      size: 12,
                      color: node.isHealthy
                          ? Colors.green
                          : node.isOnline
                              ? Colors.orange
                              : Colors.red,
                    ),
              title: Text(node.label),
              subtitle: Text(
                node.isChecking
                    ? '${node.url}\nChecking...'
                    : '${node.url}\n${node.isHealthy ? '${node.latencyMs}ms' : node.isOnline ? (node.isSyncing ? 'Syncing...' : 'Not synced') : 'Offline'}',
              ),
              isThreeLine: true,
              selected: isActive,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isActive)
                    const Chip(label: Text('Active')),
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
            title: const Text('Add Node'),
            onTap: _addNode,
          ),
        ],
      ),
    );
  }

  void _addNode() {
    final urlController = TextEditingController();
    final labelController = TextEditingController();
    bool proxyMode = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Node'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Node URL',
                  hintText: 'https://node.example.com:8000',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Proxy Mode'),
                subtitle: const Text('/chain-api/ + /chain-rpc/'),
                value: proxyMode,
                onChanged: (v) => setDialogState(() => proxyMode = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final url = urlController.text.trim();
                if (url.isEmpty) return;
                ref.read(nodesProvider.notifier).addNode(NodeModel(
                      url: url,
                      label: labelController.text.trim().isEmpty
                          ? 'Custom Node'
                          : labelController.text.trim(),
                      proxyMode: proxyMode,
                    ));
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

}
