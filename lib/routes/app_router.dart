import 'package:flutter/material.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/event_details_screen.dart';
import '../screens/event_map_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String eventDetails = '/event-details';
  static const String eventMap = '/event-map';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      
      case eventDetails:
        final Map<String, dynamic> args = 
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: args['eventId']),
        );
      
      case eventMap:
        final Map<String, dynamic> args = 
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EventMapScreen(
            latitude: args['latitude'],
            longitude: args['longitude'],
            eventName: args['eventName'],
          ),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}