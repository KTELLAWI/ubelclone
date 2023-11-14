import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String googleMapKey = 'AIzaSyD4FMYsCgW55FY7JQiUkJEQKorrlXN8Ro8';
CameraPosition kGooglePlex = const CameraPosition(
  target: LatLng(41.42796133580664, 28.085749655962),
  zoom: 5,
);

int driverTripQuestTimeOut = 20;
StreamSubscription<Position>? positionStramingHomePage;
StreamSubscription<Position>? positionStramingTripPage;

final audioPlayer = AssetsAudioPlayer();
Position? driverCureentPosition;
String driverName = "";
String driverphoto = "";
String carColor='';
String carModel='';
String carNumber='';
String driverPhone='';

