// ignore_for_file: prefer_const_constructors, unused_local_variable, unused_element, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unused_import, unnecessary_overrides

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_app/pages/earning-page.dart';
import 'package:ride_app/pages/home_page.dart';
import 'package:ride_app/pages/profile_page.dart';
import 'package:ride_app/pages/trips_page..dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int indexSelected = 0;

  onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller!.index = indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          HomePage(),
          EarningPage(),
          TripsPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "Earnings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree), label: "Trips"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        
        currentIndex: indexSelected,
        backgroundColor: Colors.amber.withOpacity(.7),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 14),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}
