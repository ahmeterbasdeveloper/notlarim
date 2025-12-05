import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/features/kategoriler/presentation/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/presentation/providers/oncelik_di_providers.dart';
import 'package:notlarim/core/localization/localization.dart';

import '../../domain/entities/kontrol_liste.dart';
import '../../../kategoriler/domain/entities/kategori.dart';
import '../../../oncelik/domain/entities/oncelik.dart';

// DI Providers
import '../providers/kontrol_liste_di_providers.dart';

// Form Widget'ı (CustomTextField entegrasyonu BURADA yapılmalı)
import '../widgets/kontrol_liste_form.dart';

class KontrolListeAddEdit extends ConsumerStatefulWidget {
  final KontrolListe? kontrolListe;
  const KontrolListeAddEdit({super.key, this.kontrolListe});

  @override
  ConsumerState<KontrolListeAddEdit> createState() =>
      _KontrolListeAddEditState();
}

class _KontrolListeAddEditState extends ConsumerState<KontrolListeAddEdit> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late int kategoriId;
  late int oncelikId;

  List<Kategori> kategoriler = [];
  List<Oncelik> oncelikler = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    baslik = widget.kontrolListe?.baslik ?? '';
    aciklama = widget.kontrolListe?.aciklama ?? '';
    kategoriId = widget.kontrolListe?.kategoriId ?? 0;
    oncelikId = widget.kontrolListe?.oncelikId ?? 0;

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Generic Providers ile verileri çekiyoruz
      final kategoriList = await ref.read(getAllKategoriProvider).call();
      final oncelikList = await ref.read(getAllOncelikProvider).call();

      if (mounted) {
        setState(() {
          kategoriler = kategoriList;
          oncelikler = oncelikList;

          // Yeni kayıtsa ve listeler doluysa varsayılan değerleri ata
          if (widget.kontrolListe == null) {
            if (kategoriler.isNotEmpty) kategoriId = kategoriler.first.id!;
            if (oncelikler.isNotEmpty) oncelikId = oncelikler.first.id!;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Veri yükleme hatası: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isEditing = widget.kontrolListe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${local.translate('general_checkList')} ${isEditing ? local.translate('general_update') : local.translate('general_add')}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Form bileşeni
                    KontrolListeForm(
                      kategoriId: kategoriId,
                      oncelikId: oncelikId,
                      baslik: baslik,
                      aciklama: aciklama,
                      onChangedKategori: (v) => kategoriId = v,
                      onChangedOncelik: (v) => oncelikId = v,
                      onChangedBaslik: (v) => baslik = v,
                      onChangedAciklama: (v) => aciklama = v,
                      kategoriListesi: kategoriler,
                      oncelikListesi: oncelikler,
                    ),
                    const SizedBox(height: 16),
                    _buildButton(local),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildButton(AppLocalizations local) {
    // Basit validasyon kontrolü (buton rengi için)
    final isFormValid = baslik.isNotEmpty && aciklama.isNotEmpty;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade600,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      ),
      onPressed: _saveKontrolListe,
      child: Text(
        local.translate('general_save'),
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Future<void> _saveKontrolListe() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.kontrolListe != null;
    final entity = KontrolListe(
      id: widget.kontrolListe?.id,
      kategoriId: kategoriId,
      oncelikId: oncelikId,
      baslik: baslik,
      aciklama: aciklama,
      kayitZamani: widget.kontrolListe?.kayitZamani ?? DateTime.now(),
      durumId: 1, // Varsayılan durum
    );

    try {
      if (isEditing) {
        // Generic Update
        await ref.read(updateKontrolListeProvider).call(entity);
      } else {
        // Generic Create
        await ref.read(createKontrolListeProvider).call(entity);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Kayıt hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }
}
