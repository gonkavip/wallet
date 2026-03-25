import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/responsive_center.dart';

class MinersScreen extends StatelessWidget {
  const MinersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For Host'),
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
      body: ResponsiveCenter(child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Collateral'),
            subtitle: const Text('Manage your mining collateral'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/collateral'),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: const Text('Grant Permissions'),
            subtitle: const Text('Grant permissions to ML operational key'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/grant'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_open_outlined),
            title: const Text('Unjail'),
            subtitle: const Text('Unjail your validator'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/unjail'),
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote_outlined),
            title: const Text('Governance'),
            subtitle: const Text('Vote on proposals'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/miners/governance'),
          ),
          ListTile(
            leading: const Icon(Icons.track_changes_outlined),
            title: const Text('Tracker'),
            subtitle: const Text('Professional Dashboard'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://tracker.gonka.vip/'), mode: LaunchMode.externalApplication),
          ),
        ],
      )),
    );
  }
}
