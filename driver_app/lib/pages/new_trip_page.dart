// ignore_for_file: must_be_immutable, unused_local_variable, prefer_collection_literals, use_build_context_synchronously, prefer_const_constructors, unused_element, avoid_function_literals_in_foreach_calls, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_app/global/global_var.dart';
import 'package:ride_app/methods/main.dart';
import 'package:ride_app/methods/map_theme_methods.dart';
import 'package:ride_app/models/trip_details.dart';
import 'package:ride_app/widgets/loading_dailog.dart';
import 'package:ride_app/widgets/payment_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class NewTripPage extends StatefulWidget {
  TripDetails? newTripDetailsInfo;
  NewTripPage({this.newTripDetailsInfo, super.key});

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods mapThemeMethods = MapThemeMethods();
  double googleMapPadding = 0;
  List<LatLng> cooredinatesPolyLineLatLng = [];
  // PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markerSet = Set<Marker>();
  Set<Circle> circleSet = Set<Circle>();
  Set<Polyline> polyLineSet = Set<Polyline>();
  CommonMethods cMethods = CommonMethods();
  BitmapDescriptor? carMarkerIcon;
  bool directionRequested = false;
  String statusOfTrip = 'accepted';
  String durationText = '';
  String buttonTitleText = 'Arrived';
  Color buttonColor = Colors.indigoAccent;
  String distanceText = '';

  makeMarker() {
    if (carMarkerIcon == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(configuration, 'assets/images/ccc.png')
          .then((value) {
        carMarkerIcon = value;
      });
    }
  }

  obtainDirectionAndDrawRoute(sorceLocationLatLng, destinationLatLng) async {
    showDialog(
      context: context,
      builder: (context) => LoadingDialog(messageText: "Please Wait.."),
    );

    var tripDetailsInfo = await cMethods.getDirectionDetailsFromApi(
        sorceLocationLatLng, destinationLatLng);
    Navigator.pop(context);

    PolylinePoints pointspolyLine = PolylinePoints();
    List<PointLatLng> laLngpoints =
        pointspolyLine.decodePolyline(tripDetailsInfo!.encodedPoints!);

    cooredinatesPolyLineLatLng.clear();
    if (laLngpoints.isNotEmpty) {
      laLngpoints.forEach((PointLatLng pointLatLng) {
        cooredinatesPolyLineLatLng
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyLine = Polyline(
        polylineId: const PolylineId("routeID"),
        color: Colors.amberAccent,
        points: cooredinatesPolyLineLatLng,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polyLineSet.add(polyLine);
    });

    /////fitpolyLine on googleMap
    LatLngBounds boundlatLngBounds;
    if (sorceLocationLatLng.latitude > destinationLatLng.latitude &&
        sorceLocationLatLng.longitude > destinationLatLng.longitude) {
      boundlatLngBounds = LatLngBounds(
          southwest: destinationLatLng, northeast: sorceLocationLatLng);
    } else if (sorceLocationLatLng.longitude > destinationLatLng.longitude) {
      boundlatLngBounds = LatLngBounds(
          southwest:
              LatLng(sorceLocationLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(
              destinationLatLng.latitude, sorceLocationLatLng.longitude));
    } else if (sorceLocationLatLng.latitude > destinationLatLng.latitude) {
      boundlatLngBounds = LatLngBounds(
          southwest:
              LatLng(destinationLatLng.latitude, sorceLocationLatLng.longitude),
          northeast: LatLng(
              sorceLocationLatLng.latitude, destinationLatLng.longitude));
    } else {
      boundlatLngBounds = LatLngBounds(
          southwest: sorceLocationLatLng, northeast: destinationLatLng);
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundlatLngBounds, 72));

    Marker sourcetMarker = Marker(
      markerId: const MarkerId("sourceId"),
      position: sorceLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      // infoWindow:
      //     InfoWindow(title: pickUpLocation.placeName, snippet: 'Location'),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationId"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      // infoWindow: InfoWindow(
      //     title: dropOffLocation.placeName, snippet: 'DestinationLocation'),
    );
    setState(() {
      markerSet.add(sourcetMarker);
      markerSet.add(destinationMarker);
    });

    Circle sourceCircle = Circle(
      circleId: const CircleId("sourceCircleId"),
      strokeColor: Colors.pink,
      strokeWidth: 4,
      radius: 14,
      center: sorceLocationLatLng,
      fillColor: Colors.pink,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationCircleId"),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: destinationLatLng,
      fillColor: Colors.pink,
    );
    setState(() {
      circleSet.add(sourceCircle);
      circleSet.add(destinationCircle);
    });
  }

  getUpdatedLocationOfDriver() {
    LatLng lastPostioinLatLng = LatLng(0, 0);
    positionStramingTripPage = Geolocator.getPositionStream().listen(
      (Position positionDriver) {
        driverCureentPosition = positionDriver;
        LatLng driverCurrentPositionLatLng = LatLng(
            driverCureentPosition!.latitude, driverCureentPosition!.longitude);

        Marker carMarker = Marker(
            markerId: const MarkerId("carMarkerID"),
            position: driverCurrentPositionLatLng,
            icon: carMarkerIcon!,
            infoWindow: InfoWindow(title: "My Location"));

        setState(() {
          CameraPosition cameraPosition =
              CameraPosition(target: driverCurrentPositionLatLng, zoom: 16);
          controllerGoogleMap!
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          markerSet.removeWhere(
              (element) => element.markerId.value == "carMarkerID");
          markerSet.add(carMarker);
        });

        lastPostioinLatLng = driverCurrentPositionLatLng;
        updateTripDetailInformation();
        Map updatedLocationOfDriver = {
          "latitude": driverCureentPosition!.latitude,
          "longitude": driverCureentPosition!.longitude
        };

        FirebaseDatabase.instance
            .ref()
            .child("tripRequests")
            .child(widget.newTripDetailsInfo!.tripID!)
            .child("driverLocation")
            .set(updatedLocationOfDriver);
      },
    );
  }

  updateTripDetailInformation() async {
    if (!directionRequested) {
      directionRequested = true;
      if (driverCureentPosition == null) {
        return;
      }
      var driverPositionLatLng = LatLng(
          driverCureentPosition!.latitude, driverCureentPosition!.longitude);
      LatLng dropoffDestinationLocationLatLng;
      if (statusOfTrip == "accepted") {
        dropoffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.pickUpLatlng!;
      } else {
        dropoffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.dropOffLatlng!;
      }
      var directionDetailsInfo = await cMethods.getDirectionDetailsFromApi(
          driverPositionLatLng, dropoffDestinationLocationLatLng);

      if (directionDetailsInfo != null) {
        directionRequested = false;

        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  endTripNow() async {
    showDialog(
      context: context,
      builder: (context) => LoadingDialog(messageText: "Please Wait"),
    );
    var driverCurrentLocationLatLng = LatLng(
        driverCureentPosition!.latitude, driverCureentPosition!.longitude);
    var directionDetailsEndTripInfo = await cMethods.getDirectionDetailsFromApi(
        widget.newTripDetailsInfo!.pickUpLatlng!, driverCurrentLocationLatLng);
    Navigator.pop(context);
    String fareAmount =
        (cMethods.calculateFareAmount(directionDetailsEndTripInfo!)).toString();

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("fareAmount")
        .set(fareAmount);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("status")
        .set('ended');

    positionStramingTripPage!.cancel();
    //
    //dailog for collectiong fare amount
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(fareAmout: fareAmount),
    );
    saveAmountToDriverTotalEarnings(fareAmount);
  }

  saveAmountToDriverTotalEarnings(String fareAmount) async {
    DatabaseReference driverEarningsRef = FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");

    await driverEarningsRef.once().then((value) {
      if (value.snapshot.value != null) {
        double previousEarnings = double.parse(value.snapshot.value.toString());
        double fareamountForTrip = double.parse(fareAmount);

        double totalEarnings = previousEarnings + fareamountForTrip;
        driverEarningsRef.set(totalEarnings);
      } else {
        driverEarningsRef.set(fareAmount);
      }
    });
  }

  assignDriverDataTripINfo() async{
    Map<String,dynamic> driverDataMap = {
      "status": "accepted",
      "driverId": FirebaseAuth.instance.currentUser!.uid,
      "driverName": driverName,
      "driverPhone": driverPhone,
      "driverPhoto": driverPhone,
      "carDetails": carColor + " " + carModel + " " + carNumber,
    };

    Map<String,dynamic> driverCurrentLocation = {
      "latitude": driverCureentPosition!.latitude.toString(),
      "lonitude": driverCureentPosition!.longitude.toString(),
    };

   await  FirebaseDatabase.instance
        .ref()
        .child("triprequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .update(driverDataMap);

        await  FirebaseDatabase.instance
        .ref()
        .child("triprequests")
        .child(widget.newTripDetailsInfo!.tripID!).child("driverLocation")
        .update(driverCurrentLocation);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    assignDriverDataTripINfo();
  }

  @override
  Widget build(BuildContext context) {
    makeMarker();
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 136),
          initialCameraPosition: kGooglePlex,
          //initialCameraPosition: CameraPosition(target: target),
          // mapType: MapType.terrain,
          myLocationEnabled: false,
          markers: markerSet,
          polylines: polyLineSet,
          circles: circleSet,

          onMapCreated: (GoogleMapController mapController) async {
            controllerGoogleMap = mapController;
            mapThemeMethods.updateMapStyle(controllerGoogleMap!);

            // getCurrentLiveLocation();
            setState(() {
              googleMapPadding = 262;
            });
            googleMapCompleterController.complete(controllerGoogleMap);

            var driverLocationLatLng = LatLng(driverCureentPosition!.latitude,
                driverCureentPosition!.longitude);
            var pickUpLocatioLatLng = widget.newTripDetailsInfo!.pickUpLatlng;
            await obtainDirectionAndDrawRoute(
                driverLocationLatLng, pickUpLocatioLatLng);
            getUpdatedLocationOfDriver();
          },
        ),

        ////tripDetails
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(17),
                      topLeft: Radius.circular(17)),
                  color: Colors.black87,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 17,
                      spreadRadius: 0.5,
                      offset: Offset(.7, .7),
                    ),
                  ]),
              height: 256,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        durationText + "-" + distanceText,
                        style: TextStyle(color: Colors.green, fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.newTripDetailsInfo!.userName!,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(
                                "tel://${widget.newTripDetailsInfo!.userPhone}"));
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 10,
                            ),
                            child: Icon(
                              Icons.phone_android_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/ccc.png",
                          width: 16,
                          height: 16,
                        ),
                        Expanded(
                            child: Text(
                          widget.newTripDetailsInfo!.pickupAddress!.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/ccc.png",
                          width: 16,
                          height: 16,
                        ),
                        Expanded(
                            child: Text(
                          widget.newTripDetailsInfo!.dropOffAddress!.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (statusOfTrip == 'accepted') {
                            setState(() {
                              buttonTitleText = 'Start Trip';
                              buttonColor = Colors.green;
                            });

                            statusOfTrip = 'arrived';
                            FirebaseDatabase.instance
                                .ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailsInfo!.tripID!)
                                .child("status")
                                .set('arrived');
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  LoadingDialog(messageText: "Please Wait..."),
                            );
                            await obtainDirectionAndDrawRoute(
                                widget.newTripDetailsInfo!.pickUpLatlng!,
                                widget.newTripDetailsInfo!.dropOffLatlng!);
                          } else if (statusOfTrip == 'arrived') {
                            setState(() {
                              buttonTitleText = 'End Trip';
                              buttonColor = Colors.amber;
                            });

                            statusOfTrip = 'onTrip';
                            FirebaseDatabase.instance
                                .ref()
                                .child("tripRequests")
                                .child(widget.newTripDetailsInfo!.tripID!)
                                .child("status")
                                .set('onTrip');
                          } else if (statusOfTrip == 'onTrip') {
                            endTripNow();
                            //endTrip
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                        ),
                        child: Text(
                          buttonTitleText,
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              ),
            )),
      ]),
    );
  }
}
