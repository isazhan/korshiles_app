import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bar.dart';
import '../requests/api.dart';
import 'profile_view.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../main.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phonenumberController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newpasswordController = TextEditingController();
  bool _loading = false;
  String? _error;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await ApiService().login(
      _phonenumberController.text,
      _codeController.text,
      _passwordController.text,
      _newpasswordController.text,
    );
    
    setState(() {
      _loading = false;
    });

    if (response['status'] == 'login') {
      await secureStorage.write(key: 'access', value: response['access']);
      await secureStorage.write(key: 'refresh', value: response['refresh']);

      // Replace LoginView with ProfileView
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MyHomePage()),
      );
    } else {
      setState(() {
        _error = 'Login failed. Check your credentials.';
      });
    }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phonenumberController,
              decoration: const InputDecoration(labelText: 'Номер телефона'),
            ),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Код верификации'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            TextField(
              controller: _newpasswordController,
              decoration: const InputDecoration(labelText: 'Придумайте пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}