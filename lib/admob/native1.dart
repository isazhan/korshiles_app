import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _loaded = false;

  String get _adUnitId => Platform.isAndroid
      ? 'ca-app-pub-5754778099148012/5554322073'
      : 'ca-app-pub-5754778099148012/5535535308';

  @override
  void initState() {
    super.initState();

    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      factoryId: 'listTile',
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
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        height: 160,
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}