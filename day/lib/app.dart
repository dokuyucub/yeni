import 'package:flutter/material.dart';

class DayApp extends StatelessWidget {
  const DayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Day',
      home: Scaffold(
        body: Center(
          child: Text('Day'),
        ),
      ),
    );
  }
}
