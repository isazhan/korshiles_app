import 'package:flutter/material.dart';
import '../widgets/bar.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Text(
          'Welcome to Profile Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
