# Flutter QR Demo App

## Mission

Our goal is to make a QR Code temporary access key app in Flutter. The app must generate a QR Code with a encrypted key and be able to share an image with the QR with another application. A second functionality of the app is to scan a QR Code, decrypt the data and validate it to grant or deny access.

## End Result

![Screenshots](assets/full-screenshots.jpg2)


## Steps

1. Generate a new Flutter project

   ```bash
   flutter create fireship_barcode_scanner
   ```

1. Add the following dependencies to you `pubspec.yaml` file
   ```
   dependencies:
     barcode_scan: any
     qr_flutter: ^3.1.0
     encrypt: any
     path_provider: any
     share: ^0.6.3
   ```
   The first two are the most important to work with QR Codes
   ```
     # Plugin to Scan Barcodes with the Camera
     barcode_scan: any
   
     # Plugin to create QR Codes
     qr_flutter: ^3.1.0
   ```
   For the purpose of this Demo we will use `encrypt` to validate the random QR Code  
   ```
     # Used to show the validation of the Code
     encrypt: any
   ```
   The last two are needed to create a temporary file and share it with another app. 
   ```
     # Needed to create a Temp Image to Share
     path_provider: any
     # Plugin to Share Text and Images
     share: ^0.6.3
   ```
   The `share` package just recently added support to [share images](https://github.com/flutter/plugins/pull/970), but at the time of writing this the normal import method doesn't contain that functionality.
   
   So we need to target the specific [commit](https://github.com/pboos/plugins/commit/0fb2f9afd29f7a8812c730f7cc7ec7b4eb9fae55) (for now):

   ```
     # Plugin to Share Text and Images (only the last version has Image Share capabilities)
     # https://github.com/pboos/plugins/tree/feature/shareFile/packages/share
     # https://github.com/flutter/plugins/pull/970
     share:
       git:
         url: https://github.com/pboos/plugins.git
         path: packages/share
         ref: feature/shareFile
   ```

1. Run package installer

   ```bash
   flutter packages get
   ```
   
1. Create the following files under the `lib` folder:
    1. qr_database.dart
    1. scanner.dart
    1. share_qr.dart
    1. page_generate_code.dart
    1. page_scan_code.dart
    
1. First we are going to build two functions to emulate a new code and the validation of an existing one. Ideally this functions will talk to a backend and receive the new Code String and validation from there.

   Paste the following code in `qr_database.dart`:
    
    ```dart
    import 'dart:math';
    import 'package:encrypt/encrypt.dart';
    
    final MAX_DEMO_NUMBER = 50000;
    final MIN_DEMO_NUMBER = 50000;
    final ENCRYPTER_SECRET = 'SOME RANDOM 32 CHARACTER STRING.';
    
    Encrypter _getEncrypter() {
      final key = Key.fromUtf8(ENCRYPTER_SECRET);
      return Encrypter(AES(key));
    }
    
    String getNewQrCode() {
      final iv = IV.fromLength(16);
      final encrypter = _getEncrypter();
    
      Random random = new Random();
      int randomNumber = random.nextInt(MAX_DEMO_NUMBER) + MIN_DEMO_NUMBER;
      final text = randomNumber.toString();
    
      final encrypted = encrypter.encrypt(text, iv: iv);
      return encrypted.base64;
    }
    
    bool validateQrCode(String encryptedText) {
      try {
        final iv = IV.fromLength(16);
        final encrypter = _getEncrypter();
    
        final encrypted = Encrypted.from64(encryptedText);
        final decrypted = encrypter.decrypt(encrypted, iv: iv);
    
        final number = int.parse(decrypted);
        return number > MIN_DEMO_NUMBER &&
            number <= (MAX_DEMO_NUMBER + MIN_DEMO_NUMBER);
      } catch (e) {
        return false;
      }
    }
    ```  

1. Next we are going to create a function to read a code from the camera, catch platform errors and user cancel.

   Paste the following code in `scanner.dart`:

   ```dart
   import 'package:flutter/services.dart';
   import 'package:barcode_scan/barcode_scan.dart';
   
   
   /// Open the Camera and scans a QR Code, if the User cancels the scan is
   /// interpreted as a reset an the value is set to empty String
   Future<String> scanBarcode() async {
     String scanResult;
     try {
       scanResult = await BarcodeScanner.scan();
     } on PlatformException catch (e) {
       if (e.code == BarcodeScanner.CameraAccessDenied) {
         scanResult = 'CameraAccessDenied';
       } else if (e.code == BarcodeScanner.UserCanceled) {
         scanResult = '';
       } else {
         scanResult = e.toString();
       }
     } on FormatException {
       scanResult = '';
     } catch (e) {
       scanResult = e.toString();
     }
     return scanResult;
   }
   ```

1. Create a function to handle the creation and share of the QR Code Image
   
   Paste the following code in `share_qr.dart`
   ```dart
    import 'dart:io';
    import 'dart:ui';
    import 'package:qr_flutter/qr_flutter.dart';
    import 'package:share/share.dart';
    import 'package:path_provider/path_provider.dart';
    
    /// Renders a QR Code in a temp file and Triggers a Share Action with the
    /// created image.
    shareQrCode(String data) async {
      try {
        // Create the Image with the input data
        final image = await QrPainter(
                data: data,
                version: QrVersions.auto,
                gapless: false,
                color: Color(0xFF000000),
                emptyColor: Color(0xFFFFFFFF))
            .toImage(800);
        // Convert the Image object to ByteData
        final png = await image.toByteData(format: ImageByteFormat.png);
        // get Raw Data from the Buffer to save to a file
        final imageRaw = png.buffer.asUint8List();
        
        // Request App folder to store files 
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        // Create the PATH to the temp image file
        final filePath = '$path/temp_qr_file.png';
        // File object representing the temp file 
        final file = File(filePath);
    
        // Write the Image Raw data to the temp file
        file.writeAsBytesSync(imageRaw);
        // Call Share plugin to trigger the action
        await Share.shareFile(file);
      } catch (e) {
        throw e;
      }
    }
    ```
   
1. Now it's time to create the first action / page of the App, the QR Generator with a button to share the Image.

   This will create a placeholder for the dynamic QR code we are going to render.
   
   Paste the following code in `page_generate_code.dart`:
   
   ```dart
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

   ```

1. Note that the action of sharing the image is handled by the function in step 7)
    ```dart 
    _shareCurrentCode() {
        shareQrCode(this._currentCode);
    }
    ```
   
1. To render the QR Code in the `PageGenerateCode` widget, we need to implement the `_refreshCode` method
    ```dart
     _refreshCode() async {
        // Get a New Encrypted Value
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
    
    ```

1. For the second action (`PageScanCode`), the one who will scan the code and validate the access, we need a button a success/error message depending on the result of the scan.

   Paste the following code in `page_scan_code.dart`:
       
    ```dart
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
    
    ```
   
1. Now that we have both pages ready we need to modify `main.dart` file to render them on the home page.

   The first part of the main file should look like this:
    ```dart
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
    ```
   
   **Note:** for the scope of this demo the QR image size strategy doesn't work well on landscape mode. So it's restricted to portrait mode.
   
1. Create the app as two tabs, one for each action
    ```dart
    
    class MyHomePage extends StatefulWidget {
      MyHomePage({Key key}) : super(key: key);
    
      @override
      _MyHomePageState createState() => _MyHomePageState();
    }
   
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
    ```  