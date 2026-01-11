import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../globals.dart' as globals;

//https://onlyflutter.com/how-to-build-better-forms-in-flutter/

class FilterView extends StatelessWidget {
  FilterView({super.key});

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
        appBar: CustomAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormBuilderDropdown(
                      name: 'type',
                      decoration: InputDecoration(
                        labelText: lang=='kk'
                          ? 'Хабарландыру түрі'
                          : 'Тип объявления',
                      ),
                      items: [
                        {'value': 'ad_look', 'kk': 'Көршілес іздеймін', 'ru': 'Ищу на подселение'},
                        {'value': 'ad_go', 'kk': 'Көршілес боламын', 'ru': 'Пойду на подселение'},
                      ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item['value'],
                              child: Text(item[lang]!),
                            ),
                          )
                          .toList(),
                    ),
                    /// City
                    FormBuilderDropdown(
                      name: 'city',
                      decoration: InputDecoration(
                        labelText: lang=='kk'
                          ? 'Қала'
                          : 'Город',
                      ),
                      items: [
                        {'value': '1', 'name': 'Алматы'},
                        {'value': '2', 'name': 'Астана'},
                        {'value': '3', 'name': 'Шымкент'},
                      ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item['value'],
                              child: Text(item['name']!),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: globals.myColor,
                          foregroundColor: Colors.white,
                          fixedSize: const Size.fromHeight(40),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.saveAndValidate()) {
                            //print(_formKey.currentState!.value['type']);
                            final filters = {
                              'type': _formKey.currentState!.value['type'],
                              'city': _formKey.currentState!.value['city'],
                              'page': '1',
                            };
                            //ApiService().getAds({'type': 'ad_go'});
                            Navigator.pop(context, filters);
                          }
                        },
                        child: Text(lang=='kk' ? 'Нәтижелерді көрсету' : 'Показать результаты')),
                    )
                  ])
          ),
        )
    );
  }
}