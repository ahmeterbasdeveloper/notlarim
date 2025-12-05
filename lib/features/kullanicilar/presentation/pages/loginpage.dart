import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart'; // ✅ Eklendi
import '../../../../core/localization/localization.dart';

// Ana Menü
import '../../../genel/anamenu/ana_menu.dart';

// ✅ DI Providers
import '../providers/kullanici_di_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _versionInfo = ""; // ✅ Versiyon bilgisini tutacak değişken

  @override
  void initState() {
    super.initState();
    _loadAppVersion(); // ✅ Versiyonu yükle
  }

  // ✅ Versiyon bilgisini çeken fonksiyon
  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        // Örn: v1.0.0 (12)
        _versionInfo = "v${info.version} (${info.buildNumber})";
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ... (Giriş İşlemi Kodu Aynen Kalıyor - _submitLogin) ...
  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final bool isSuccess =
          await ref.read(loginUserProvider).call(username, password);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Giriş başarılı, yönlendiriliyorsunuz...'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AnaMenuMenuScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Kullanıcı adı veya şifre hatalı!")),
            ]),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Bir hata oluştu: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 🔒 ŞİFREMİ UNUTTUM İŞLEMLERİ (GÜNCELLENDİ)
  // ---------------------------------------------------------------------------
  void _showForgotPasswordDialog() {
    final usernameController = TextEditingController();
    // E-posta yerine Güvenlik Kodu Controller
    final securityCodeController = TextEditingController();
    final newPassController = TextEditingController();

    final formKeyDialog = GlobalKey<FormState>();
    bool isVerified = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                isVerified ? "Yeni Şifre Belirle" : "Hesap Doğrulama",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF4E125C)),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKeyDialog,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isVerified) ...[
                        // --- 1. AŞAMA: KULLANICI ADI VE GÜVENLİK KODU ---
                        const Text(
                          "Lütfen hesabınızı doğrulamak için Kullanıcı Adınızı ve Güvenlik Kodunuzu giriniz.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),

                        // Kullanıcı Adı Input
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Boş bırakılamaz'
                              : null,
                        ),
                        const SizedBox(height: 15),

                        // Güvenlik Kodu Input (Değiştirilen Kısım)
                        TextFormField(
                          controller: securityCodeController,
                          keyboardType:
                              TextInputType.number, // Sadece sayısal klavye
                          obscureText:
                              true, // Güvenlik kodu olduğu için gizliyoruz
                          decoration: const InputDecoration(
                            labelText: 'Güvenlik Kodu',
                            prefixIcon: Icon(Icons.security), // İkon değişti
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Boş bırakılamaz'
                              : null,
                        ),
                      ] else ...[
                        // --- 2. AŞAMA: YENİ ŞİFRE ---
                        const Text(
                          "Bilgiler doğrulandı. Lütfen yeni şifrenizi giriniz.",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: newPassController,
                          decoration: const InputDecoration(
                            labelText: 'Yeni Şifre',
                            prefixIcon: Icon(Icons.lock_reset),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (v) => (v == null || v.length < 4)
                              ? 'En az 4 karakter olmalı'
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      const Text("İptal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E125C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (formKeyDialog.currentState!.validate()) {
                      if (!isVerified) {
                        // === DOĞRULAMA İŞLEMİ ===
                        try {
                          // verifyUser provider çağırılıyor (Artık güvenlik kodu ile)
                          final exists =
                              await ref.read(verifyUserProvider).call(
                                    usernameController.text.trim(),
                                    securityCodeController.text.trim(),
                                  );

                          if (exists) {
                            setStateDialog(() => isVerified = true);
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Kullanıcı adı veya Güvenlik Kodu hatalı!"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          debugPrint("Hata: $e");
                        }
                      } else {
                        // === ŞİFRE GÜNCELLEME İŞLEMİ ===
                        try {
                          await ref.read(updatePasswordProvider).call(
                                usernameController.text.trim(),
                                newPassController.text.trim(),
                              );

                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Şifreniz başarıyla güncellendi! Lütfen giriş yapın."),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint("Şifre güncelleme hatası: $e");
                        }
                      }
                    }
                  },
                  child: Text(isVerified ? "Şifreyi Güncelle" : "Doğrula"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🎨 UI TASARIMI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER KISMI ---
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4E125C), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2)
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit_note,
                              size: 50, color: Color(0xFF4E125C)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Notlarım",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        loc.translate('general_welcome') ??
                            "Tekrar Hoş Geldiniz!",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- FORM ALANI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Kullanıcı Adı
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: _buildInputDecoration(
                        label: 'Kullanıcı Adı',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Lütfen kullanıcı adınızı girin'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Şifre
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _buildInputDecoration(
                        label: 'Şifre',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Lütfen şifrenizi girin'
                          : null,
                    ),

                    // Şifremi Unuttum Butonu
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text("Şifremi Unuttum?",
                            style: TextStyle(
                                color: Color(0xFF4E125C),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Giriş Butonu
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _submitLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4E125C),
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shadowColor:
                                    const Color(0xFF4E125C).withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                            ),
                          ),

                    const SizedBox(height: 40),

                    // ✅ VERSİYON BİLGİSİ (EN ALTA EKLENDİ)
                    Text(
                      _versionInfo,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20), // En altta biraz boşluk
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF4E125C)),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4E125C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
