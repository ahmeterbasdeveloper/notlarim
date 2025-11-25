import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';

import '../../../domain/entities/kontrol_liste.dart';
import '../../../domain/entities/kategori.dart';
import '../../../domain/entities/oncelik.dart';

// 🧠 UseCases
import '../../../domain/usecases/kontrol_liste/create_kontrol_liste.dart';
import '../../../domain/usecases/kontrol_liste/update_kontrol_liste.dart';
import '../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';

// 💾 Repositories & DataSources
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/kontrol_liste_repository_impl.dart';
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';

class KontrolListeAddEdit extends StatefulWidget {
  final KontrolListe? kontrolListe;

  const KontrolListeAddEdit({
    super.key,
    this.kontrolListe,
  });

  @override
  State<KontrolListeAddEdit> createState() => _KontrolListeAddEditState();
}

class _KontrolListeAddEditState extends State<KontrolListeAddEdit> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late int kategoriId;
  late int oncelikId;

  late final _dbHelper = DatabaseHelper.instance;
  late final _kategoriRepository = KategoriRepositoryImpl(_dbHelper);
  late final _oncelikRepository = OncelikRepositoryImpl(_dbHelper);
  late final _kontrolListeRepository = KontrolListeRepositoryImpl(_dbHelper);

  late final _getAllKategori = GetAllKategori(_kategoriRepository);
  late final _getAllOncelik = GetAllOncelik(_oncelikRepository);
  late final _createKontrolListe = CreateKontrolListe(_kontrolListeRepository);
  late final _updateKontrolListe = UpdateKontrolListe(_kontrolListeRepository);

  List<Kategori> kategoriler = [];
  List<Oncelik> oncelikler = [];

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
    final kategoriList = await _getAllKategori();
    final oncelikList = await _getAllOncelik();
    setState(() {
      kategoriler = kategoriList;
      oncelikler = oncelikList;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${AppLocalizations.of(context).translate('general_checkList')} '
            '${AppLocalizations.of(context).translate('general_addUpdate')}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.amber,
            ),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildKategoriDropdown(),
                const SizedBox(height: 8),
                _buildOncelikDropdown(),
                const SizedBox(height: 8),
                _buildBaslik(),
                const SizedBox(height: 8),
                _buildAciklama(),
                const SizedBox(height: 16),
                _buildButton(),
              ],
            ),
          ),
        ),
      );

  // 🟢 Kategori Dropdown
  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: kategoriId == 0 ? null : kategoriId,
      items: kategoriler.map((kategori) {
        return DropdownMenuItem<int>(
          value: kategori.id,
          child: Text(kategori.baslik),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => kategoriId = newValue ?? 0),
      decoration: InputDecoration(
        labelText:
            '${AppLocalizations.of(context).translate('general_categori')} '
            '${AppLocalizations.of(context).translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
    );
  }

  // 🟡 Öncelik Dropdown
  Widget _buildOncelikDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: oncelikId == 0 ? null : oncelikId,
      items: oncelikler.map((oncelik) {
        return DropdownMenuItem<int>(
          value: oncelik.id,
          child: Text(oncelik.baslik),
        );
      }).toList(),
      onChanged: (newValue) => setState(() => oncelikId = newValue ?? 0),
      decoration: InputDecoration(
        labelText:
            '${AppLocalizations.of(context).translate('general_priority')} '
            '${AppLocalizations.of(context).translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
    );
  }

  // 🟠 Başlık alanı
  Widget _buildBaslik() => TextFormField(
        maxLines: 1,
        initialValue: baslik,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText:
              AppLocalizations.of(context).translate('general_title'),
          hintText:
              AppLocalizations.of(context).translate('general_enterTitle'),
        ),
        validator: (value) => (value == null || value.isEmpty)
            ? '${AppLocalizations.of(context).translate('general_title')} '
              '${AppLocalizations.of(context).translate('general_notEmpty')}'
            : null,
        onChanged: (value) => setState(() => baslik = value),
      );

  // 🔵 Açıklama alanı
  Widget _buildAciklama() => TextFormField(
        maxLines: 5,
        initialValue: aciklama,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText:
              AppLocalizations.of(context).translate('general_explanation'),
          hintText: AppLocalizations.of(context)
              .translate('general_somethingWriteHereMessage'),
        ),
        validator: (value) => (value == null || value.isEmpty)
            ? '${AppLocalizations.of(context).translate('general_explanation')} '
              '${AppLocalizations.of(context).translate('general_notEmpty')}'
            : null,
        onChanged: (value) => setState(() => aciklama = value),
      );

  // 💾 Kaydet butonu
  Widget _buildButton() {
    final isFormValid = baslik.isNotEmpty && aciklama.isNotEmpty;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade600,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      ),
      onPressed: _saveKontrolListe,
      child: Text(
        AppLocalizations.of(context).translate('general_save'),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
      kayitZamani:
          widget.kontrolListe?.kayitZamani ?? DateTime.now(),
      durumId: 1,
    );

    if (isEditing) {
      await _updateKontrolListe(entity);
    } else {
      await _createKontrolListe(entity);
    }

    if (mounted) Navigator.pop(context, true);
  }
}
