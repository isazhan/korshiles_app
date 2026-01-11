import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../requests/auth.dart';
import '../globals.dart' as globals;

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


  bool _showCodeField = false;
  bool _showPasswordField = false;
  bool _passwordVisible = true;
  bool _showNewPasswordField = false;
  bool _newPasswordVisible = true;
  bool _loading = false;
  String? _error;
  String forget = '';
  bool _isReadOnlyPhone = false;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
      _isReadOnlyPhone = true;
    });

    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() {
        _loading = false;
        _error = 'Номер телефона должен содержать 10 цифр.';
      });
      return;
    }

    final response = await AuthService().login( // ApiService().login(
      '7$phone',
      _codeController.text.trim(),
      _passwordController.text.trim(),
      _newPasswordController.text.trim(),
      forget,
    );

    setState(() => _loading = false);

    switch (response['status']) {
      case 'code_sent':
        setState(() => _showCodeField = true);
        break;
      case 'user_not_found':
        final Uri url = Uri(scheme: 'https', host: 't.me', path: 'korshiles_bot');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw 'Could not launch $url';
        }
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
        if (!mounted) return;
        Navigator.pop(context); // Close LoginView
        break;
      case 'password_wrong':
        setState(() => _error = 'Неверный пароль.');
        break;
      case 'code_wrong':
        setState(() => _error = 'Неверный код верификации.');
        break;
      case 'new_code_sent':
        setState(() {
          _passwordController.clear();
          _showPasswordField = false;
          _showCodeField = true;
          forget = '';
        });
        break;
      default:
        setState(() => _error = 'Ошибка входа. Попробуйте снова.');
    }
  }

  Future<void> _forgetPassword() async {
    setState(() {
      forget = 'true';
    });

    _login();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: CustomAppBar(exit: true,),
      backgroundColor: globals.myBackColor,
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
                child: Text(lang=='kk' ? 'Жеке кабинетке кіру' : 'Вход в личный кабинет',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  readOnly: _isReadOnlyPhone,
                  decoration: InputDecoration(
                    labelText: lang=='kk' ? 'Телефон номері' : 'Номер телефона',
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
                    decoration: InputDecoration(
                      labelText: lang=='kk' ? 'Растау коды' : 'Код подтверждения',
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ), 
              ),
            if (_showPasswordField)
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
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
                    keyboardType: TextInputType.text,
                    obscureText: _passwordVisible,
                    decoration: InputDecoration(
                      labelText: lang=='kk' ? 'Құпия сөз' : 'Пароль',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                        )
                    ),
                  ),
                ), 
              ),
            if (_showPasswordField)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: globals.myColor,
                  side: BorderSide(width: 1.0, color: globals.myColor),
                  fixedSize: const Size.fromHeight(40),
                  //fixedSize: Size(50, 50),
                ),
                onPressed: _loading ? null : _forgetPassword,
                child: _loading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                    : Text(lang=='kk' ? 'Құпия сөзді ұмыттыңыз ба?' : 'Забыли пароль?'),
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
                    obscureText: _newPasswordVisible,
                    decoration: InputDecoration(
                      labelText: lang=='kk' ? 'Құпия сөз ойлап табыңыз' : 'Придумайте пароль',
                      //prefixText: '+7',
                      border: InputBorder.none,
                      //counterText: '',
                      suffixIcon: IconButton(
                        icon: Icon(_newPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _newPasswordVisible = !_newPasswordVisible;
                          });
                        },
                        )
                    ),
                  ),
                ), 
              ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.only(left: 10),
              //height: 40,
              //decoration: BoxDecoration(
                //color: Color.fromRGBO(207, 226, 255, 1),
                //borderRadius: BorderRadius.circular(10),
              //),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: lang=='kk' ? 'Жалғастыра отырып сіз қабылдайсыз: \n' : 'Продолжая вы принимаете \n',
                      style: TextStyle(
                        fontSize: 14,
                        //fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: lang=='kk' ? 'Пайдаланушы келісімі' : 'Пользовательское соглашение',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async{
                          final Uri url = Uri(scheme: 'https', host: 'korshiles.kz', path: 'terms');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }
                    ),
                  ],
                )
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: globals.myColor,
                foregroundColor: Colors.white,
                fixedSize: const Size.fromHeight(40),
              ),
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                  : Text(lang=='kk' ? 'Жалғастыру' : 'Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}