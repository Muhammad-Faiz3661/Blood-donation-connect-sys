import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BloodDonationApp());
}

class BloodDonationApp extends StatefulWidget {
  const BloodDonationApp({super.key});

  @override
  State<BloodDonationApp> createState() => _BloodDonationAppState();
}

class _BloodDonationAppState extends State<BloodDonationApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC83B50),
          brightness: Brightness.light,
          primary: const Color(0xFFC83B50),
          onPrimary: Colors.white,
          secondary: const Color(0xFF167D72),
          surface: const Color(0xFFFFFDFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F5F1),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF24212F),
              displayColor: const Color(0xFF24212F),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F5F1),
          foregroundColor: Color(0xFF24212F),
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFDFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE8E2DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFC83B50), width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEEE8E2)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 72,
          backgroundColor: Color(0xFFFFFDFC),
          indicatorColor: Color(0xFFF8DEE3),
          elevation: 8,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final currentUser = _controller.currentUser;
          if (currentUser == null) {
            return OnboardingScreen(controller: _controller);
          }
          return HomeScreen(controller: _controller);
        },
      ),
    );
  }
}