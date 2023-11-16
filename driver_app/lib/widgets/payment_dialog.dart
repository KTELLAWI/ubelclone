// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, must_be_immutable


import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:ride_app/methods/main.dart';

class PaymentDialog extends StatefulWidget {
  PaymentDialog({required this.fareAmout, super.key});

  String fareAmout;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      backgroundColor: Colors.black87,
      child: Container(
          margin: EdgeInsets.all(0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 21,
              ),
              Text("Collect Cash",
                  style: TextStyle(
                    color: Colors.black,
                  )),
              SizedBox(
                height: 21,
              ),
              Divider(
                height: 1.5,
                color: Colors.black,
                thickness: 1.0,
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "\$${widget.fareAmout}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                    "this is fare Amout (\$${widget.fareAmout}) to be charged from Rider",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    )),
              ),
              SizedBox(
                height: 31,
              ),
              ElevatedButton(
             
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    commonMethods.turnOnLocationUpdateOnHomePage();
                    Restart.restartApp();
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text("Collect cash")),
              SizedBox(
                height: 41,
              ),
            ],
          )),
    );
  }
}
