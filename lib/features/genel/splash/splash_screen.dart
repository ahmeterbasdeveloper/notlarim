import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notlarim/core/localization/localization.dart';

// Login sayfasının doğru yolu (proje yapınıza göre kontrol edin)
import '../../kullanicilar/presentation/pages/loginpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Uygulama yüklenme işlemleri bittiğinde (burada 2 sn simüle ediyoruz)
    Timer(const Duration(seconds: 2), () {
      // Login ekranına yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Native Splash zaten ekranda olduğu için burası çok kısa görünecek
    // Kullanıcıya akıcı bir geçiş hissi vermek için aynı logoyu buraya da koyabiliriz
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icon_aap_kurt1.png',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 20),
            // Yazı ve loading indicator, native splashtan sonra görünecek
            Text(
              AppLocalizations.of(context).translate('app_description'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
