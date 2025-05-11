import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

//https://onlyflutter.com/how-to-build-better-forms-in-flutter/

class FilterView extends StatelessWidget {
  FilterView({super.key});

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
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
                      decoration:
                          const InputDecoration(labelText: 'Тип объявления'),
                      items: [
                        {'value': 'ad_look', 'name': 'Ищу на подселение'},
                        {'value': 'ad_go', 'name': 'Пойду на подселение'},
                      ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item['value'],
                              child: Text(item['name']!),
                            ),
                          )
                          .toList(),
                    ),
                    /// City
                    FormBuilderDropdown(
                      name: 'city',
                      decoration:
                          const InputDecoration(labelText: 'Город'),
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
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: ElevatedButton(
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
                              child: const Text('Показать результаты')),
                        ))
                  ])),
        ));
  }
}
