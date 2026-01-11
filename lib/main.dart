import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:korshiles_app/requests/auth.dart';
import 'views/home_view.dart';
import 'views/create_view.dart';
import 'views/profile_view.dart';
import 'views/login_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'globals.dart' as globals;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) unawaited(MobileAds.instance.initialize());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState(); 
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('kk');

  void changeLanguage(String lang) {
    setState(() {
      _locale = Locale(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korshiles',
      locale: _locale,
      supportedLocales: const [
        Locale('kk'),
        Locale('ru'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
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
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeView(),
      CreateView(onSuccess: goToProfile),
      ProfileView(),
    ];
  }

  void goToProfile() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _onItemTapped(int index) async {
    if (index != 0) {
      final loggedIn = await AuthService().isLoggedIn();
      if (!loggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: globals.myColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: lang == 'kk' ? 'Басты' : 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: lang == 'kk' ? 'Жариялау' : 'Подать'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: lang == 'kk' ? 'Профиль' : 'Профиль'),
        ],
      ),
    );
  }
}