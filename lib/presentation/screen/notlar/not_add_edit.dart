import 'package:flutter/material.dart';
import 'package:notlarim/data/models/oncelik_model.dart';

// 🌍 Localization & Core Utils
import '../../../../core/utils/color_helper.dart';
import '../../../../localization/localization.dart';

// 🧠 Domain Entities
import '../../../domain/entities/not.dart';
import '../../../domain/entities/kategori.dart';
import '../../../domain/entities/oncelik.dart';

// 🧠 Domain UseCases
import '../../../domain/usecases/not/create_not.dart';
import '../../../domain/usecases/not/update_not.dart';
import '../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../domain/usecases/kategori/get_first_kategori.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';
import '../../../domain/usecases/oncelik/get_first_oncelik.dart';
import '../../../domain/usecases/oncelik/get_oncelik_by_id.dart';

// DI
import '../../../../core/di/injection_container.dart';

class NotAddEdit extends StatefulWidget {
  final Not? not;

  // Constructor sadeleşti
  const NotAddEdit({
    super.key,
    this.not,
  });

  @override
  State<NotAddEdit> createState() => _NotAddEditState();
}

class _NotAddEditState extends State<NotAddEdit> {
  final _formKey = GlobalKey<FormState>();

  String baslik = '';
  String aciklama = '';
  int kategoriId = 0;
  int oncelikId = 0;
  List<Kategori> kategoriListesi = [];
  List<Oncelik> oncelikListesi = [];
  Color selectedColor = Colors.grey.shade300;

  // UseCase'leri DI'dan çekiyoruz
  final CreateNot _createNotUseCase = sl<CreateNot>();
  final UpdateNot _updateNotUseCase = sl<UpdateNot>();
  final GetAllKategori _getAllKategoriUseCase = sl<GetAllKategori>();
  final GetAllOncelik _getAllOncelikUseCase = sl<GetAllOncelik>();
  final GetFirstKategori _getFirstKategoriUseCase =
      sl<GetFirstKategori>(); // Not: Bunu DI container'a eklediğinden emin ol
  // Eğer GetFirstKategori'yi DI'a eklemediysen:
  // final GetFirstKategori _getFirstKategoriUseCase = GetFirstKategori(sl<KategoriRepository>());
  final GetFirstOncelik _getFirstOncelikUseCase =
      sl<GetFirstOncelik>(); // Aynı şekilde kontrol et
  final GetOncelikById _getOncelikByIdUseCase = sl<GetOncelikById>();

