import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../globals.dart' as globals;
import '../requests/api.dart';
import '../requests/auth.dart';
import '../widgets/bar.dart';
import 'my_ads_view.dart';


class CreateView extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CreateView({super.key, this.onSuccess});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormBuilderState>();

  bool _loading = false;
  String? _error;

  List<dynamic> _cities = [];
  List<dynamic> _districts = [];
  List<dynamic> _adTypes = [];

  late Future<bool> _isLoggedInFuture;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  static const int maxImages = 5;

  

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = AuthService().isLoggedIn();
    loadJson();
  }


  Future<void> loadJson() async {
    final String jsonString = await rootBundle.loadString('static/cities.json');
    final data = json.decode(jsonString);

    setState(() {
      _cities = data['cities'] ?? [];
      _adTypes = data['ad_types'] ?? [];
    });
  }

  void _onCitySelected(String? value) {
    if (value == null) return;

    final city = _cities.firstWhere(
      (c) => c['id'] == value,
      orElse: () => null,
    );

    if (city == null) return;

    setState(() {
      _districts = city['districts'] ?? [];
    });

    _formKey.currentState?.fields['district']?.reset();
  }


  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (picked.isEmpty) return;

    setState(() {
      final remaining = maxImages - _images.length;
      _images.addAll(picked.take(remaining));
    });
  }


  Future<void> _createAd() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.saveAndValidate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final values = formState.value;

    final response = await ApiService().postMultipartWithAuth('api/api_create_ad', {
      'type': values['type'],
      'city': values['city'],
      'district': values['district'],
      'address': values['address'],
      'info': values['description'],
      'contact': '7${values['contact']}',
    },
      _images
    );

    setState(() => _loading = false);

    if (response['status'] == 'ok') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Хабарландыру сәтті берілді!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onSuccess?.call(); //go to profile tab

      final username = await AuthService().loadUserName();

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MyAdsView(user: username,)),
      );

    } else {
      setState(() {
        _error = response['status'] ?? 'Произошла ошибка';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    
    return FutureBuilder<bool>(
      future: _isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data != true) {
          return const SizedBox();
        }

        return Scaffold(
          appBar: CustomAppBar(),
          backgroundColor: globals.myBackColor,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: _formKey,
              child: ListView(
              //shrinkWrap: true,
                children: [

                  // Tittle
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
                      child: Text(lang=='kk' ? 'Хабарландыру беру' : 'Подать объявление',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ), 
                  ),

                  // Ad type
                  _dropdown(
                    child: FormBuilderDropdown<String>(
                      name: 'type',
                      validator: FormBuilderValidators.required(
                        errorText: lang == 'kk'
                            ? 'Хабарландыру түрін таңдаңыз'
                            : 'Выберите тип объявления',
                      ),
                      decoration: InputDecoration(
                        labelText: lang=='kk' ? 'Хабарландыру түрі' : 'Тип объявления',
                        border: InputBorder.none,
                      ),
                      items: _adTypes
                        .map((ad) => DropdownMenuItem<String>(
                              value: ad['id'],
                              child: Text(ad[lang]),
                            ))
                        .toList(),
                    )
                  ),

                  // City
                  _dropdown(
                    child: FormBuilderDropdown<String>(
                      name: 'city',
                      validator: FormBuilderValidators.required(
                        errorText: lang == 'kk'
                            ? 'Қаланы таңдаңыз'
                            : 'Выберите город',
                      ),
                      decoration: InputDecoration(
                        labelText: lang=='kk' ? 'Қала' : 'Город',
                        border: InputBorder.none,
                      ),
                      items: _cities
                        .map((city) => DropdownMenuItem<String>(
                              value: city['id'],
                              child: Text(city[lang]),
                            ))
                        .toList(),
                      onChanged: _onCitySelected,
                    )
                  ),

                  // District
                  _dropdown(
                    child: FormBuilderDropdown<String>(
                      name: 'district',                      
                      decoration: InputDecoration(
                        labelText: lang=='kk' ? 'Аудан' : 'Район',
                        border: InputBorder.none,
                      ),
                      items: _districts
                        .map((district) => DropdownMenuItem<String>(
                              value: district['id'],
                              child: Text(district[lang]),
                            ))
                        .toList(),
                    )
                  ),

                  // Address
                  _input(
                    child: FormBuilderTextField(
                      name: 'address',
                      decoration: InputDecoration(
                        labelText: lang=='kk' ? 'Мекен-жай' : 'Адрес',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Description                  
                  _input(
                    child: FormBuilderTextField(
                      name: 'description',
                      validator: FormBuilderValidators.required(
                        errorText: lang == 'kk'
                            ? 'Сипаттама жазылуы тиіс'
                            : 'Напишите описание',
                      ),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: lang=='kk' ? 'Сипаттама' : 'Описание',
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // Contact
                  _input(
                    child: FormBuilderTextField(
                      name: 'contact',
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: lang=='kk' ? 'Байланыс' : 'Контакты',
                        prefixText: '+7',
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.equalLength(
                          10,
                          errorText: lang=='kk' ? 'Номер толық жазылмаған' : 'Номер введен не полностью',
                        ),
                      ]),
                    ),
                  ),

                  _imagesPicker(),

                  const SizedBox(height: 10),                

                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _loading ? null : _createAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: globals.myColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(lang=='kk' ? 'Хабарландыру беру' : 'Подать объявление'),
                  ),

                ],
              ),
            ),
          )
        );
      },
    );
  }

  // Common dropdown container
  Widget _dropdown({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  // Common input container
  Widget _input({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  // Image preview widget
  Widget _imagesPicker() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Фото'),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._images.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final file = entry.value;

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(file.path),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _images.removeAt(index));
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              if (_images.length < maxImages)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Icon(Icons.add_a_photo),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

}