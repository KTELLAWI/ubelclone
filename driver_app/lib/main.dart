// ignore_for_file: prefer_const_constructors, avoid_print, unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_app/authenticatio/login_screen.dart';
import 'package:ride_app/authenticatio/signup_screen.dart';
import 'package:ride_app/pages/dashboard.dart';
import 'package:ride_app/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // var status = await Permission.camera.status;
  // if (status.isDenied) {
    
  //     print("camerrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr");
   
  // }
  await Permission.locationWhenInUse.isDenied.then((valuOfPermissione) => {
        if (valuOfPermissione) {Permission.locationWhenInUse.request()}
      });
      await Permission.notification.isDenied.then((valuOfPermissione) => {
        if (valuOfPermissione) {Permission.notification.request()}
      });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Booking Taxi Driver App',
      
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        // ignore: deprecated_member_use
        scaffoldBackgroundColor: Colors.black
        
       
      ),
      home: FirebaseAuth.instance.currentUser != null ? HomePage():LoginScreen(),
      //const Dashboard(),
  //SignUpScreen(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, });

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text("title"),
//       ),
//       body: Text("")

//      // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

extension RouterContext on BuildContext {
  toNamed(routeName, {Object? args}) =>
      Navigator.push(this, MaterialPageRoute(builder: (e) => routeName));
}
