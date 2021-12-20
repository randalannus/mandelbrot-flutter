import 'dart:typed_data';

import 'package:app1/model.dart';
import 'package:complex/complex.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

class SettingsProvider with ChangeNotifier {
  int _depth = 1;
  num _zoom = 1;
  Complex _center = Complex.zero;
  Resolution _resolution = Resolution.r1080p;

  int get depth => _depth;
  set depth(int d) {
    _depth = d;
    notifyListeners();
  }

  num get zoom => _zoom;
  set zoom(num z) {
    _zoom = z;
    notifyListeners();
  }

  Complex get center => _center;
  set center(Complex c) {
    _center = c;
    notifyListeners();
  }

  Resolution get resolution => _resolution;
  set resolution(Resolution r) {
    _resolution = r;
    notifyListeners();
  }
}

class MandelbrotImageProvider with ChangeNotifier {
  ui.Image? _image;
  //Uint8List? _bytes;

  ui.Image? get image => _image;
  set image(ui.Image? img) {
    _image = img;
    notifyListeners();
  }

  /*Uint8List? get bytes => _bytes;
  void update(ui.Image? image, Uint8List? bytes) {
    _image = image;
    _bytes = bytes;
    notifyListeners();
  }*/
}
