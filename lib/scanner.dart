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
