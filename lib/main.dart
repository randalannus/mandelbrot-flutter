import 'package:app1/Mandelbrot.dart';
import 'package:app1/model.dart';
import 'package:app1/providers.dart';
import 'package:complex/complex.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider()),
        ChangeNotifierProvider<MandelbrotImageProvider>(
            create: (_) => MandelbrotImageProvider())
      ],
      child: MaterialApp(
        title: 'Mandelbrot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Mandelbrot renderer"),
        ),
        body: Row(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return SizedBox(
                    width: constraints.widthConstraints().maxWidth,
                    height: constraints.heightConstraints().maxHeight,
                    child: MandelbrotViewer());
              }),
            ),
            const SideMenu()
          ],
        ));
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 10, right: 20, top: 20, bottom: 20),
      child: Form(
        child: Column(
          children: [
            TextField(
              controller: MandelbrotField.depth.controller,
              decoration: const InputDecoration(helperText: "Depth"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: MandelbrotField.xCoord.controller,
              decoration: const InputDecoration(helperText: "X"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: MandelbrotField.yCoord.controller,
              decoration: const InputDecoration(helperText: "Y"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: MandelbrotField.zoom.controller,
              decoration: const InputDecoration(helperText: "Zoom"),
            ),
            const SizedBox(height: 10),
            Consumer<SettingsProvider>(
              builder: (context, settings, _) => ResolutionPicker(
                onChanged: (res) => settings.resolution = res,
                selectedRes: settings.resolution,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onRenderPressed(context),
              child: const Text("Render"),
            )
          ],
        ),
      ),
    );
  }
}

void onRenderPressed(BuildContext context) {
  final settings = Provider.of<SettingsProvider>(context, listen: false);
  Provider.of<SettingsProvider>(context, listen: false)
    ..depth = int.parse(MandelbrotField.depth.controller.text)
    ..center = Complex(double.parse(MandelbrotField.xCoord.controller.text),
        double.parse(MandelbrotField.yCoord.controller.text))
    ..zoom = num.parse(MandelbrotField.zoom.controller.text);

  makeMandelbrotImage(
          settings.resolution, settings.depth, settings.center, settings.zoom)
      .then((image) =>
          Provider.of<MandelbrotImageProvider>(context, listen: false).image =
              image);
}

class ResolutionPicker extends StatelessWidget {
  final void Function(Resolution res) onChanged;
  final Resolution selectedRes;

  const ResolutionPicker(
      {required this.onChanged, required this.selectedRes, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var res in <Resolution>[
      Resolution.r360p,
      Resolution.r720p,
      Resolution.r1080p,
      Resolution.r4k
    ]) {
      ButtonStyle style;
      if (selectedRes == res) {
        style = OutlinedButton.styleFrom(
            backgroundColor: Colors.blue,
            primary: Colors.white,
            animationDuration: Duration.zero);
      } else {
        style = OutlinedButton.styleFrom(animationDuration: Duration.zero);
      }

      children.add(OutlinedButton(
          onPressed: () => onChanged(res),
          child: Text(res.name),
          style: style));
    }

    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      spacing: 5,
      runSpacing: 5,
      children: children,
    );
  }
}
