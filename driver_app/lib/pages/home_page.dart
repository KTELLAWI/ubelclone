// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_app/global/global_var.dart';
import 'package:ride_app/methods/map_theme_methods.dart';
import 'package:ride_app/pushNotification/push_notification_system.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  Color colorToShow = Colors.green;
  String titleToShow = "GO ONLINE NOW";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReferences;
  MapThemeMethods mapThemeMethods = MapThemeMethods();

  getCurrentLiveLocation() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;
    driverCureentPosition = currentPositionOfUser;
    LatLng positionOfUserInLatLang = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLang, zoom: 5);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow() {
    Geofire.initialize("onlineDrivers");
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    newTripRequestReferences = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReferences!.set("waiting");

    newTripRequestReferences!.onValue.listen(
      (event) {},
    );
  }

  setAndGetLocationUpdate() {
    positionStramingHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfUser = position;
      if (isDriverAvailable == true) {
        Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
            currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
      }

      LatLng positionLatLng = LatLng(
          currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOffLineNow() {
    /////
    Geofire.removeLocation(
      FirebaseAuth.instance.currentUser!.uid,
    );
    newTripRequestReferences!.onDisconnect();
    newTripRequestReferences!.remove();
    newTripRequestReferences = null;
    positionStramingHomePage!.cancel();
  }

  initilaizePushNotification() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceToken();
    notificationSystem.startlisteningForNewNotification(context);
  }

  retriveCurrentDriverInfo() async {
    await FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid.toString())
        .once()
        .then((data) {
      driverName = (data.snapshot.value as Map)['name'];
      driverPhone = (data.snapshot.value as Map)['phone'];
      driverphoto = (data.snapshot.value as Map)['photo'];
      carColor = (data.snapshot.value as Map)["car_details"]['carColor'];
      carModel = (data.snapshot.value as Map)["car_details"]['carModel'];
      carNumber = (data.snapshot.value as Map)["car_details"]['carNumber'];
    });

    initilaizePushNotification();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retriveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 136),
            initialCameraPosition: kGooglePlex,
            //initialCameraPosition: CameraPosition(target: target),
            // mapType: MapType.terrain,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;
              mapThemeMethods.updateMapStyle(controllerGoogleMap!);
              getCurrentLiveLocation();
              googleMapCompleterController.complete(controllerGoogleMap);
            },
          ),
          Container(
            height: 136,
            width: double.infinity,
            color: Colors.black54,
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 61,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: false,
                          builder: (context) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber,
                                      blurRadius: 5,
                                      spreadRadius: .3,
                                      offset: Offset(.3, .3),
                                    )
                                  ]),
                              height: 221,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 18),
                                child: Column(children: [
                                  const SizedBox(
                                    height: 11,
                                  ),
                                  Text(
                                    !isDriverAvailable
                                        ? "GO ONLINE NOW"
                                        : "GO OFFLINE NOW",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 21,
                                  ),
                                  Text(
                                    !isDriverAvailable
                                        ? "You are about to go online, you will become available to receive trip requests from users"
                                        : "you are about to go oofiline , you will stop receiving trip requests from users ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Back"),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!isDriverAvailable) {
                                              goOnlineNow();

                                              setAndGetLocationUpdate();

                                              Navigator.pop(context);
                                              setState(() {
                                                colorToShow = Colors.pink;
                                                titleToShow = "GO OFFLINE NOW";
                                                isDriverAvailable = true;
                                              });
                                            } else {
                                              Navigator.pop(context);
                                              setState(() {
                                                colorToShow = Colors.green;
                                                titleToShow = "GO ONLINE NOW";
                                                isDriverAvailable = false;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                titleToShow == "GO ONLINE NOW"
                                                    ? Colors.green
                                                    : Colors.pink,
                                          ),
                                          child: Text("Confirm"),
                                        ),
                                      ),
                                    ],
                                  )
                                ]),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorToShow,
                      ),
                      child: Text(
                        titleToShow,
                      ))
                ],
              ))
        ],
      ),
    );
  }
}
