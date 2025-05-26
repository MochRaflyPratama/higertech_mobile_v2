import 'package:flutter/material.dart';
import 'package:projectv2/app/modules/home/Homescreen.dart';
import 'package:projectv2/app/modules/locations/tag/taglocation.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LocationPickerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
