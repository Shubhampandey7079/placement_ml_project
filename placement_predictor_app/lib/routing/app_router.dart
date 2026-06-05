import 'package:flutter/material.dart';
import '../core/constants/app_strings.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/prediction/prediction_form_screen.dart';
import '../screens/result/result_screen.dart';
import '../screens/history/history_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppStrings.routeSplash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppStrings.routeHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppStrings.routePredictForm:
        return MaterialPageRoute(builder: (_) => const PredictionFormScreen());
      case AppStrings.routeResult:
        return MaterialPageRoute(builder: (_) => const ResultScreen());
      case AppStrings.routeHistory:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
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
