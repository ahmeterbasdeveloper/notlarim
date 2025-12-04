import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/core/localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/genel/anamenu/ana_menu.dart';
import 'features/genel/splash/splash_screen.dart';

void main() async {
  // ✅ DÜZELTME 1: Doğru method 'WidgetsFlutterBinding' sınıfındadır.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ✅ DÜZELTME 2: Private tip (_MyAppState) yerine genel tip (State<MyApp>) döndürülmeli.
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedLocale', newLocale.languageCode);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('selectedLocale');

    setState(() {
      _locale =
          languageCode != null ? Locale(languageCode) : const Locale('tr');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('tr', ''),
        Locale('de', ''),
        Locale('ar', ''),
        Locale('bn', ''),
        Locale('zh', ''),
        Locale('fa', ''),
        Locale('fr', ''),
        Locale('hi', ''),
        Locale('en', ''),
        Locale('es', ''),
        Locale('it', ''),
        Locale('ja', ''),
        Locale('ko', ''),
        Locale('ms', ''),
        Locale('pa', ''),
        Locale('pt', ''),
        Locale('ru', ''),
        Locale('th', ''),
        Locale('ur', ''),
        Locale('vi', '')
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/main': (context) => const AnaMenuMenuScreen(),
      },
    );
  }
}
