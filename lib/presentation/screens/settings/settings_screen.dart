import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../state/providers/node_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNode = ref.watch(nodesProvider).activeNode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Node Settings'),
            subtitle: activeNode != null
                ? Text(
                    '${activeNode.label} (${activeNode.isHealthy ? '${activeNode.latencyMs}ms' : activeNode.isOnline ? 'not synced' : 'offline'})')
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/nodes'),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            subtitle: const Text('PIN & biometrics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/security'),
          ),
        ],
      ),
    );
  }
}
