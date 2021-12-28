import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:app1/model.dart';
import 'package:app1/providers.dart';
import 'package:complex/complex.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageUtil;
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

class MandelbrotViewer extends StatelessWidget {
  static const maxScale = 4.0;
  static const minScale = 0.4;
  final controller = TransformationController(Matrix4.diagonal3Values(1, 1, 1));

  MandelbrotViewer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MandelbrotImageProvider>(
        builder: (context, imageProvider, _) {
      if (imageProvider.image == null) {
        return const Center(child: Text("No image"));
      }
      final image = imageProvider.image!;
      return FutureBuilder<Uint8List>(
          future: imageToBytes(image),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Failed to generate image"),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text("Loading image"),
              );
            }
            final bytes = snapshot.data!;
            return _interactiveViewer(bytes);
          });
    });
  }

  Widget _interactiveViewer(Uint8List bytes) {
    return LayoutBuilder(builder: (context, constraints) {
      final horizontal = constraints.maxWidth / minScale - 100;
      final vertical = constraints.maxHeight / minScale - 100;
      return InteractiveViewer(
        boundaryMargin:
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        minScale: minScale,
        maxScale: maxScale,
        transformationController: controller,
        child: Image.memory(bytes),
      );
    });
  }
}

Future<Uint8List> imageToBytes(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw Exception("Failed to decode image to bytes");
  }
  return byteData.buffer.asUint8List();
}

void onDoubleTap(BuildContext context, TapDownDetails details) {
  final settingsProvider =
      Provider.of<SettingsProvider>(context, listen: false);
}

Complex positionToPoint(
    int x, int y, int width, int height, Complex center, double zoom) {
  final ratio = width / height;
  final lft = -2 / zoom + center.real;
  final rt = 1 / zoom + center.real;
  final bot = (-2 / zoom + center.imaginary) / ratio;
  final up = (2 / zoom + center.imaginary) / ratio;

  final a = (rt - lft) * x / width + lft;
  final b = (up - bot) * y / height + bot;
  return Complex(a, b);
}

@Deprecated("Use flutter Image to render mandelbrot instead.")
class MandelbrotPainter extends CustomPainter {
  final ui.Image image;

  MandelbrotPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    //canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
    canvas.drawImage(
        image,
        Offset(
            (size.width - image.width) / 2, (size.height - image.height) / 2),
        paint);
  }

  @override
  bool shouldRepaint(MandelbrotPainter oldDelegate) => false;
}

Future<ui.Image> makeMandelbrotImage(
    Resolution resolution, int depth, Complex center, num zoom) async {
  final c = Completer<ui.Image>();

  Stopwatch stopwatch = Stopwatch()..start();
  final pixels = await calcMandelbrotPixels(resolution, depth, center, zoom);
  print('Rendered in ${stopwatch.elapsed}');

  ui.decodeImageFromPixels(
    pixels.buffer.asUint8List(),
    resolution.width,
    resolution.height,
    ui.PixelFormat.rgba8888,
    c.complete,
  );
  return c.future;
  //return pixels.buffer.asUint8List();
}

Future<Int32List> calcMandelbrotPixels(
    Resolution resolution, int depth, Complex center, num zoom) async {
  final width = resolution.width;
  final height = resolution.height;
  final gradient = MandelbrotGradient();
  final pixels = Int32List(width * height);

  final ratio = width / height;
  final lft = -2 / zoom + center.real;
  final rt = 1 / zoom + center.real;
  final bot = (-2 / zoom + center.imaginary) / ratio;
  final up = (2 / zoom + center.imaginary) / ratio;

  final futures = <Future>[];

  for (int x = 0; x < width; x += 1) {
    Future calculateLine() async {
      await Future.delayed(Duration.zero);
      for (int y = 0; y < height; y += 1) {
        final a = (rt - lft) * x / width + lft;
        final b = (up - bot) * y / height + bot;
        final iterations = calculatePoint(Complex(a, b), depth);
        final color = iterations == -1
            ? Colors.black.value
            : gradient.at(iterations % 20 / 20);
        pixels[x + y * width] = color;
      }
    }

    futures.add(calculateLine());
  }
  await Future.wait(futures);
  return pixels;
}

int calculatePoint(Complex point, int depth) {
  var z = Complex.zero;
  var iterations = -1;
  while (distanceSquared(z) < 4 && iterations < depth) {
    z = z * z + point;
    iterations++;
  }
  return iterations == depth ? -1 : iterations;
}

double distanceSquared(Complex z) {
  return (z.real * z.real) + (z.imaginary * z.imaginary);
}

class MandelbrotGradient {
  final colors = <Color>[
    Colors.purple,
    Colors.blue[900]!,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red
  ];

  int at(double t) {
    final scaledTime = t * (colors.length - 1);
    final oldColor = colors[scaledTime.toInt()];
    final newColor = colors[min(scaledTime.toInt() + 1, colors.length - 1)];
    final newT = scaledTime - scaledTime.round();
    return Color.lerp(oldColor, newColor, newT)!.value;
  }
}
