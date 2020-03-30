import 'package:flutter/material.dart';
import 'qr_database.dart';
import 'scanner.dart';


/// Renders a Page with a with a button to call the Camera and scan for a
/// QR Code
class PageScanCode extends StatefulWidget {
  PageScanCode({Key key}) : super(key: key);

  @override
  _PageScanCode createState() => _PageScanCode();
}

class _PageScanCode extends State<PageScanCode> {
  /// Last value read from the Camera
  String _scanLastRead = '';
  /// Last scan validation result
  bool _scanResult = false;

  /// Call for a new code read from the Camera
  _scanCode() async {
    final scanRead = await scanBarcode();
    final scanResult = validateQrCode(scanRead);
    /// Only when the value is ready update the State, to avoid locking the
    /// render process
    setState(() {
      this._scanLastRead = scanRead;
      this._scanResult = scanResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MaterialButton(
            child: Text('SCAN CODE'),
            textTheme: ButtonTextTheme.primary,
            color: Theme.of(context).colorScheme.primary,
            height: 50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: _scanCode,
          ),
        ),
        if (_scanLastRead != '') ...[
          // Uncomment next line to view the read from the camera.
          // Text('$_scanLastRead', style: Theme.of(context).textTheme.display1),
          if (_scanResult) ...[
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            Text('Access Granted', style: Theme.of(context).textTheme.display1),
          ],
          if (!_scanResult) ...[
            Icon(Icons.error, color: Colors.red, size: 80),
            Text('Access denied', style: Theme.of(context).textTheme.display1),
          ]
        ]
      ],
    ));
  }

}
