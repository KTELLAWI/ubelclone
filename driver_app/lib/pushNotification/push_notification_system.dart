// ignore_for_file: body_might_complete_normally_nullable, unused_local_variable

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_app/global/global_var.dart';
import 'package:ride_app/models/trip_details.dart';
import 'package:ride_app/widgets/loading_dailog.dart';
import 'package:ride_app/widgets/notification_dialog.dart';
import 'package:ride_app/widgets/payment_dialog.dart';

class PushNotificationSystem {
  FirebaseMessaging firebaseCloudMessageing = FirebaseMessaging.instance;

  Future<String?> generateDeviceToken() async {
    String? deviceRecogniationToken = await firebaseCloudMessageing.getToken();

    DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('deviceToken');

    referenceOnlineDriver.set(deviceRecogniationToken);

    firebaseCloudMessageing.subscribeToTopic('drivers');
    firebaseCloudMessageing.subscribeToTopic('users');
  }

  startlisteningForNewNotification(BuildContext context) async {
    //// listen to notofoation and app is terminated
 retrveTripRequestInfo("tripID", context);
    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? messageRemote) {
    //        //print("nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
     
    //   if (messageRemote != null) {
    //     String tripID = messageRemote.data['tripID'];
    //     retrveTripRequestInfo(tripID, context);
    //   }
    // });

    // //// foreground

    // FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
    //   if (messageRemote != null) {
    //    String tripID = messageRemote.data['tripID'];
    //    retrveTripRequestInfo(tripID, context);
    //   }
    // });

    // ///// running in Background
    // ///
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      
    //   if (messageRemote != null) {
    //     String tripID = messageRemote.data['tripID'];
    //     retrveTripRequestInfo(tripID, context);
    //   }
    // });
  }

  retrveTripRequestInfo(String tripID, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          LoadingDialog(messageText: "Gettings Details............"),
    );

    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child('tripRequests').child("-NjNOG60CUUdvqXhLhZY");
    tripRequestRef.once().then((data) {
      Navigator.pop(context);
     // audioPlayer.open(Audio("assets/audio/"));
     // audioPlayer.play();
     print("dddddddddd");
      TripDetails tripDetailsInfo = TripDetails();
      tripDetailsInfo.pickUpLatlng = LatLng(42.000,10.000);
      // LatLng(
      //     double.parse(
      //         (data.snapshot.value! as Map)['pickuplatlng']["latitude"]),
      //     double.parse(
      //         (data.snapshot.value! as Map)['pickuplatlng']["longitude"]));
      tripDetailsInfo.pickupAddress ="AbuDabi China Mall";
          (data.snapshot.value! as Map)['pickupAddress'];
      tripDetailsInfo.dropOffLatlng =LatLng(42.000,10.000);
      //  LatLng(
      //     double.parse(
      //         (data.snapshot.value! as Map)['dropoffLatLng']["latitude"]),
      //     double.parse(
      //         (data.snapshot.value! as Map)['dropOffLatLng']["longitude"]));
      tripDetailsInfo.dropOffAddress ="AbuDabi China Mall";
       //   (data.snapshot.value! as Map)['dropoffAddress'];
      tripDetailsInfo.userName = "Ahmet Sherif";//(data.snapshot.value! as Map)['userName'];
      tripDetailsInfo.userPhone = "00974 567892";//(data.snapshot.value! as Map)['userPhone'];
      tripDetailsInfo.tripID = "-NjNOG60CUUdvqXhLhZY";//tripID;
      print("cccccccccccccccccccc"+tripDetailsInfo.tripID.toString());
       showDialog(
      context: context,
      builder: (context) => PaymentDialog(fareAmout: "50"),
    );

      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) => NotificatioDailog(tripDetails: tripDetailsInfo),
      // );
    });
  }
}
