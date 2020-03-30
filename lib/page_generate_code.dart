import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_database.dart';
import 'share_qr.dart';


/// Renders a Page with a random new QR Code and 2 buttons. One to refresh the
/// code and one to share an image to another App
class PageGenerateCode extends StatefulWidget {
  PageGenerateCode({Key key}) : super(key: key);

  @override
  _PageGenerateCode createState() => _PageGenerateCode();
}

class _PageGenerateCode extends State<PageGenerateCode> {
  /// The current value to draw
  String _currentCode;
  /// The compiled widget to instert in the Widget Tree
  QrImage _currentImage;

  /// Creates a new Random value and renders the Widget
  _refreshCode() async {
    // Get a New Encripted Value
    final newCode = getNewQrCode();
    // Render the Widget
    final newImage = await QrImage(
      data: newCode,
      version: QrVersions.auto,
      size: MediaQuery.of(context).size.width,
      gapless: false,
    );
    /// Only when the values are ready update the State, to avoid locking the
    /// render process
    setState(() {
      this._currentCode = newCode;
      this._currentImage = newImage;
    });
  }

  /// Shares an Image with the current value
  _shareCurrentCode() {
    shareQrCode(this._currentCode);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    // Request first QR
    if (this._currentImage == null) {
      _refreshCode();
    }

    return Center(
      child: Column(
        children: <Widget>[
          Container(
              child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  // If the image is not ready, render a blank Container
                  child: _currentImage != null
                      ? _currentImage
                      : Container(width: size, height: size))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Refresh Button
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
              // Share Button
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
                    onPressed: () => _shareCurrentCode(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
