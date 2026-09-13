import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Don Savio Thomas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E1E)),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const HomeScreen(isWallpaper: false),
        '/wallpaper': (context) => const HomeScreen(isWallpaper: true),
      },
    );
  }
}

