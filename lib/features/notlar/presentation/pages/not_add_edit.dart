import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/features/kategori/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';
import 'package:notlarim/core/widgets/custom_text_field.dart';
import 'package:notlarim/core/localization/localization.dart';

// Entities
import '../../domain/entities/not.dart';
import '../../../kategori/domain/entities/kategori.dart';
import '../../../oncelik/domain/entities/oncelik.dart';

// DI Providers (Generic UseCase'lere erişim için)
import '../providers/not_di_providers.dart';

// Helper
import '../../../../../core/utils/color_helper.dart';

// ✅ YENİ: Ortak Widget Importu

class NotAddEdit extends ConsumerStatefulWidget {
  final Not? not;
  const NotAddEdit({super.key, this.not});

  @override
  ConsumerState<NotAddEdit> createState() => _NotAddEditState();
}

class _NotAddEditState extends ConsumerState<NotAddEdit> {
  final _formKey = GlobalKey<FormState>();

  // Form Alanları
  late String _baslik;
  late String _aciklama;
  int? _selectedKategoriId;
  int? _selectedOncelikId;

  // Arka plan rengini tutan değişken (Varsayılan beyaz)
  Color _backgroundColor = Colors.white;

  // Dropdown Listeleri
  List<Kategori> _kategoriList = [];
  List<Oncelik> _oncelikList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Varsayılan Değerler
    _baslik = widget.not?.baslik ?? '';
    _aciklama = widget.not?.aciklama ?? '';
    _selectedKategoriId = widget.not?.kategoriId;
    _selectedOncelikId = widget.not?.oncelikId;

    // Verileri Yükle
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      // Generic UseCase'leri çağırıyoruz
      final kategoriler = await ref.read(getAllKategoriProvider).call();
      final oncelikler = await ref.read(getAllOncelikProvider).call();

      if (mounted) {
        setState(() {
          _kategoriList = kategoriler;
          _oncelikList = oncelikler;

          // Eğer yeni kayıt ise ve liste boş değilse varsayılan olarak ilkini seç
          if (widget.not == null) {
            if (_kategoriList.isNotEmpty) {
              _selectedKategoriId = _kategoriList.first.id;
            }
            if (_oncelikList.isNotEmpty) {
              _selectedOncelikId = _oncelikList.first.id;
            }
          }

          // Veriler yüklendiğinde rengi güncelle
          _updateBackgroundColor(_selectedOncelikId);

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Veri yükleme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Seçilen ID'ye göre rengi bulan ve güncelleyen fonksiyon
  void _updateBackgroundColor(int? oncelikId) {
    if (oncelikId == null || _oncelikList.isEmpty) {
      _backgroundColor = Colors.white;
      return;
    }

    try {
      // Listeden seçili önceliği bul
      final selectedOncelik = _oncelikList.firstWhere(
        (element) => element.id == oncelikId,
        orElse: () => _oncelikList.first,
      );

      // Rengi helper ile dönüştür ve hafif şeffaflık ver (Okunabilirlik için)
      setState(() {
        _backgroundColor = ColorHelper.hexToColor(selectedOncelik.renkKodu)
            .withValues(alpha: 0.3); // alpha 0.3 ile pastel ton yapar
      });
    } catch (e) {
      debugPrint("Renk güncelleme hatası: $e");
      setState(() => _backgroundColor = Colors.white);
    }
  }

  Future<void> _saveNot() async {
    if (!_formKey.currentState!.validate()) return;

    final isUpdating = widget.not != null;
    final local = AppLocalizations.of(context);

    // Formdan gelen verilerle Not nesnesi oluştur
    final yeniNot = Not(
      id: widget.not
          ?.id, // Güncelleme ise ID korunur, yoksa null (BaseEntity halleder)
      baslik: _baslik,
      aciklama: _aciklama,
      kategoriId: _selectedKategoriId ?? 0,
      oncelikId: _selectedOncelikId ?? 0,
      kayitZamani: widget.not?.kayitZamani ??
          DateTime.now(), // Tarih değişmez veya şu an
      durumId: widget.not?.durumId ?? 1, // Varsayılan durum (Örn: 1-Aktif)
    );

    try {
      if (isUpdating) {
        // Güncelleme Provider'ı
        await ref.read(updateNotProvider).call(yeniNot);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    local.translate('general_updateSuccess') ?? 'Güncellendi')),
          );
        }
      } else {
        // Ekleme Provider'ı
        await ref.read(createNotProvider).call(yeniNot);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    local.translate('general_saveSuccess') ?? 'Kaydedildi')),
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${local.translate('general_errorMessage')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isUpdating = widget.not != null;

    return Scaffold(
      // Scaffold background rengini değişkene bağla
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(isUpdating
            ? (local.translate('general_update') ?? 'Notu Güncelle')
            : (local.translate('general_add') ?? 'Not Ekle')),
        backgroundColor: Colors.green.shade900,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- KATEGORİ SEÇİMİ ---
                      DropdownButtonFormField<int>(
                        initialValue: _selectedKategoriId,
                        items: _kategoriList.map((e) {
                          return DropdownMenuItem(
                              value: e.id, child: Text(e.baslik));
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedKategoriId = val),
                        decoration: InputDecoration(
                          labelText:
                              local.translate('general_category') ?? 'Kategori',
                          border: const OutlineInputBorder(),
                          // Arka plan rengine göre input arka planını beyaz yapalım
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        validator: (val) =>
                            val == null ? 'Lütfen kategori seçin' : null,
                      ),
                      const SizedBox(height: 16),

                      // --- ÖNCELİK SEÇİMİ ---
                      DropdownButtonFormField<int>(
                        initialValue: _selectedOncelikId,
                        items: _oncelikList.map((e) {
                          return DropdownMenuItem(
                              value: e.id, child: Text(e.baslik));
                        }).toList(),
                        // Seçim değişince rengi güncelle
                        onChanged: (val) {
                          setState(() => _selectedOncelikId = val);
                          _updateBackgroundColor(val);
                        },
                        decoration: InputDecoration(
                          labelText:
                              local.translate('general_priority') ?? 'Öncelik',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        validator: (val) =>
                            val == null ? 'Lütfen öncelik seçin' : null,
                      ),
                      const SizedBox(height: 16),

                      // --- BAŞLIK ALANI (CustomTextField) ---
                      CustomTextField(
                        label: local.translate('general_title') ?? 'Başlık',
                        initialValue: _baslik,
                        onChanged: (val) => _baslik = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Başlık boş olamaz'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // --- AÇIKLAMA ALANI (CustomTextField) ---
                      CustomTextField(
                        label: local.translate('general_explanation') ??
                            'Açıklama',
                        initialValue: _aciklama,
                        maxLines: 5, // Çok satırlı görünüm
                        onChanged: (val) => _aciklama = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Açıklama boş olamaz'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // --- KAYDET BUTONU ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                          ),
                          onPressed: _saveNot,
                          child: Text(
                            local.translate('general_save') ?? 'Kaydet',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
