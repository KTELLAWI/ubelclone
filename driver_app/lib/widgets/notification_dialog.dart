// ignore_for_file: must_be_immutable, prefer_const_constructors, unused_local_variable

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ride_app/global/global_var.dart';
import 'package:ride_app/methods/main.dart';
import 'package:ride_app/models/trip_details.dart';
import 'package:ride_app/pages/new_trip_page.dart';
import 'package:ride_app/widgets/loading_dailog.dart';

class NotificatioDailog extends StatefulWidget {
  TripDetails? tripDetails;
  NotificatioDailog({this.tripDetails, super.key});

  @override
  State<NotificatioDailog> createState() => _NotificatioDailogState();
}

class _NotificatioDailogState extends State<NotificatioDailog> {
  String tripRequestStatus = "";
  CommonMethods cMethods = CommonMethods();


  cancelNotificationDialogAfter20Sec() {
    const oneTickPerSecond = Duration(seconds: 1);
    var timerCountDown = Timer.periodic(oneTickPerSecond, (timer) {
      driverTripQuestTimeOut = driverTripQuestTimeOut - 1;
      if (tripRequestStatus == "accepted") {
        driverTripQuestTimeOut = 20;
      }
      if (driverTripQuestTimeOut == 0) {
        Navigator.pop(context);
        timer.cancel();
        driverTripQuestTimeOut = 20;
        audioPlayer.stop();
      }
    });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    cancelNotificationDialogAfter20Sec();
  }

  checkAailabilityofTripRequest(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(messageText: "Please wait")
    );

    DatabaseReference driverTripStatusRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    await driverTripStatusRef.once().then((value) {
      Navigator.pop(context);
      Navigator.pop(context);
      String newTripStatusValue = "";
      if (value.snapshot.value != null) {
        newTripStatusValue = value.snapshot.value.toString();
      } else {
        cMethods.displaySnackBar("TripRequest not found ", context);
      }
      if (newTripStatusValue == widget.tripDetails!.tripID) {
        driverTripStatusRef.set("accepted");
        cMethods.turnOffLocationUpdateOnHomePage();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => NewTripPage(newTripDetailsInfo: widget.tripDetails),
            ));
      } else if (newTripStatusValue == "cancelled") {
        cMethods.displaySnackBar(
            'the trip request has cancelled by user ', context);
      } else if (newTripStatusValue == "timeout") {
        cMethods.displaySnackBar('the trip request has timed out ', context);
      } else {
        cMethods.displaySnackBar("Trip request not found", context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            height: 30.0,
          ),
          Image.asset(
            "assets/images/ccc.png",
            width: 140,
          ),
          SizedBox(height: 16.0),
          Text("New Trip Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey,
              )),
          SizedBox(
            height: 20,
          ),
          Divider(
            height: 1,
            color: Colors.white,
            thickness: 1,
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/initial.png",
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(width: 18),
                    Expanded(
                        child: Text(
                      widget.tripDetails!.pickupAddress.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    )),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      "assets/images/initial.png",
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(width: 18),
                    Expanded(
                        child: Text(
                      widget.tripDetails!.dropOffAddress.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white,
          ),
          const SizedBox(
            height: 9,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      audioPlayer.stop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                    ),
                    child: Text(
                      "Decline",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      tripRequestStatus = 'accepted';
                      audioPlayer.stop();
                      checkAailabilityofTripRequest(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: Text(
                      "Accept",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0)
        ]),
      ),
    );
  }
}

        
       
        
        
        
        