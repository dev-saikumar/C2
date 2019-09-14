import 'package:fast_qr_reader_view/fast_qr_reader_view.dart';
import 'package:flutter/material.dart';
import './qrscanner.dart';
import './sharedPreference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras;
Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on QRReaderException catch (_) {}
  runApp(Screen());
}

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomesScreen());
  }
}

class HomesScreen extends StatefulWidget {
  @override
  _HomesScreenState createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> {
  final TextEditingController textEditingController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final pageController = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.pink[100],
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.edit, color: Colors.black.withOpacity(.65)),
            onPressed: () => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => SharedPreferencesBuilder(
                    pref: "storedapi",
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        textEditingController.text = snapshot.data;
                      }
                      return AlertDialog(
                        title: Text("Edit API"),
                        content: TextField(
                          controller: textEditingController,
                          decoration: InputDecoration(
                              labelText: "API here",
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              )),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("cancel",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.65))),
                            splashColor: Colors.pink[50],
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          FlatButton(
                              child: Text(
                                "Change",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.65)),
                              ),
                              color: Colors.pink[100],
                              splashColor: Colors.pink[50],
                              onPressed: () {
                                if (textEditingController.text.isNotEmpty) {
                                  SharedPreferences.getInstance().then((value) {
                                    value.setString("storedapi",
                                        textEditingController.text);
                                    Navigator.of(context).pop();
                                  });
                                } else
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text("Sorry API Cant be empty"),
                                  ));
                              })
                        ],
                      );
                    })),
            backgroundColor: Colors.pink[100]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        appBar: AppBar(
          title: Text(
            "Cuboids Club",
            style: TextStyle(color: Colors.black.withOpacity(.65)),
          ),
          backgroundColor: Colors.pink[100],
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyApp(
                            cameras: cameras,
                          ))),
            )
          ],
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.black38,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.pink[100],
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedFontSize: 17,
          onTap: (val) {
            setState(() {
              index = val;
              pageController.jumpToPage(val);
            });
          },
          currentIndex: index,
          iconSize: 27,
          items: [
            BottomNavigationBarItem(
                title: Text("event"),
                icon: Icon(Icons.event_note),
                activeIcon: Icon(Icons.event_available)),
            BottomNavigationBarItem(
                title: Text("stats"), icon: Icon(Icons.equalizer)),
            BottomNavigationBarItem(
                title: Text("QrScanner"), icon: Icon(Icons.center_focus_strong))
          ],
        ),
        body: PageView(
          controller: pageController,
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              color: Colors.black38,
            ),
            Container(
              color: Colors.black12,
            ),
            MyApp(
              cameras: cameras,
            )
          ],
        ));
  }
}
