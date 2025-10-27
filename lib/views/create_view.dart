import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../controllers/nav_controller.dart';
import '../requests/api.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';


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

      navIndexNotifier.value = 2; // Switch to ProfileView

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
      future: ApiService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: CustomAppBar(),
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
                            const InputDecoration(labelText: 'Тип объявления'),
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
                            const InputDecoration(labelText: 'Город'),
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
                            const InputDecoration(labelText: 'Район'),
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
                      decoration: const InputDecoration(labelText: 'Адрес'),
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
                      decoration: const InputDecoration(labelText: 'Описание'),
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
                      ),
                    ),
                  ),
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