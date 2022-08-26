import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  BannerAd bannerAd;
  bool isLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isLoaded = true;
        });
        print('Banner Ad Loaded');
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
      }),
      request: AdRequest(),
    );
    bannerAd.load();
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: 50.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'أدخل القيمة',
              ),
              onChanged: (value) {
                setState(() {
                  _value = double.parse(value);
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
            isLoaded
                ? Container(
                    height: 50,
                    child: AdWidget(
                      ad: bannerAd,
                    ),
                  )
                : SizedBox(height: 25.0),
            MaterialButton(
              minWidth: double.infinity,
              onPressed: _convert,
              child: Text(
                'تحويل',
                style: TextStyle(color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
            ),
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
