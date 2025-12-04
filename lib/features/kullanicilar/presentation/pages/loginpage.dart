import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/core/localization/localization.dart';

// Provider (Login işlemleri için)
import '../providers/login_providers.dart';

// Ana Menü
import '../../../genel/anamenu/ana_menu.dart';

// ✅ DI Providers (verifyUser ve updatePassword provider'larına erişim için)
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Provider'daki fonksiyonu çağırıyoruz
      ref.read(loginProvider.notifier).login(username, password);
    }
  }

  // ---------------------------------------------------------------------------
  // 🔒 ŞİFREMİ UNUTTUM İŞLEMLERİ
  // ---------------------------------------------------------------------------
  void _showForgotPasswordDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final newPassController = TextEditingController();

    // Dialog içinde form kontrolü
    final formKeyDialog = GlobalKey<FormState>();

    // Doğrulama durumu (false: bilgileri sor, true: yeni şifre sor)
    bool isVerified = false;

    showDialog(
      context: context,
      builder: (ctx) {
        // Dialog'un kendi state'ini yönetebilmesi için StatefulBuilder kullanıyoruz
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
                        // --- 1. AŞAMA: KİMLİK DOĞRULAMA ---
                        const Text(
                          "Lütfen hesabınızı doğrulamak için kullanıcı adınızı ve e-posta adresinizi giriniz.",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          // ✅ DÜZELTME: Null check güvenli hale getirildi
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Boş bırakılamaz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          // ✅ DÜZELTME: Null check güvenli hale getirildi
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Boş bırakılamaz';
                            }
                            return null;
                          },
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
                          // ✅ DÜZELTME: Null check güvenli hale getirildi
                          validator: (v) {
                            if (v == null || v.length < 4) {
                              return 'En az 4 karakter olmalı';
                            }
                            return null;
                          },
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
                          // Riverpod ile VerifyUser UseCase çağrısı
                          final exists =
                              await ref.read(verifyUserProvider).call(
                                    usernameController.text.trim(),
                                    emailController.text.trim(),
                                  );

                          if (exists) {
                            setStateDialog(() {
                              isVerified = true; // 2. Aşamaya geç
                            });
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Kullanıcı adı veya e-posta hatalı!"),
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
                          // Riverpod ile UpdatePassword UseCase çağrısı
                          await ref.read(updatePasswordProvider).call(
                                usernameController.text.trim(),
                                newPassController.text.trim(),
                              );

                          if (mounted) {
                            Navigator.pop(ctx); // Dialogu kapat
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

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final loc = AppLocalizations.of(context);

    // Login durumunu dinle (Hata veya Başarı)
    ref.listen(loginProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (next.isSuccess == true) {
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
      }
    });

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
                    // Kullanıcı Adı Input Alanı
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: _buildInputDecoration(
                        label: 'Kullanıcı Adı',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen kullanıcı adınızı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Şifre Input
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        return null;
                      },
                    ),

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
                    loginState.isLoading
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

                    const SizedBox(height: 20),
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
