import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:audioplayers/audio_cache.dart';

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class MyApp extends StatefulWidget {
  MyApp({this.cameras});

  final List<CameraDescription> cameras;

  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  static AudioCache player = new AudioCache();

  AnimationController animationController;
  QRReaderController controller;
  Animation<double> verticalPosition;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );

    animationController.addListener(() {
      this.setState(() {});
    });
    animationController.forward();
    verticalPosition = Tween<double>(begin: 0.0, end: 300.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear))
      ..addStatusListener((state) {
        if (state == AnimationStatus.completed) {
          animationController.reverse();
        } else if (state == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });

    // pick the first available camera
    onNewCameraSelected(widget.cameras[0]);
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final deviceRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'No camera selected',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Transform.scale(
        scale: controller.value.aspectRatio / deviceRatio,
        child: new AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: new QRReaderPreview(controller),
        ),
      );
    }
  }

  Future sendDetails() {
    return Future.delayed(Duration(seconds: 3));
  }

  void onCodeRead(dynamic value) {
    controller.stopScanning();
    const alarmAudioPath = "sound.mp3";
    player.play(alarmAudioPath);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
                child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width * .9,
              color: Colors.white,
              child: FutureBuilder(
                future: sendDetails(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return CircularProgressIndicator();
                      break;
                    case ConnectionState.none:
                      return CircularProgressIndicator();
                      break;
                    case ConnectionState.done:
                      return Container(
                        color: Colors.blue,
                        height: 100,
                        width: 100,
                        child: FlatButton(
                          onPressed: () {
                            controller.startScanning();
                            Navigator.of(context).pop();
                          },
                          color: Colors.blue,
                          child: Container(
                            height: 40,
                            width: 70,
                            child: Text("press me"),
                          ),
                        ),
                      );
                      break;
                    case ConnectionState.active:
                      return Container(
                        color: Colors.blue,
                        height: 100,
                        width: 100,
                        child: FlatButton(
                          onPressed: () {
                            controller.startScanning();
                            Navigator.of(context).pop();
                          },
                          color: Colors.white,
                          child: Container(
                            height: 40,
                            width: 70,
                            child: Text("press me"),
                          ),
                        ),
                      );
                      break;
                  }
                },
              ),
            )));
    // ... do something
    // wait 5 seconds then start scanning again.
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    print(widget.cameras);
    if (controller != null) {
      await controller.dispose();
    }
    controller = new QRReaderController(cameraDescription, ResolutionPreset.low,
        [CodeFormat.qr, CodeFormat.pdf417], onCodeRead);
    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on QRReaderException catch (e) {
      logError(e.code, e.description);
      showInSnackBar('Error: ${e.code}\n${e.description}');
    }

    if (mounted) {
      setState(() {});
      controller.startScanning();
    }
  }

  void showInSnackBar(String message) {}

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new Container(
          child: new Padding(
            padding: const EdgeInsets.all(0.0),
            child: new Center(
              child: _cameraPreviewWidget(),
            ),
          ),
        ),
        Center(
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: 250.0,
                width: 250.0,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 4.0)),
                ),
              ),
              Positioned(
                top: verticalPosition.value,
                child: Container(
                  width: 250.0,
                  height: 2.0,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
