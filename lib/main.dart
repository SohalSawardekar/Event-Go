import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Event Go",
      home: Scaffold(
        appBar: AppBar(title: const Text("Event Go")),
        body: const Center(
          child: Image(
            image: AssetImage("assets/logo/EventGo.png"),
          ),
        ),
      ),
    );
  }
}
