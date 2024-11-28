import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:korshiles_app/requests/api.dart';

class AdView extends StatelessWidget {
  final String ad;

  AdView({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().getAd(ad),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            return Center(child: Text(data['info']));
          }
        },
      ),
    );
  }
}
