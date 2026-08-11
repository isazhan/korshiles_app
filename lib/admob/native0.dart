import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../globals.dart' as globals;


class NativeAdWidget0 extends StatefulWidget {
  const NativeAdWidget0({super.key});

  @override
  State<NativeAdWidget0> createState() => _NativeAdWidget0State();
}

class _NativeAdWidget0State extends State<NativeAdWidget0> {
  NativeAd? _nativeAd;
  bool _loaded = false;

  String get _adUnitId => Platform.isAndroid
      ? 'ca-app-pub-5754778099148012/6034000811'
      : 'ca-app-pub-5754778099148012/5117142990';

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