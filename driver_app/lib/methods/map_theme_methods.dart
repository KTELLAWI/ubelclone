import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapThemeMethods{
  
  setGoogleMapStyle(String value, GoogleMapController controller) {
    controller.setMapStyle(value);
  }

  Future<String> getJsonFileFromThemes(String mapStylePath) async {
    ByteData byteData = await rootBundle.load(mapStylePath);
    var list = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  void updateMapStyle(GoogleMapController controller) {
    getJsonFileFromThemes('lib/themes/night_style.json')
        .then((value) => setGoogleMapStyle(value, controller));
  }

}