  @override
  void initState() {
    super.initState();

    baslik = widget.not?.baslik ?? '';
    aciklama = widget.not?.aciklama ?? '';
    kategoriId = widget.not?.kategoriId ?? 0;
    oncelikId = widget.not?.oncelikId ?? 0;

    // Not: injection_container.dart içinde GetFirst... usecaselerini tanımlamadıysak
    // hata alabilirsin. Tanımladığını varsayıyorum. Eğer yoksa en aşağıya not ekledim.

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final kategoriList = await _getAllKategoriUseCase();
      final oncelikList = await _getAllOncelikUseCase();

      if (mounted) {
        if (widget.not == null) {
          // 🆕 Yeni not
          Kategori? ilkKategori;
          Oncelik? ilkOncelik;

          // Hata önleyici: Veritabanı boşsa crash olmasın
          try {
            ilkKategori = await _getFirstKategoriUseCase();
            ilkOncelik = await _getFirstOncelikUseCase();
          } catch (_) {}

          setState(() {
            kategoriListesi = kategoriList;
            oncelikListesi = oncelikList;
            kategoriId = ilkKategori?.id ??
                (kategoriList.isNotEmpty ? kategoriList.first.id! : 0);
            oncelikId = ilkOncelik?.id ??
                (oncelikList.isNotEmpty ? oncelikList.first.id! : 0);
            selectedColor =
                ColorHelper.hexToColor(ilkOncelik?.renkKodu ?? '#CCCCCC');
          });
        } else {
          // ✏️ Düzenleme modu
          final secilenOncelik =
              await _getOncelikByIdUseCase(widget.not!.oncelikId);
          setState(() {
            kategoriListesi = kategoriList;
            oncelikListesi = oncelikList;
            selectedColor =
                ColorHelper.hexToColor(secilenOncelik?.renkKodu ?? "#E0E0E0");
          });
        }
      }
    } catch (e) {
      debugPrint("⚠️ Dropdown yüklenemedi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veri yüklenemedi")),
        );
      }
    }
  }

  Future<void> _saveNot() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final isUpdating = widget.not != null;

    final yeniNot = Not(
      id: widget.not?.id,
      kategoriId: kategoriId,
      oncelikId: oncelikId,
      baslik: baslik,
      aciklama: aciklama,
      kayitZamani: now,
      durumId: 1,
    );

    try {
      if (isUpdating) {
        await _updateNotUseCase(yeniNot);
      } else {
        await _createNotUseCase(yeniNot);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('❌ Not kaydedilemedi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not kaydedilemedi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${loc.translate('general_note')} ${loc.translate('general_addUpdate')}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.amber,
          ),
        ),
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: selectedColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildKategoriDropdown(loc),
                  const SizedBox(height: 8),
                  _buildOncelikDropdown(loc),
                  const SizedBox(height: 8),
                  _buildBaslikField(loc),
                  const SizedBox(height: 8),
                  _buildAciklamaField(loc),
                  const SizedBox(height: 16),
                  _buildSaveButton(loc),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... _buildKategoriDropdown, _buildOncelikDropdown vb. metodlar aynen kalabilir
  // Sadece içlerinde UseCase çağırmıyorsan değişiklik gerekmez.
  // Eğer çağırıyorsan widget.useCase yerine yukarıda tanımladığımız _useCase değişkenlerini kullan.

  Widget _buildKategoriDropdown(AppLocalizations loc) {
    return DropdownButtonFormField<int>(
      initialValue: kategoriId != 0 ? kategoriId : null,
      items: kategoriListesi
          .map((kategori) => DropdownMenuItem<int>(
                value: kategori.id,
                child: Text(kategori.baslik),
              ))
          .toList(),
      onChanged: (val) => setState(() => kategoriId = val ?? 0),
      decoration: InputDecoration(
        labelText:
            '${loc.translate('general_categori')} ${loc.translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val == 0 ? loc.translate('general_notEmpty') : null,
    );
  }

  Widget _buildOncelikDropdown(AppLocalizations loc) {
    return DropdownButtonFormField<int>(
      initialValue: oncelikId != 0 ? oncelikId : null,
      items: oncelikListesi
          .map((oncelik) => DropdownMenuItem<int>(
                value: oncelik.id,
                child: Text(oncelik.baslik),
              ))
          .toList(),
      onChanged: (val) {
        if (val == null || oncelikListesi.isEmpty) return;
        final secilen = oncelikListesi.firstWhere(
          (o) => o.id == val,
          orElse: () => OncelikModel(
            id: 0,
            baslik: '',
            aciklama: '',
            renkKodu: "#E0E0E0",
            kayitZamani: DateTime.now(),
            sabitMi: false,
          ),
        );
        setState(() {
          oncelikId = val;
          selectedColor = ColorHelper.hexToColor(
            secilen.renkKodu.isNotEmpty ? secilen.renkKodu : "#E0E0E0",
          );
        });
      },
      decoration: InputDecoration(
        labelText:
            '${loc.translate('general_priority')} ${loc.translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
      validator: (val) =>
          val == null || val == 0 ? loc.translate('general_notEmpty') : null,
    );
  }

  Widget _buildBaslikField(AppLocalizations loc) => TextFormField(
        initialValue: baslik,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: loc.translate('general_title'),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? loc.translate('general_notEmpty') : null,
        onChanged: (v) => baslik = v,
      );

  Widget _buildAciklamaField(AppLocalizations loc) => TextFormField(
        maxLines: 5,
        initialValue: aciklama,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: loc.translate('general_explanation'),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? loc.translate('general_notEmpty') : null,
        onChanged: (v) => aciklama = v,
      );

  Widget _buildSaveButton(AppLocalizations loc) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade700,
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: _saveNot,
      child: Text(
        loc.translate('general_save'),
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
