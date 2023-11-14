// ignore_for_file: unused_local_variable, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_app/global/global_var.dart';
import 'package:http/http.dart' as http;
import 'package:ride_app/models/direction_details.dart';

class CommonMethods {
  checkConnectivity(BuildContext context) async {
    var connectivity = await Connectivity().checkConnectivity();

    if (connectivity != ConnectivityResult.mobile &&
        connectivity != ConnectivityResult.wifi) {
      if (!context.mounted) return;
      displaySnackBar("Your internet Connection is not available", context);
    }
  }

  displaySnackBar(String message, BuildContext context) {
    var snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  turnOffLocationUpdateOnHomePage() {
    positionStramingHomePage!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }
    turnOnLocationUpdateOnHomePage() {
    positionStramingHomePage!.resume();
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
    driverCureentPosition!.latitude,driverCureentPosition!.longitude);
  }
     sendRequestApi(String apiUrl) async {
    http.Response responseFromApi = await http.get(Uri.parse(apiUrl));

    try {
      if (responseFromApi.statusCode == 200) {
        String stringfromApi = responseFromApi.body;
        var datadecode = jsonDecode(stringfromApi);
        return datadecode;
      } else {
        return "error";
      }
    } catch (errorMsg) {
      return "error";
    }
  }
    Future<DirectionDetails?> getDirectionDetailsFromApi(
      LatLng source, LatLng destination) async {
    String urlDirectionApi =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";
    var responseFromDorectionApi = await sendRequestApi(urlDirectionApi);
    if (responseFromDorectionApi == 'error') {
      return null;
    }
    DirectionDetails detailsModal = DirectionDetails();
    detailsModal.distanceTextString =
        responseFromDorectionApi['routes'][0]['legs'][0]['distance']['text'];
    detailsModal.distanceValueDigits =
        responseFromDorectionApi['routes'][0]['legs'][0]['distance']['value'];

    detailsModal.durationTextString =
        responseFromDorectionApi['routes'][0]['legs'][0]['duration']['text'];
    detailsModal.durationValueDigit =
        responseFromDorectionApi['routes'][0]['legs'][0]['duration']['value'];

    detailsModal.encodedPoints =
        responseFromDorectionApi['routes'][0]["overview_polyline"]['points'];
    print("ddddddddddddddddddddddddddddddddddddddddddd" +
        detailsModal.durationTextString!);

    return detailsModal;
  }
    calculateFareAmount(DirectionDetails directionDetails) {
    double distancePerKmAmount = 0.4;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount = 2;

    double totalDistanceTravelFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpendFarePerAmount =
        (directionDetails.durationValueDigit! / 60) * durationPerMinuteAmount;

    double overTotalFareAmount = baseFareAmount +
        totalDistanceTravelFareAmount +
        totalDurationSpendFarePerAmount;

    return overTotalFareAmount;
  }
}
