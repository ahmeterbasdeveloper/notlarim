import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';

// 🧩 Domain
import '../../../domain/entities/kategori.dart';
import '../../../domain/entities/oncelik.dart';
import '../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';

// 💾 Data
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';

class KontrolListeForm extends StatefulWidget {
  final int? kategoriId;
  final int? oncelikId;
  final String? baslik;
  final String? aciklama;
  final ValueChanged<int> onChangedKategori;
  final ValueChanged<int> onChangedOncelik;
  final ValueChanged<String> onChangedBaslik;
  final ValueChanged<String> onChangedAciklama;

  const KontrolListeForm({
    super.key,
    required this.kategoriId,
    required this.oncelikId,
    this.baslik = '',
    this.aciklama = '',
    required this.onChangedKategori,
    required this.onChangedOncelik,
    required this.onChangedBaslik,
    required this.onChangedAciklama,
  });

  @override
  State<KontrolListeForm> createState() => _KontrolListeFormState();
}

class _KontrolListeFormState extends State<KontrolListeForm> {
  int? selectedKategoriId;
  int? selectedOncelikId;

  late final GetAllKategori _getAllKategori;
  late final GetAllOncelik _getAllOncelik;

  @override
  void initState() {
    super.initState();

    final dbHelper = DatabaseHelper.instance;

    _getAllKategori = GetAllKategori(KategoriRepositoryImpl(dbHelper));
    _getAllOncelik = GetAllOncelik(OncelikRepositoryImpl(dbHelper));

    selectedKategoriId = widget.kategoriId;
    selectedOncelikId = widget.oncelikId;
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _buildKategoriDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildOncelikDropdown()),
              ],
            ),
            const SizedBox(height: 12),
            _buildBaslik(),
            const SizedBox(height: 8),
            _buildAciklama(),
          ],
        ),
      );

  // 🟢 Kategori Dropdown
  Widget _buildKategoriDropdown() {
    return FutureBuilder<List<Kategori>>(
      future: _getAllKategori(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalizations.of(context).translate('general_dataELoadingrrorMessage')}: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(AppLocalizations.of(context)
              .translate('general_noDataAvailable'));
        }

        final items = snapshot.data!
            .map((kategori) => DropdownMenuItem<int>(
                  value: kategori.id,
                  child: Text(kategori.baslik),
                ))
            .toList();

        return DropdownButtonFormField<int>(
          initialValue: selectedKategoriId,
          items: items,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedKategoriId = value);
              widget.onChangedKategori(value);
            }
          },
          decoration: InputDecoration(
            labelText:
                '${AppLocalizations.of(context).translate('general_categori')} ${AppLocalizations.of(context).translate('general_select')}',
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  // 🟡 Öncelik Dropdown
  Widget _buildOncelikDropdown() {
    return FutureBuilder<List<Oncelik>>(
      future: _getAllOncelik(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
              '${AppLocalizations.of(context).translate('general_dataELoadingrrorMessage')}: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(AppLocalizations.of(context)
              .translate('general_noDataAvailable'));
        }

        final items = snapshot.data!
            .map((oncelik) => DropdownMenuItem<int>(
                  value: oncelik.id,
                  child: Text(oncelik.baslik),
                ))
            .toList();

        return DropdownButtonFormField<int>(
          initialValue: selectedOncelikId,
          items: items,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedOncelikId = value);
              widget.onChangedOncelik(value);
            }
          },
          decoration: InputDecoration(
            labelText:
                '${AppLocalizations.of(context).translate('general_priority')} ${AppLocalizations.of(context).translate('general_select')}',
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  // 🟠 Başlık Alanı
  Widget _buildBaslik() => TextFormField(
        maxLines: 1,
        initialValue: widget.baslik,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText:
              AppLocalizations.of(context).translate('general_title'),
          hintText:
              AppLocalizations.of(context).translate('general_enterTitle'),
        ),
        validator: (value) => value != null && value.isEmpty
            ? '${AppLocalizations.of(context).translate('general_title')} ${AppLocalizations.of(context).translate('general_notEmpty')}'
            : null,
        onChanged: widget.onChangedBaslik,
      );

  // 🔵 Açıklama Alanı
  Widget _buildAciklama() => TextFormField(
        maxLines: 5,
        initialValue: widget.aciklama,
        style: const TextStyle(color: Colors.black, fontSize: 20),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText:
              AppLocalizations.of(context).translate('general_explanation'),
          hintText: AppLocalizations.of(context)
              .translate('general_somethingWriteHereMessage'),
        ),
        validator: (value) => value != null && value.isEmpty
            ? '${AppLocalizations.of(context).translate('general_explanation')} ${AppLocalizations.of(context).translate('general_notEmpty')}'
            : null,
        onChanged: widget.onChangedAciklama,
      );
}
