import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unit_converter/ads/Ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Unit Converter',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'درهم ريال فرنك',
            ),
          ),
          body: HomeScreen(),
        ));
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double height = 0, width = 0;
  BannerAd? bannerAd;
  bool isloaded = false;
  final AdSize _adSize = AdSize.largeBanner;

  InterstitialAd? _interstitialAd;
  int maxFailedLoadAttempts = 3;
  int _numInterstitialLoadAttempts = 0;

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Ads.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    bannerAd = BannerAd(
      adUnitId: Ads.bannerAdUnitId,
      request: AdRequest(),
      size: _adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isloaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    bannerAd!.load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Widget checkForAd() {
    if (isloaded == true) {
      return Container(
        height: _adSize.height.toDouble(),
        width: _adSize.width.toDouble(),
        child: AdWidget(
          ad: bannerAd!,
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
  final TextStyle labelStyle = TextStyle(
    fontSize: 16.0,
  );
  final TextStyle resultSyle = TextStyle(
    color: Colors.teal,
    fontSize: 25.0,
    fontWeight: FontWeight.w700,
  );

  final List<String> _mesaures = [
    'درهم',
    'ريال',
    'فرنك',
  ];

  double _value;
  String _fromMesaures = 'درهم';
  String _toMesaures = 'ريال';
  String _results = "";

  final Map<String, int> _mesauresMap = {
    'درهم': 0,
    'ريال': 1,
    'فرنك': 2,
  };

  dynamic _formulas = {
    '0': [1, 20, 100],
    '1': [0.05, 1, 5],
    '2': [0.01, 0.2, 1],
  };
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 50.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'أدخل القيمة',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              validator: (v) =>
                  num.tryParse(v) == null ? "قيمة غير صحيحة" : null,
              onChanged: (value) {
                setState(() {
                  _value = double.parse('${value}');
                });
              },
            ),
            SizedBox(height: 25.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الى', style: labelStyle),
                    DropdownButton(
                      items: _mesaures
                          .map((String value) => DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _toMesaures = value;
                        });
                      },
                      value: _toMesaures,
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'من',
                      style: labelStyle,
                    ),
                    DropdownButton(
                      items: _mesaures
                          .map((String value) => DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _fromMesaures = value;
                        });
                      },
                      value: _fromMesaures,
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 25.0),
            isloaded
                ? Container(
                    height: 50,
                    child: AdWidget(
                      ad: bannerAd,
                    ),
                  )
                : SizedBox(height: 25.0),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: () {
          _showInterstitialAd();
          _convert();
        },
              child: Text(
                'تحويل',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 10),
            checkForAd(),
            SizedBox(width: width),
            SizedBox(height: 50.0),
            Text(
              _results,
              style: resultSyle,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  void _convert() {
    print('Button Clicked');
    print(_value);

    if (_value != 0 && _fromMesaures.isNotEmpty && _toMesaures.isNotEmpty) {
      int from = _mesauresMap[_fromMesaures];
      int to = _mesauresMap[_toMesaures];

      var multiplier = _formulas[from.toString()][to];

      setState(() {
        _results =
            "$_value $_fromMesaures = ${_value * multiplier} $_toMesaures";
      });
    } else {
      setState(() {
        _results = "ادخل قيمة صحيحة";
      });
    }
  }
}
