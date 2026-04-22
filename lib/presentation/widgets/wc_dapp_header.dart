import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

class WcDappHeader extends StatelessWidget {
  final String name;
  final String? url;
  final String? iconUrl;
  final String? description;

  const WcDappHeader({
    super.key,
    required this.name,
    this.url,
    this.iconUrl,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(color: GonkaColors.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(GonkaRadius.sm),
            child: iconUrl != null && iconUrl!.isNotEmpty
                ? Image.network(
                    iconUrl!,
                    width: 48,
                    height: 48,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  )
                : _fallbackIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  style: const TextStyle(
                    color: GonkaColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (url != null && url!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    url!,
                    style: const TextStyle(
                      color: GonkaColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: const TextStyle(
                      color: GonkaColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() => Container(
        width: 48,
        height: 48,
        color: GonkaColors.bgSecondary,
        child: const Icon(
          Icons.apps,
          color: GonkaColors.textMuted,
        ),
      );
}
