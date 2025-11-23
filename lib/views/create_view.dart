import 'package:flutter/material.dart';
import 'package:korshiles_app/views/my_ads_view.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../requests/api.dart';
import '../requests/auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../globals.dart' as globals;


class CreateView extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CreateView({super.key, this.onSuccess});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _loading = false;
  String? _error;
  final _adtest = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  List<dynamic> _adTypes = [];
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedAdType;
  String _Address = '';
  

  @override
  void initState() {
    super.initState();
    loadJson();
  }


  Future<void> loadJson() async {
    final String jsonString = await rootBundle.loadString('static/cities.json');
    final data = json.decode(jsonString);

    setState(() {
      _cities = data['cities'];
      _adTypes = data['ad_types'];
    });
  }

  void _onCitySelected(String? value) {
    setState(() {
      _selectedCity = value;
      _districts = _cities
          .firstWhere((city) => city['id'] == value)['districts'];
      _selectedDistrict = null;
      //_Address = value!;
    });
  }

  Future<void> _createAd() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = _contactController.text.trim();
    if (phone.length != 10) {
      setState(() {
        _loading = false;
        _error = 'Номер телефона должен содержать 10 цифр.';
      });
      return;
    }

    final response = await ApiService().postWithAuth('api/api_create_ad', {
      'type': _selectedAdType ?? '',
      'city': _selectedCity ?? '',
      'district': _selectedDistrict ?? '',
      'address': _addressController.text,
      'info': _descriptionController.text,
      'contact': _contactController.text,
    });

    if (response['status'] == 'ok') {
      setState(() {
        _loading = false;
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Объявление успешно создано'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSuccess?.call(); //go to profile tab

      final username = await AuthService().loadUserName();

      Future.microtask(() {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MyAdsView(user: username,)),
        );
      });
      return;

    } else {
      setState(() {
        _loading = false;
        _error = response['status'] ?? 'Произошла ошибка';
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    _adtest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: CustomAppBar(),
            backgroundColor: globals.myBackColor,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
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
                      child: Text('Подать объявление',
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
                      child: FormBuilderDropdown(
                        name: 'type',
                        initialValue: _selectedAdType,
                        validator: (value) => value == null
                            ? 'Пожалуйста, выберите тип объявления'
                            : null,
                        decoration:
                            const InputDecoration(
                              labelText: 'Тип объявления',
                              border: InputBorder.none,
                            ),
                        items: _adTypes
                          .map((ad) => DropdownMenuItem<String>(
                                value: ad['id'],
                                child: Text(ad['ru']),
                              ))
                          .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAdType = value;
                          });
                        },
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
                      child: FormBuilderDropdown(
                        name: 'city',
                        initialValue: _selectedCity,
                        decoration:
                            const InputDecoration(
                              labelText: 'Город',
                              border: InputBorder.none,
                            ),
                        items: _cities
                          .map((city) => DropdownMenuItem<String>(
                                value: city['id'],
                                child: Text(city['ru']),
                              ))
                          .toList(),
                        onChanged: _onCitySelected,
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
                      child: FormBuilderDropdown(
                        initialValue: _selectedDistrict,
                        name: 'district',
                        decoration:
                            const InputDecoration(
                              labelText: 'Район',
                              border: InputBorder.none,
                            ),
                        items: _districts
                          .map((district) => DropdownMenuItem<String>(
                                value: district['id'],
                                child: Text(district['ru']),
                              ))
                          .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrict = value;
                          });
                        },
                      ),
                    ), 
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Адрес',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextFormField(
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Контакты',
                        prefixText: '+7',
                        counterText: '',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),

                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _createAd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(22, 151, 209, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Подать объявление'),
                    )
                  ),
                ],
              ),
            ),
          );
        } else {
          
          return const SizedBox(); // placeholder
        }
      },
    );
  }
}