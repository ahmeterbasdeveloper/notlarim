import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/features/kategori/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';
import 'package:notlarim/core/localization/localization.dart';

// Domain
import '../../domain/entities/gorev.dart';
import '../../../kategori/domain/entities/kategori.dart';
import '../../../oncelik/domain/entities/oncelik.dart';

// DI Providers
import '../providers/gorev_di_providers.dart';

// Form Widget'ı (CustomTextField entegrasyonu BURADA yapılmalı)
import '../widgets/gorev_form.dart';

class GorevAddEdit extends ConsumerStatefulWidget {
  final Gorev? gorev;
  const GorevAddEdit({super.key, this.gorev});

  @override
  ConsumerState<GorevAddEdit> createState() => _GorevAddEditState();
}

class _GorevAddEditState extends ConsumerState<GorevAddEdit> {
  final _formKey = GlobalKey<FormState>();

  late int grupId;
  late String baslik;
  late String aciklama;
  late int kategoriId;
  late int oncelikId;
  late DateTime baslamaTarihiZamani;
  late DateTime bitisTarihiZamani;

  // Dropdown listeleri
  List<Kategori> _kategoriList = [];
  List<Oncelik> _oncelikList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    grupId = widget.gorev?.grupId ?? 0;
    baslik = widget.gorev?.baslik ?? '';
    aciklama = widget.gorev?.aciklama ?? '';
    kategoriId = widget.gorev?.kategoriId ?? 0;
    oncelikId = widget.gorev?.oncelikId ?? 0;
    baslamaTarihiZamani = widget.gorev?.baslamaTarihiZamani ?? DateTime.now();
    bitisTarihiZamani = widget.gorev?.bitisTarihiZamani ?? DateTime.now();

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      // Generic UseCase Provider'larını çağırıyoruz
      final kategoriler = await ref.read(getAllKategoriProvider).call();
      final oncelikler = await ref.read(getAllOncelikProvider).call();

      if (mounted) {
        setState(() {
          _kategoriList = kategoriler;
          _oncelikList = oncelikler;

          // Eğer yeni kayıt ise varsayılan değerleri ata
          if (widget.gorev == null) {
            if (_kategoriList.isNotEmpty) kategoriId = _kategoriList.first.id!;
            if (_oncelikList.isNotEmpty) oncelikId = _oncelikList.first.id!;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Veri yükleme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isUpdating = widget.gorev != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${local.translate('general_missionJob')} ${isUpdating ? local.translate('general_update') : local.translate('general_add')}',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GorevlerForm(
                      baslik: baslik,
                      aciklama: aciklama,
                      kategoriId: kategoriId,
                      oncelikId: oncelikId,
                      baslamaTarihiZamani: baslamaTarihiZamani,
                      bitisTarihiZamani: bitisTarihiZamani,

                      // Değer değişikliklerini dinle
                      onChangedBaslik: (v) => baslik = v,
                      onChangedAciklama: (v) => aciklama = v,
                      onChangedKategori: (v) => kategoriId = v,
                      onChangedOncelik: (v) => oncelikId = v,
                      onChangedBaslamaTarihiZamani: (v) =>
                          baslamaTarihiZamani = v,
                      onChangedBitisTarihiZamani: (v) => bitisTarihiZamani = v,

                      // Listeleri gönderiyoruz
                      kategoriListesi: _kategoriList,
                      oncelikListesi: _oncelikList,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                        ),
                        onPressed: _saveGorev,
                        child: Text(
                          local.translate('general_save'),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveGorev() async {
    if (!_formKey.currentState!.validate()) return;

    final entity = Gorev(
      id: widget.gorev?.id,
      grupId: grupId,
      baslik: baslik,
      aciklama: aciklama,
      kategoriId: kategoriId,
      oncelikId: oncelikId,
      baslamaTarihiZamani: baslamaTarihiZamani,
      bitisTarihiZamani: bitisTarihiZamani,
      kayitZamani: widget.gorev?.kayitZamani ?? DateTime.now(),
      durumId: widget.gorev?.durumId ?? 1,
    );

    try {
      if (widget.gorev != null) {
        // Generic Update
        await ref.read(updateGorevProvider).call(entity);
      } else {
        // Generic Create
        await ref.read(createGorevProvider).call(entity);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ Görev kaydedilirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ $e')));
      }
    }
  }
}
