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
