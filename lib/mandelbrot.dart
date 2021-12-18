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
  const MandelbrotViewer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return Consumer<MandelbrotImageProvider>(
        builder: (context, imageProvider, _) {
      if (imageProvider.bytes == null) {
        return const Center(child: Text("Loading"));
      }
      final img = imageUtil.decodeImage(imageProvider.bytes!);
      return InteractiveViewer(child: Image);
    });
  }
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

class MandelbrotPainter extends CustomPainter {
  final ui.Image image;

  MandelbrotPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(MandelbrotPainter oldDelegate) => true;
}

Future<Uint8List> makeMandelbrotImage(
    Resolution resolution, int depth, Complex center, num zoom) async {
  final c = Completer<ui.Image>();
  final pixels = await calcMandelbrotPixels(resolution, depth, center, zoom);
  /*
  ui.decodeImageFromPixels(
    pixels.buffer.asUint8List(),
    resolution.width,
    resolution.height,
    ui.PixelFormat.rgba8888,
    c.complete,
  );*/
  return pixels.buffer.asUint8List();
}

Future<Int32List> calcMandelbrotPixels(
    Resolution resolution, int depth, Complex center, num zoom) async {
  await Future.delayed(const Duration(milliseconds: 100));
  final width = resolution.width;
  final height = resolution.height;
  final gradient = MandelbrotGradient();
  final pixels = Int32List(width * height);

  final ratio = width / height;
  final lft = -2 / zoom + center.real;
  final rt = 1 / zoom + center.real;
  final bot = (-2 / zoom + center.imaginary) / ratio;
  final up = (2 / zoom + center.imaginary) / ratio;

  for (int x = 0; x < width; x += 1) {
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
  return pixels;
}

int calculatePoint(Complex point, int depth) {
  if (point.abs() >= 2) return 0;
  if (point == Complex.zero) return -1;

  var z = point;
  var iterations = 0;
  while (z.abs() < 2 && iterations < depth) {
    z = z.pow(2) + point;
    iterations++;
  }
  return iterations == depth ? -1 : iterations;
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
