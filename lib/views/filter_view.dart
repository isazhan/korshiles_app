import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:korshiles_app/requests/api.dart';

class FilterView extends StatelessWidget {
  FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Form(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextFormField(),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton(
                  onPressed: () {
                    ApiService().getFilter();
                  },
                  child: const Text('Показать результаты')),
            ))
      ])),
    );
  }
}
