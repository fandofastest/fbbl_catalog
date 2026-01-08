import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;

// Run with: dart run tool/generate_placeholders.dart
// Generates PNG placeholders for products lacking an image and updates assets/data/products.json

int _hash(String s) => s.codeUnits.fold<int>(0, (p, c) => (p * 31 + c) & 0x7fffffff);

img.ColorRgb8 _colorFromName(String name) {
  final h = _hash(name);
  // Create a soft color range
  final r = 150 + (h % 100);
  final g = 120 + ((h >> 5) % 120);
  final b = 120 + ((h >> 10) % 120);
  return img.ColorRgb8(r, g, b);
}

img.Image _generatePlaceholder(String name, {int width = 800, int height = 500}) {
  final base = img.Image(width: width, height: height);
  final baseColor = _colorFromName(name);
  final darker = img.ColorRgb8(
    (baseColor.r * 0.8).toInt(),
    (baseColor.g * 0.8).toInt(),
    (baseColor.b * 0.8).toInt(),
  );

  // Vertical gradient
  for (int y = 0; y < height; y++) {
    final t = y / (height - 1);
    final r = (baseColor.r * (1 - t) + darker.r * t).toInt();
    final g = (baseColor.g * (1 - t) + darker.g * t).toInt();
    final b = (baseColor.b * (1 - t) + darker.b * t).toInt();
    final rowColor = img.ColorRgb8(r, g, b);
    for (int x = 0; x < width; x++) {
      base.setPixelRgb(x, y, rowColor.r, rowColor.g, rowColor.b);
    }
  }

  // Simple emblem: centered circle
  final cx = width ~/ 2;
  final cy = height ~/ 2;
  final radius = (height * 0.22).toInt();
  img.drawCircle(base, x: cx, y: cy, radius: radius, color: img.ColorRgba8(255, 255, 255, 180));

  // Inner circle
  img.drawCircle(base, x: cx, y: cy, radius: (radius * 0.6).toInt(), color: img.ColorRgba8(255, 255, 255, 220));

  return base;
}

Future<void> main() async {
  final projectDir = Directory.current.path;
  final dataPath = '$projectDir/assets/data/products.json';
  final imagesDirPath = '$projectDir/assets/images';

  final dataFile = File(dataPath);
  if (!await dataFile.exists()) {
    stderr.writeln('Could not find products.json at $dataPath');
    exit(1);
  }

  final imagesDir = Directory(imagesDirPath);
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final raw = await dataFile.readAsString();
  final List<dynamic> list = jsonDecode(raw) as List<dynamic>;

  int generated = 0;
  for (final item in list) {
    if (item is! Map<String, dynamic>) continue;
    final id = item['id'];
    final name = (item['name'] ?? '').toString();
    var image = (item['image'] ?? '').toString();
    if (image.isEmpty) {
      final filename = 'product_${id ?? _hash(name)}.png';
      final outPath = '$imagesDirPath/$filename';
      final placeholder = _generatePlaceholder(name);
      final bytes = img.encodePng(placeholder);
      await File(outPath).writeAsBytes(bytes);
      item['image'] = filename;
      generated++;
    }
  }

  final encoder = const JsonEncoder.withIndent('  ');
  await dataFile.writeAsString(encoder.convert(list));

  stdout.writeln('Generated $generated placeholder image(s).');
  stdout.writeln('Done.');
}
