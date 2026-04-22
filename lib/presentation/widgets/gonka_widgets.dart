import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';

class WalletCardDotTexture extends CustomPainter {
  static const double _spacing = 6.0;
  static const double _dotRadius = 0.9;
  static const Color _dotColor = Color(0xFFBFDBFE);
  static const double _baseAlpha = 0.14;
  static const double _edgeAlpha = 0.04;

  const WalletCardDotTexture();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxDist = Offset(cx, cy).distance;

    for (double y = _spacing / 2; y < size.height; y += _spacing) {
      for (double x = _spacing / 2; x < size.width; x += _spacing) {
        final dist = (Offset(x - cx, y - cy)).distance;
        final t = (dist / maxDist).clamp(0.0, 1.0);
        final alpha = _baseAlpha + (_edgeAlpha - _baseAlpha) * t;
        paint.color = _dotColor.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), _dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WalletCardDotTexture oldDelegate) => false;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool glow;
  final Color? background;
  final double? radius;
  final BorderSide? borderSide;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.glow = false,
    this.background,
    this.radius,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? GonkaRadius.lg;
    final border = borderSide ??
        const BorderSide(color: GonkaColors.borderSubtle, width: 1);

    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: background ?? GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(r),
        border: Border.fromBorderSide(border),
        boxShadow: glow ? GonkaShadows.glowBlue : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: GonkaColors.glowBlue,
            highlightColor: GonkaColors.glowBlue,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    return container;
  }
}

class GlowBackground extends StatelessWidget {
  final Widget child;
  final double size;
  final Color color;

  const GlowBackground({
    super.key,
    required this.child,
    this.size = 280,
    this.color = GonkaColors.glowBlue,
  });

  @override
  Widget build(BuildContext context) {
    final base = HSLColor.fromColor(color);
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  base.withAlpha(0.18).toColor(),
                  base.withAlpha(0.10).toColor(),
                  base.withAlpha(0.04).toColor(),
                  base.withAlpha(0.0).toColor(),
                ],
                stops: const [0.0, 0.4, 0.75, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.gradient = GonkaGradients.brandText,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = (style ?? const TextStyle()).copyWith(color: Colors.white);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: baseStyle, textAlign: textAlign),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GonkaRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class ResultIcon extends StatelessWidget {
  final bool success;
  final double size;

  const ResultIcon({super.key, required this.success, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final color = success ? GonkaColors.success : GonkaColors.error;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        success ? Icons.check_rounded : Icons.close_rounded,
        color: color,
        size: size * 0.55,
      ),
    );
  }
}

class TxHashDisplay extends StatelessWidget {
  final String hash;
  final String? label;

  const TxHashDisplay({
    super.key,
    required this.hash,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GonkaColors.bgCard,
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(color: GonkaColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? l10n.widgetTxHash,
            style: const TextStyle(
              color: GonkaColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: hash));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.widgetHashCopied),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    hash,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: GonkaColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse('https://tracker.gonka.vip/tx/$hash'),
                  mode: LaunchMode.externalApplication,
                ),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: GonkaColors.accentBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum InfoBannerVariant { info, warning, error, success }

class InfoBanner extends StatelessWidget {
  final String message;
  final String? title;
  final InfoBannerVariant variant;
  final IconData? icon;

  const InfoBanner({
    super.key,
    required this.message,
    this.title,
    this.variant = InfoBannerVariant.info,
    this.icon,
  });

  Color get _color {
    switch (variant) {
      case InfoBannerVariant.info:
        return GonkaColors.info;
      case InfoBannerVariant.warning:
        return GonkaColors.warning;
      case InfoBannerVariant.error:
        return GonkaColors.error;
      case InfoBannerVariant.success:
        return GonkaColors.success;
    }
  }

  IconData get _icon {
    if (icon != null) return icon!;
    switch (variant) {
      case InfoBannerVariant.info:
        return Icons.info_outline_rounded;
      case InfoBannerVariant.warning:
        return Icons.warning_amber_rounded;
      case InfoBannerVariant.error:
        return Icons.error_outline_rounded;
      case InfoBannerVariant.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(GonkaRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    color: GonkaColors.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
