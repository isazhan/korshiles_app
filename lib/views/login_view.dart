/*
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MyHomePage()),
              (route) => false,
            );
          },
        ),
        title: const Text('Login'),
      ),
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
*/


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../requests/api.dart';
import '../main.dart';
import '../widgets/bar.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();

  bool _showCodeField = false;
  bool _showPasswordField = false;
  bool _showNewPasswordField = false;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() {
        _loading = false;
        _error = 'Номер телефона должен содержать 10 цифр.';
      });
      return;
    }

    final response = await ApiService().login(
      '7$phone',
      _codeController.text.trim(),
      _passwordController.text.trim(),
      _newPasswordController.text.trim(),
    );

    setState(() => _loading = false);

    switch (response['status']) {
      case 'code_sent':
        setState(() => _showCodeField = true);
        break;
      case 'user_exist':
        setState(() => _showPasswordField = true);
        break;
      case 'code_accept':
        setState(() {
          _showCodeField = false;
          _codeController.clear();
          _showNewPasswordField = true;
        });
        break;
      case 'login':
        await _secureStorage.write(key: 'access', value: response['access']);
        await _secureStorage.write(key: 'refresh', value: response['refresh']);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
        break;
      case 'password_wrong':
        setState(() => _error = 'Неверный пароль.');
        break;
      case 'code_wrong':
        setState(() => _error = 'Неверный код верификации.');
        break;
      default:
        setState(() => _error = 'Ошибка входа. Попробуйте снова.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(exit: true,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              //margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.only(left: 10),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text('Вход в личный кабинет',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ), 
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(left: 10),
              //height: 40,
              decoration: BoxDecoration(
                color: Color.fromRGBO(207, 226, 255, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Прежде чем продолжить, поделитесь своим номером телефона с нашим ботом в Telegram: \n',
                        style: TextStyle(
                          fontSize: 14,
                          //fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '@korshiles_bot \n\n',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async{
                            final Uri url = Uri(scheme: 'https', host: 't.me', path: 'korshiles_bot');
                            print(url.toString());
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          }
                      ),
                      TextSpan(
                        text: 'Так мы сможем отправить вам код верификации.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                ),
              ), 
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(left: 10),
              //height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Номер телефона',
                    prefixText: '+7',
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ), 
            ),
            if (_showCodeField)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(left: 10),
                //height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      labelText: 'Код верификации',
                      //prefixText: '+7',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ), 
              ),
            if (_showPasswordField)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(left: 10),
                //height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _passwordController,
                    //keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      //prefixText: '+7',
                      border: InputBorder.none,
                      //counterText: '',
                    ),
                  ),
                ), 
              ),
            if (_showNewPasswordField)
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.only(left: 10),
                //height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _newPasswordController,
                    //keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Придумайте пароль',
                      //prefixText: '+7',
                      border: InputBorder.none,
                      //counterText: '',
                    ),
                  ),
                ), 
              ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(22, 151, 209, 1),
                foregroundColor: Colors.white,
              ),
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                  : const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}