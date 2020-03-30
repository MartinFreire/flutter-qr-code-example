import 'dart:io';
import 'dart:ui';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

shareQrCode(String data) async {
  try {
    final image = await QrPainter(data: data, version: QrVersions.auto, gapless: false, color: Color(0xFF000000), emptyColor: Color(0xFFFFFFFF)).toImage(300);
    final a = await image.toByteData(format: ImageByteFormat.png);
    final imageRaw = a.buffer.asUint8List();
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final filePath = '$path/temp_qr_file.png';
    final file = File(filePath);

    file.writeAsBytesSync(imageRaw);
    await Share.shareFile(file);
  } catch (e) {
    throw e;
  }
}
