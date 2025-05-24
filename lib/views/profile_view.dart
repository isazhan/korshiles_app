import 'package:flutter/material.dart';
import 'package:korshiles_app/requests/api.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access');
    return accessToken != null;
  }

  void logout(BuildContext context) async {
    await ApiService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginView()),
      (route) => false,
    );
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
          return Scaffold(
            appBar: CustomAppBar(exit: true,),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Выйти из аккаунта',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => logout(context),
                  ),
                ],
              ),
            ),
          );
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