# Notes

1. Check the package [barcode_scan](https://pub.dev/packages/barcode_scan) if you are adding this to an old flutter project. 

   This package returns a String from the Camera, as this package is a wrapper of 2 iOS and Android libraries it has the potential to return the **Format** of the code.
   There is progress in this, but it hasn't shipped yet (see https://github.com/mintware-de/flutter_barcode_reader/issues/131)
   
   Also there is a possible bug with iOs 13 when canceling via swipe (see https://github.com/mintware-de/flutter_barcode_reader/issues/153), it's fixed, but for the next release.
 
1. If you look for more manual control about the creation of the QR Code here is a [blog post](https://medium.com/flutter/building-a-qr-code-widget-in-flutter-d4edc457f4b3) from the author of the widget explaining the process he use to create the widget. 
