import 'dart:io' as io;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ads {
  static bool _testMode = true;

  ///
  static String get appId {
    if (io.Platform.isAndroid) {
      return "";
    } else {
      throw new UnsupportedError("UnsupportedError");
    }
  }

  static String get bannerAdUnitId {
    if (_testMode == true) {
      return BannerAd.testAdUnitId;
    } else if (io.Platform.isAndroid) {
      return "";
    } else {
      throw new UnsupportedError("UnsupportedError");
    }
  }

  static String get interstitialAdUnitId {
    if (_testMode == true) {
      return InterstitialAd.testAdUnitId;
    } else if (io.Platform.isAndroid) {
      return "";
    } else {
      throw new UnsupportedError("UnsupportedError");
    }
  }

  static String get nativeAdUnitId {
    if (_testMode == true) {
      return "----------";
    } else if (io.Platform.isAndroid) {
      return "----------";
    } else {
      throw new UnsupportedError("UnsupportedError");
    }
  }
}
