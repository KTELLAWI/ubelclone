// ignore_for_file: prefer_const_constructors, unused_local_variable, unused_element, non_constant_identifier_names

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ride_app/authenticatio/login_screen.dart';
import 'package:ride_app/main.dart';
import 'package:ride_app/methods/main.dart';
import 'package:ride_app/pages/dashboard.dart';
import 'package:ride_app/widgets/loading_dailog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  XFile? imageFile;
  String? urlOfUploadedImage =
      "https://firebasestorage.googleapis.com/v0/b/ubberflutter.appspot.com/o/images%2Fmesf.png?alt=media&token=9a6b1f7b-8b33-436f-9373-c484bba43487&_gl=1*tplke5*_ga*Mzk5MzE4NTI3LjE2OTc5NjE2Mzk.*_ga_CW55HF8NVT*MTY5ODIzMDA1MC44LjEuMTY5ODIzMDE2Mi4yMi4wLjA.";

  chooseImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  registerUser() async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Registering your Accoutn......"));

    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            // ignore: body_might_complete_normally_catch_error
            .catchError((errorMessage) {
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMessage.toString(), context);
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(userFirebase!.uid);

    Map car_details = {
      "car_model": carModelController.text.trim(),
      "car_color": carColorController.text.trim(),
      "car_number": carNumberController.text.trim(),
    };

    Map DriverDataMap = {
      "photo": urlOfUploadedImage,
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
      "car_details": car_details,
    };
    userRef.set(DriverDataMap);
    context.toNamed(Dashboard());
  }

  uploadImage() async {
    String imageIDName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceImage =
        FirebaseStorage.instance.ref().child('images').child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState(() {
      urlOfUploadedImage;
    });
    registerUser();
  }

  formValidation() {
    if (nameController.text.trim().length < 4) {
      cMethods.displaySnackBar("name is not right ", context);
    } else if (!emailController.text.contains("@")) {
      cMethods.displaySnackBar("Email is not right ", context);
    } else if (carColorController.text.trim().length < 4) {
      cMethods.displaySnackBar("Color is not right ", context);
    } else if (carNumberController.text.trim().length < 4) {
      cMethods.displaySnackBar("Car number  is not right ", context);
    } else if (carModelController.text.trim().length < 4) {
      cMethods.displaySnackBar("Car Model is not right ", context);
    } else {
      //uploadImage();
      registerUser();
    }
  }

  checkIfNetWorkAvailable() async {
    cMethods.checkConnectivity(context);
    formValidation();
    // if (imageFile == null) {
    //   formValidation();
    // } else {
    //   cMethods.displaySnackBar("Please Upload an Image at first ", context);
    // }

    //register with firebase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            // Text("Create Driver Account"),
            SizedBox(
              height: 40,
            ),
            imageFile == null
                ? CircleAvatar(
                    radius: 85,
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage("assets/images/carLogo3.jpg"),
                  )
                : Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                        image: DecorationImage(
                          fit: BoxFit.fitHeight,
                          image: FileImage(File(imageFile!.path)),
                        )),
                  ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(5),
                //color: Colors.amber,
                child: Text("Upload your image",
                    style: TextStyle(color: Colors.amber)),
              ),
              onTap: () {
                chooseImageFromGallery();
              },
            ),
            Padding(
              padding: EdgeInsets.all(22),
              child: Column(children: [
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "User Name",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(
                  height: 22,
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(
                  height: 22,
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(
                  height: 22,
                ),
                TextField(
                  controller: carModelController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "Car Model",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(
                  height: 22,
                ),
                TextField(
                  controller: carColorController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "Your Car Color",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(
                  height: 22,
                ),
                TextField(
                  controller: carNumberController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "Your car Number",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                SizedBox(
                  height: 32,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        checkIfNetWorkAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: ContinuousRectangleBorder(
                            side: BorderSide.none,
                            borderRadius: BorderRadius.circular(75)),
                        backgroundColor: Colors.amber,
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      ),
                      child: Text(
                        "SignUp",
                        style: TextStyle(fontSize: 22,color:Colors.white),
                      )),
                ),
              ]),
            ),
            TextButton(
                onPressed: () {
                  context.toNamed(LoginScreen());
                },
                child: Text(
                  "Already have an account? Login here",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ))
          ]),
        ),
      ),
    );
  }
}
