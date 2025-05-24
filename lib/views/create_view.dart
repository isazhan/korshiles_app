import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_view.dart';
import '../requests/api.dart';


class CreateView extends StatefulWidget {
  const CreateView({super.key});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _loading = false;
  String? _error;
  final _adtest = TextEditingController();


  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access');
    return accessToken != null;
  }  

  Future<void> _createAd() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await ApiService().createAd(
      _adtest.text,
    );
    print(response);
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
                      'Страница в разработке',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  /*
                  TextField(
                    controller: _adtest,
                    decoration: const InputDecoration(labelText: 'Номер телефона'),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: _loading ? null : _createAd,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                  */
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