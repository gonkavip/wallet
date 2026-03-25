import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/responsive_center.dart';

class SendResultScreen extends StatelessWidget {
  final bool success;
  final String txhash;
  final String error;

  const SendResultScreen({
    super.key,
    required this.success,
    this.txhash = '',
    this.error = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                success ? Icons.check_circle : Icons.error,
                size: 80,
                color: success ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                success ? 'Transaction Sent!' : 'Transaction Failed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (success && txhash.isNotEmpty) ...[
                Text(
                  'Transaction Hash',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: txhash));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hash copied')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            txhash,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12),
                          ),
                        ),
                        const Icon(Icons.copy, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
              if (!success && error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Done'),
                ),
              ),
              if (!success) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/send'),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
