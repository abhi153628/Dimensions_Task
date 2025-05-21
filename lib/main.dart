import 'package:dimensionleap/screens/home_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const GetJobApp());
}

class GetJobApp extends StatelessWidget {
  const GetJobApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetJob',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomeScreen(),
    );
  }
}