const String tableKullanicilar = 'kullanicilar';

class KullaniciAlanlar {
  static final List<String> values = [
    id,
    ad,
    soyad,
    cepTelefon,
    email,
    userName,
    password,
    fotoUrl
  ];

  static const String id = '_id';
  static const String ad = 'ad';
  static const String soyad = 'soyad';
  static const String cepTelefon = 'cepTelefon';
  static const String email = 'email';
  static const String userName = 'userName';
  static const String password = 'password';
  static const String fotoUrl = 'fotoUrl';
}

class Kullanicilar {
  final int? id;
  final String ad;
  final String soyad;
  final String cepTelefon;
  final String email;
  final String userName;
  final String password;
  final String fotoUrl;

  const Kullanicilar({
    this.id,
    required this.ad,
    required this.soyad,
    required this.cepTelefon,
    required this.email,
    required this.userName,
    required this.password,
    required this.fotoUrl,
  });

  Kullanicilar copy({
    int? id,
    String? ad,
    String? soyad,
    String? cepTelefon,
    String? email,
    String? userName,
    String? password, // Yeni şifre alanı
    String? fotoUrl,
  }) =>
      Kullanicilar(
        id: id ?? this.id,
        ad: ad ?? this.ad,
        soyad: soyad ?? this.soyad,
        cepTelefon: cepTelefon ?? this.cepTelefon,
        email: email ?? this.email,
        userName: userName ?? this.userName,
        password: password ?? this.password, // Yeni şifre alanı
        fotoUrl: fotoUrl ?? this.fotoUrl,
      );

  static Kullanicilar fromJson(Map<String, Object?> json) => Kullanicilar(
        id: json[KullaniciAlanlar.id] as int?,
        ad: json[KullaniciAlanlar.ad] as String,
        soyad: json[KullaniciAlanlar.soyad] as String,
        cepTelefon: json[KullaniciAlanlar.cepTelefon] as String,
        email: json[KullaniciAlanlar.email] as String,
        userName: json[KullaniciAlanlar.userName] as String,
        password: json[KullaniciAlanlar.password] as String, // Yeni şifre alanı
        fotoUrl: json[KullaniciAlanlar.fotoUrl] as String,
      );

  Map<String, Object?> toJson() => {
        KullaniciAlanlar.id: id,
        KullaniciAlanlar.ad: ad,
        KullaniciAlanlar.soyad: soyad,
        KullaniciAlanlar.cepTelefon: cepTelefon,
        KullaniciAlanlar.email: email,
        KullaniciAlanlar.userName: userName,
        KullaniciAlanlar.password: password,
        KullaniciAlanlar.fotoUrl: fotoUrl,
      };

  static Kullanicilar fromMap(Map<String, dynamic> map) {
    return Kullanicilar(
      id: map[KullaniciAlanlar.id],
      ad: map[KullaniciAlanlar.ad],
      soyad: map[KullaniciAlanlar.soyad],
      cepTelefon: map[KullaniciAlanlar.cepTelefon],
      email: map[KullaniciAlanlar.email],
      userName: map[KullaniciAlanlar.userName],
      password: map[KullaniciAlanlar.password],
      fotoUrl: map[KullaniciAlanlar.fotoUrl],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      KullaniciAlanlar.id: id,
      KullaniciAlanlar.ad: ad,
      KullaniciAlanlar.soyad: soyad,
      KullaniciAlanlar.cepTelefon: cepTelefon,
      KullaniciAlanlar.email: email,
      KullaniciAlanlar.userName: userName,
      KullaniciAlanlar.password: password,
      KullaniciAlanlar.fotoUrl: fotoUrl,
    };
  }
}
