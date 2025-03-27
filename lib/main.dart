import 'package:event_go/screens/favorites.dart';
import 'package:event_go/screens/home.dart';
import 'package:event_go/screens/landing.dart';
import 'package:event_go/screens/location.dart';
import 'package:event_go/screens/login.dart';
import 'package:event_go/screens/register.dart';
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
      initialRoute: "/",
      routes: {
        "/": (context) => const LandingPage(),
        "/login": (context) => LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/home;": (context) => const HomePage(),
        "/location": (context) => const Location(),
        "/favorites": (context) => const Favorites(),
      },
    );
  }
}
