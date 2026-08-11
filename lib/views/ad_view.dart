import 'package:flutter/material.dart';
import '../widgets/bar.dart';
import 'package:korshiles_app/requests/api.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admob/native0.dart';


class AdView extends StatelessWidget {
  final String ad;

  AdView({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: globals.myBackColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService().justGet('api/ad', {'ad': ad}),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            final title = data['type'][lang] as String? ?? 'No Title';
            final images = (data['photos'] as List?)?.cast<String>() ?? [];
            final city = data['city']['ru'] as String? ?? 'No city';
            final district = (data['district'] != '')
                ? data['district']['ru'] as String
                : '';
            final address = data['address'] as String? ?? 'No address';
            final contact = data['contact'] as String? ?? 'No contact';
            final description = data['info'] as String? ?? 'No description';
            final ad = data['ad'].toString() as String? ?? '0';

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Title
                _cont(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text("#$ad",
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
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
                          globals.host + imageUrl.toString(),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 300.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      enableInfiniteScroll: false
                    ),
                  ),
                //else
                  //Image.asset('static/img/no-image.png'),
                const SizedBox(height: 16),

                NativeAdWidget0(),

                //const SizedBox(height: 16),

                // city
                Row(
                  children: [
                    // City
                    Expanded(
                      child: _cont(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang=='kk' ? 'Қала' : 'Город',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            )),
                            Text(city,
                            style: TextStyle(
                              fontSize: 16                          
                            )),
                          ]
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

                    // District
                    Expanded(
                      child: _cont(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang=='kk' ? 'Аудан' : 'Район',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            )),
                            Text(district,
                            style: TextStyle(
                              fontSize: 16                          
                            )),
                          ]
                        ),
                      ),
                    )

                  ],
                ),

                SizedBox(height: 10),

                // address
                _cont(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang=='kk' ? 'Мекенжай' : 'Адрес',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                      Text(address,
                      style: TextStyle(
                        fontSize: 16                          
                      )),
                    ]
                  ),
                ),

                SizedBox(height: 10),

                // contact
                _cont(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang=='kk' ? 'Байланыс' : 'Контакты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                      Row(
                        children: [
                          Text(
                            '+' + contact.substring(0, 1) + ' ' + contact.substring(1, 4) + ' ' + contact.substring(4, 7) + ' ' + contact.substring(7, 9) + ' ' + contact.substring(9, 11),
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.blue),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: '+'+contact));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(lang=='kk' ? 'Байланыс номері көшірілді' : 'Контакт скопирован в буфер обмена')),
                              );
                            },
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri(
                            scheme: 'https',
                            host: 'wa.me',
                            path: contact,
                            queryParameters: {
                              'text': lang == 'kk' 
                                  ? 'Сәлем! "Көршілестен" хабарласып тұрмын.' 
                                  : 'Привет! Пишу из "Көршілес".',
                            },
                          );

                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: Text(
                          lang == 'kk' ? 'WhatsApp-қа жазу' : 'Написать в WhatsApp',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 37, 211, 102),
                        ),
                      )
                    ]
                  ),
                ),
                
                const SizedBox(height: 16),

                // Description
                _cont(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang=='kk' ? 'Сипаттама' : 'Описание',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 10),
                      Text(description,
                      style: TextStyle(
                        fontSize: 16                          
                      )),
                    ]
                  ),
                ),                

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final Uri url = Uri(scheme: 'https', host: 't.me', path: 'korshiles');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(lang=='kk' ? 'Хабарландыруға шағымдану' : 'Пожаловаться на объявление'),
                )
              ],
            );
          }
        },
      ),
    );
  }


  // Common container
  Widget _cont({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
