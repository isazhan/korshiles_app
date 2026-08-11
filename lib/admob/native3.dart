import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../globals.dart' as globals;


class NativeAdWidget3 extends StatefulWidget {
  const NativeAdWidget3({super.key});

  @override
  State<NativeAdWidget3> createState() => _NativeAdWidget3State();
}

class _NativeAdWidget3State extends State<NativeAdWidget3> {
  NativeAd? _nativeAd;
  bool _loaded = false;

  String get _adUnitId => Platform.isAndroid
      ? 'ca-app-pub-5754778099148012/3482879151'
      : 'ca-app-pub-5754778099148012/9515553008';

  @override
  void initState() {
    super.initState();

    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(error.toString());
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: globals.myColor,
          style: NativeTemplateFontStyle.bold,
          size: 16,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _nativeAd == null) {
      return const SizedBox(height: 130);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 90,
          maxHeight: 120,
        ),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}