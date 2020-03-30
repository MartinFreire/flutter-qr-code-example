import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'scanner.dart';
import 'qr_database.dart';
import 'share_qr.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Barcode Scanner Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentCode;
  QrImage _currentImage;

  String _scanLastRead = '';
  bool _scanResult = false;

  _refreshCode() async {
    final newCode = getNewQrCode();
    final newImage = await QrImage(
      data: newCode,
      version: QrVersions.auto,
      size: MediaQuery.of(context).size.width,
      gapless: false,
    );

    setState(() {
      this._currentCode = newCode;
      this._currentImage = newImage;
    });
  }

  _scanCode() async {
    final scanResult = await scanBarcode();
    setState(() {
      this._scanLastRead = scanResult;
      this._scanResult = validateQrCode(scanResult);
    });
  }


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size.width;

    if ( this._currentImage == null ) {
      _refreshCode();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.audiotrack)),
              Tab(icon: Icon(Icons.camera_rear)),
            ],
          ),
        ),
        body: TabBarView(children: [
          Center(
            child: Column(
              children: <Widget>[
                Container(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: _currentImage != null ? _currentImage : Container( width: size, height: size )
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: Colors.green,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.refresh, size: 45),
                          color: Colors.white,
                          onPressed: () => _refreshCode(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Ink(
                        decoration: ShapeDecoration(
                          color: Colors.lightBlue,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.share, size: 45),
                          color: Colors.white,
                          onPressed: () => shareQrCode(this._currentCode),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
              child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MaterialButton(
                  child: Text('SCAN CODE'),
                  textTheme: ButtonTextTheme.primary,
                  color: Theme.of(context).colorScheme.primary,
                  height: 50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                  onPressed: _scanCode,
                ),
              ),

              if ( _scanLastRead != '' ) ...[
                // Uncomment next line to view the read from the camara.
                // Text('$_scanLastRead', style: Theme.of(context).textTheme.display1),
                if ( _scanResult ) ...[
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  Text('Access Granted', style: Theme.of(context).textTheme.display1),
                ],
                if ( !_scanResult ) ...[
                  Icon(Icons.error, color: Colors.red, size: 80),
                  Text('Access denied', style: Theme.of(context).textTheme.display1),
                ]
              ]
            ],
          ))
        ]),
      ),
    );
  }

}
