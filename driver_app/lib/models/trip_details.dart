import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String? tripID;
  LatLng? pickUpLatlng;
  String? pickupAddress;
  LatLng? dropOffLatlng;
  String? dropOffAddress;
  String? userName;
  String? userPhone;
  // Constructor
  TripDetails({
    this.tripID,
    this.pickUpLatlng,
    this.pickupAddress,
    this.dropOffLatlng,
    this.dropOffAddress,
    this.userName,
    this.userPhone,
  });


}
