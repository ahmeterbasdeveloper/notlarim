import 'package:flutter/material.dart';
import 'package:notlarim/domain/usecases/kategori/get_all_kategori.dart';
import 'package:notlarim/domain/usecases/oncelik/get_all_oncelik.dart';
import 'package:notlarim/localization/localization.dart';

// Domain
import '../../../../domain/entities/gorev.dart';
import '../../../../domain/usecases/gorev/create_gorev.dart';
import '../../../../domain/usecases/gorev/update_gorev.dart';

// UI
import 'gorev_form.dart';

/// 🧱 Görev Ekle / Güncelle Ekranı — Clean Architecture versiyonu.
class GorevAddEdit extends StatefulWidget {
  final Gorev? gorev;
  final CreateGorev createGorevUseCase;
  final UpdateGorev updateGorevUseCase;
  final GetAllKategori getAllKategoriUseCase;
  final GetAllOncelik getAllOncelikUseCase;

  const GorevAddEdit({
    super.key,
    this.gorev,
    required this.createGorevUseCase,
    required this.updateGorevUseCase,
    required this.getAllKategoriUseCase,
    required this.getAllOncelikUseCase,
  });

  @override
  State<GorevAddEdit> createState() => _GorevAddEditState();
}

class _GorevAddEditState extends State<GorevAddEdit> {
  final _formKey = GlobalKey<FormState>();

  late int grupId;
  late String baslik;
  late String aciklama;
  late int kategoriId;
  late int oncelikId;
  late DateTime baslamaTarihiZamani;
  late DateTime bitisTarihiZamani;

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
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isUpdating = widget.gorev != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${local.translate('general_missionJob')} ${isUpdating ? local.translate('general_update') : local.translate('general_add')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green.shade900,
      ),
      body: Form(
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
                onChangedBaslik: (v) => setState(() => baslik = v),
                onChangedAciklama: (v) => setState(() => aciklama = v),
                onChangedKategori: (v) => setState(() => kategoriId = v),
                onChangedOncelik: (v) => setState(() => oncelikId = v),
                onChangedBaslamaTarihiZamani: (v) => setState(() => baslamaTarihiZamani = v),
                onChangedBitisTarihiZamani: (v) => setState(() => bitisTarihiZamani = v),
                getAllKategoriUseCase: widget.getAllKategoriUseCase,
                getAllOncelikUseCase: widget.getAllOncelikUseCase,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: baslik.isNotEmpty && aciklama.isNotEmpty
                        ? Colors.indigo.shade600
                        : Colors.grey.shade600,
                  ),
                  onPressed: baslik.isNotEmpty && aciklama.isNotEmpty
                      ? _saveGorev
                      : null,
                  child: Text(
                    local.translate('general_save'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
        await widget.updateGorevUseCase(entity);
      } else {
        await widget.createGorevUseCase(entity);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ Görev kaydedilirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${e.toString()}')),
        );
      }
    }
  }
}
