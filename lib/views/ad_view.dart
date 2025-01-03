import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:korshiles_app/requests/api.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            final title = data['type']['ru'] as String? ?? 'No Title';
            final images = (data['images'] as List?)?.cast<String>() ?? [];
            final city = data['city']['ru'] as String? ?? 'No city';
            final district = data['district']['ru'] as String? ?? 'No district';
            final address = data['address'] as String? ?? 'No address';
            final contact = data['contact'] as String? ?? 'No contact';
            final description = data['info'] as String? ?? 'No description';

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Image Slider
                if (images.isNotEmpty)
                  CarouselSlider(
                    items: images.map((imageUrl) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 200.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                    ),
                  )
                else
                  Image.asset('static/img/no-image.png'),
                const SizedBox(height: 16),

                // city
                Text(
                  'Город',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  city,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // district
                Text(
                  'Район',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  district,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // address
                Text(
                  'Адрес',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // contact
                Text(
                  'Контакты',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contact,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Описание',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
