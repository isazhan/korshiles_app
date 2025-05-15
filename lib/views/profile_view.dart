import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access');
    return accessToken != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const Center(child: Text('Profile screen'));
        } else {
          Future.microtask(() {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LoginView()),
            );
          });
          return const SizedBox(); // placeholder
        }
      },
    );
  }
}