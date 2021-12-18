import 'package:flutter/cupertino.dart';

class MandelbrotField {
  static final depth = MandelbrotField._make("Depth", 5);
  static final xCoord = MandelbrotField._make("Y", 0);
  static final yCoord = MandelbrotField._make("X", 0);
  static final zoom = MandelbrotField._make("Zoom", 1.0);
  static final resolution =
      MandelbrotField._make("Resolution", Resolution.r720p);

  final String name;
  final dynamic defaultValue;
  final TextEditingController controller = TextEditingController();

  MandelbrotField._make(this.name, this.defaultValue) {
    controller.text = defaultValue.toString();
  }
}

class Resolution {
  static final r4k = Resolution._make("4K", 3840, 2160);
  static final r1080p = Resolution._make("1080p", 1920, 1080);
  static final r720p = Resolution._make("720p", 1280, 720);
  static final r360p = Resolution._make("360p", 640, 360);

  final String name;
  final int width;
  final int height;

  Resolution._make(this.name, this.width, this.height);

  @override
  String toString() {
    return name;
  }
}
