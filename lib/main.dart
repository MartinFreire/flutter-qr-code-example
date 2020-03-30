import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'page_scan_code.dart';
import 'page_generate_code.dart';

void main() {
  // This line is required to call SystemChrome.setPreferredOrientations
  WidgetsFlutterBinding.ensureInitialized();

  // This enforces portrait mode to avoid overflow on the painting of the QR in
  // landscape, and thus enabling dynamic size of the widget.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Codes Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Creates a Tab Bar Page
/// Each of the 2 actions is build on it's own file and place here as a tab
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('QR Codes Demo'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.audiotrack)),
              Tab(icon: Icon(Icons.camera_rear)),
            ],
          ),
        ),
        body: TabBarView(children: [PageGenerateCode(), PageScanCode()]),
      ),
    );
  }
}
