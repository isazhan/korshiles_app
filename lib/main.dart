import 'package:flutter/material.dart';
import 'views/home_view.dart';
import 'views/create_view.dart';
import 'views/profile_view.dart';
import 'views/login_view.dart';
import 'widgets/nav.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'controllers/nav_controller.dart';
import 'controllers/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) unawaited(MobileAds.instance.initialize());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korshiles',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeView(),
    CreateView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: navIndexNotifier,
        builder: (_, index, __) => _screens[index],
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: navIndexNotifier,
        builder: (_, index, __) {
          return CustomBottomNav(
            selectedIndex: index,
            onItemTapped: (newIndex) {
              if ((newIndex == 1 || newIndex == 2) && !AuthController.isLoggedIn) {
                AuthController.pendingTabIndex = newIndex;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginView()),
                );
                return;
              }
              navIndexNotifier.value = newIndex;
            },
          );
        },
      ),
    );
  }
}
