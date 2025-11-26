import 'package:flutter/material.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/localization/localization.dart';

// Domain UseCases
import 'package:notlarim/domain/usecases/hatirlatici/create_hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/update_hatirlatici.dart';
import 'package:notlarim/domain/usecases/kategori/get_all_kategori.dart';
import 'package:notlarim/domain/usecases/oncelik/get_all_oncelik.dart';

// DI
import '../../../../core/di/injection_container.dart';

import 'hatirlatici_form.dart';

/// 🧱 Hatırlatıcı Ekle / Güncelleme Ekranı — Clean Architecture uyumlu versiyon.
class HatirlaticiAddEdit extends StatefulWidget {
  final Hatirlatici? hatirlatici;

  const HatirlaticiAddEdit({
    super.key,
    this.hatirlatici,
  });

  @override
  State<HatirlaticiAddEdit> createState() => _HatirlaticiAddEditState();
}

class _HatirlaticiAddEditState extends State<HatirlaticiAddEdit> {
  final _formKey = GlobalKey<FormState>();

  late String _baslik;
  late String _aciklama;
  late int _kategoriId;
  late int _oncelikId;
  late DateTime _hatirlatmaTarihiZamani;

  // ✅ UseCase'ler DI'dan
  final CreateHatirlatici _createHatirlaticiUseCase = sl<CreateHatirlatici>();
  final UpdateHatirlatici _updateHatirlaticiUseCase = sl<UpdateHatirlatici>();
  final GetAllKategori _getAllKategoriUseCase = sl<GetAllKategori>();
  final GetAllOncelik _getAllOncelikUseCase = sl<GetAllOncelik>();

  @override
  void initState() {
    super.initState();

    _baslik = widget.hatirlatici?.baslik ?? '';
    _aciklama = widget.hatirlatici?.aciklama ?? '';
    _kategoriId = widget.hatirlatici?.kategoriId ?? 0;
    _oncelikId = widget.hatirlatici?.oncelikId ?? 0;
    _hatirlatmaTarihiZamani =
        widget.hatirlatici?.hatirlatmaTarihiZamani ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isUpdating = widget.hatirlatici != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${loc.translate('general_reminder')} '
          '${isUpdating ? loc.translate('general_update') : loc.translate('general_add')}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.amber,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              /// 📋 Hatırlatıcı form bileşeni
              HatirlaticiForm(
                initialHatirlatici: widget.hatirlatici,
                onChangedBaslik: (v) => setState(() => _baslik = v),
                onChangedAciklama: (v) => setState(() => _aciklama = v),
                onChangedKategori: (v) => setState(() => _kategoriId = v),
                onChangedOncelik: (v) => setState(() => _oncelikId = v),
                onChangedHatirlatmaTarihi: (v) =>
                    setState(() => _hatirlatmaTarihiZamani = v),
                // UseCase parametreleri form widget'ına gönderiliyor
                getAllKategoriUseCase: _getAllKategoriUseCase,
                getAllOncelikUseCase: _getAllOncelikUseCase,
              ),

              const SizedBox(height: 16),

              /// 💾 Kaydet Butonu
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _baslik.isNotEmpty && _aciklama.isNotEmpty
                        ? Colors.indigo.shade700
                        : Colors.grey.shade600,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    loc.translate('general_save'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _baslik.isNotEmpty && _aciklama.isNotEmpty
                      ? _saveHatirlatici
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 💾 Kaydetme işlemi (Ekleme veya Güncelleme)
  Future<void> _saveHatirlatici() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);

    final entity = Hatirlatici(
      id: widget.hatirlatici?.id,
      baslik: _baslik.trim(),
      aciklama: _aciklama.trim(),
      kategoriId: _kategoriId,
      oncelikId: _oncelikId,
      hatirlatmaTarihiZamani: _hatirlatmaTarihiZamani,
      kayitZamani: widget.hatirlatici?.kayitZamani ?? DateTime.now(),
      durumId: widget.hatirlatici?.durumId ?? 1,
    );

    try {
      if (widget.hatirlatici != null) {
        await _updateHatirlaticiUseCase(entity);
      } else {
        await _createHatirlaticiUseCase(entity);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.hatirlatici != null
                  ? loc.translate('general_updated')
                  : loc.translate('general_added'),
            ),
            backgroundColor: Colors.green.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Hatırlatıcı kaydedilirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }
}
