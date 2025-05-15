import 'package:flutter/material.dart';
import '../widgets/bar.dart';

class CreateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Text(
          'Страница в разработке',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}