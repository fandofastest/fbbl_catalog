import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductImage extends StatelessWidget {
  final String? assetName; // e.g., 'product_1.jpg'
  final String fallbackText; // initials/title
  final String? category;
  final int? seed; // stable seed for per-product unique placeholder
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.assetName,
    required this.fallbackText,
    this.category,
    this.seed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  int _stableSeed() {
    if (seed != null) return seed!;
    var h = 0;
    for (final c in fallbackText.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    for (final c in (category ?? '').codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final initials = fallbackText.isNotEmpty
        ? fallbackText
            .split(' ')
            .where((s) => s.isNotEmpty)
            .take(2)
            .map((s) => s[0].toUpperCase())
            .join()
        : '?';

    final seedValue = _stableSeed();

    final image = (assetName != null && assetName!.isNotEmpty)
        ? (assetName!.startsWith('http://') || assetName!.startsWith('https://'))
            ? Image.network(
                assetName!,
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (c, e, st) => _NetworkOrSvgPlaceholder(
                  initials: initials,
                  category: category,
                  seed: seedValue,
                  width: width,
                  height: height,
                  fit: fit,
                ),
              )
            : Image.asset(
                'assets/images/$assetName',
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (c, e, st) => _NetworkOrSvgPlaceholder(
                  initials: initials,
                  category: category,
                  seed: seedValue,
                  width: width,
                  height: height,
                  fit: fit,
                ),
              )
        : _NetworkOrSvgPlaceholder(
            initials: initials,
            category: category,
            seed: seedValue,
            width: width,
            height: height,
            fit: fit,
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius ?? BorderRadius.zero, child: image);
  }
}

class _NetworkOrSvgPlaceholder extends StatelessWidget {
  final String initials;
  final String? category;
  final int seed;
  final double? width;
  final double? height;
  final BoxFit fit;
  const _NetworkOrSvgPlaceholder({
    required this.initials,
    required this.category,
    required this.seed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  String _keyword() {
    final c = (category ?? '').toLowerCase();
    if (c.contains('beverage') || c.contains('drink')) return 'beverage,drink,juice,soda,bottle,glass';
    if (c.contains('food') || c.contains('snack') || c.contains('grocery')) return 'food,snack,cookies,crisps,groceries';
    return 'product,packaging,retail';
  }

  @override
  Widget build(BuildContext context) {
    final kw = Uri.encodeComponent(_keyword());
    final w = (width ?? 320).round();
    final h = (height ?? 180).round();
    final url = 'https://source.unsplash.com/${w}x$h/?$kw&sig=$seed';
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (c, e, st) => _GeneratedPlaceholder(
        initials: initials,
        category: category,
        seed: seed,
        width: width,
        height: height,
      ),
    );
  }
}

class _GeneratedPlaceholder extends StatelessWidget {
  final String initials;
  final String? category;
  final int seed;
  final double? width;
  final double? height;
  const _GeneratedPlaceholder({
    required this.initials,
    required this.category,
    required this.seed,
    this.width,
    this.height,
  });

  String _hex(Color c) {
    final v = c.value & 0xFFFFFF;
    return v.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  String _generateSvg(BuildContext context) {
    final theme = Theme.of(context);
    final c = (category ?? '').toLowerCase();

    // Palette by category
    Color c1;
    Color c2;
    Color c3;
    String symbol;
    if (c.contains('beverage') || c.contains('drink')) {
      c1 = theme.colorScheme.primaryContainer;
      c2 = theme.colorScheme.primary;
      c3 = theme.colorScheme.surface;
      symbol = 'B';
    } else if (c.contains('food') || c.contains('snack') || c.contains('grocery')) {
      c1 = theme.colorScheme.tertiaryContainer;
      c2 = theme.colorScheme.tertiary;
      c3 = theme.colorScheme.surface;
      symbol = 'F';
    } else {
      c1 = theme.colorScheme.secondaryContainer;
      c2 = theme.colorScheme.secondary;
      c3 = theme.colorScheme.surface;
      symbol = 'P';
    }

    // Deterministic geometry from seed
    final s = seed;
    final r1 = 18 + (s % 18);
    final r2 = 16 + ((s >> 3) % 20);
    final x1 = 30 + ((s >> 6) % 40);
    final y1 = 26 + ((s >> 9) % 44);
    final x2 = 70 + ((s >> 12) % 36);
    final y2 = 70 + ((s >> 15) % 32);
    final angle = (s % 360);

    final h1 = _hex(c1);
    final h2 = _hex(c2);
    final h3 = _hex(c3);

    // NOTE: Keep it simple and fast: shapes + soft gradient + label.
    return '''<svg xmlns="http://www.w3.org/2000/svg" width="320" height="180" viewBox="0 0 320 180">
  <defs>
    <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#$h1" stop-opacity="1" />
      <stop offset="55%" stop-color="#$h2" stop-opacity="0.35" />
      <stop offset="100%" stop-color="#$h3" stop-opacity="0.20" />
    </linearGradient>
  </defs>
  <rect width="320" height="180" rx="18" fill="url(#g)" />
  <g opacity="0.55" transform="rotate($angle 160 90)">
    <circle cx="$x1" cy="$y1" r="$r1" fill="#$h2" fill-opacity="0.25" />
    <circle cx="$x2" cy="$y2" r="$r2" fill="#$h1" fill-opacity="0.22" />
    <rect x="220" y="18" width="110" height="56" rx="18" fill="#$h2" fill-opacity="0.18" />
  </g>
  <text x="18" y="36" font-family="Inter, Arial" font-size="14" font-weight="700" fill="#111" fill-opacity="0.55">$symbol</text>
  <text x="160" y="104" text-anchor="middle" font-family="Inter, Arial" font-size="28" font-weight="800" letter-spacing="2" fill="#111" fill-opacity="0.55">$initials</text>
</svg>''';
  }

  @override
  Widget build(BuildContext context) {
    final svg = _generateSvg(context);
    return SvgPicture.string(
      svg,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
