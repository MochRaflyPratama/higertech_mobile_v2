import 'package:flutter/material.dart';

class  Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Higertech Tracking'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}