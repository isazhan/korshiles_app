import 'package:flutter/material.dart';
import '../views/ad_view.dart';
import 'package:intl/intl.dart';

class AdCardMy extends StatelessWidget {
  final String title;
  final String ad;
  final String photos;
  final String city;
  final String district;  
  final String description;
  final String views;
  final String date;
  final bool publish;

  const AdCardMy({
    Key? key,
    required this.title,
    required this.ad,
    required this.photos,
    required this.city,
    required this.district,
    required this.description,
    required this.views,
    required this.date,
    required this.publish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdView(ad: ad)),
            );
          },
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Ad number
                  Text(
                    '#'+ad,
                    style: TextStyle(
                      fontSize: 12,
                      //fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  publish
                    ? Text(
                      'Опубликовано',
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.green,
                        fontSize: 12,
                      ),
                    )
                    : Text(
                      'На проверке',
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.orange,
                        fontSize: 12,
                      ),
                    )
                ],
              ),

              Row(
                children: <Widget>[
                    photos != 'no'
                        ? Image.network(photos, height: 100, width: 150, fit: BoxFit.cover,)
                        : Image.asset('static/img/no-image.png', height: 100, width: 150, fit: BoxFit.cover),
                  const SizedBox(width: 10),
                  Flexible(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: <Widget>[
                        Text(city),
                        Text(district),
                        const SizedBox(height: 16),
                        Text(
                          description,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.grey, size: 16),
                            Text(views),
                            Spacer(),
                            Text(
                              DateFormat('d.MM.yyyy').format(DateTime.parse(date)).toString(),
                            ),
                          ],
                        ),
                      ]))
                ],
              )
            ],
          )));
  }
}