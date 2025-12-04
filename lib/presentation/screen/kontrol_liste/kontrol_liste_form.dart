import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';

// Domain
import '../../../../domain/entities/kategori.dart';
import '../../../../domain/entities/oncelik.dart';

class KontrolListeForm extends StatefulWidget {
  final int? kategoriId;
  final int? oncelikId;
  final String? baslik;
  final String? aciklama;

  final ValueChanged<int> onChangedKategori;
  final ValueChanged<int> onChangedOncelik;
  final ValueChanged<String> onChangedBaslik;
  final ValueChanged<String> onChangedAciklama;

  // ✅ Listeleri parent'tan alıyoruz
  final List<Kategori> kategoriListesi;
  final List<Oncelik> oncelikListesi;

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
    required this.kategoriListesi, // ✅
    required this.oncelikListesi, // ✅
  });

  @override
  State<KontrolListeForm> createState() => _KontrolListeFormState();
}

class _KontrolListeFormState extends State<KontrolListeForm> {
  int? selectedKategoriId;
  int? selectedOncelikId;

  @override
  void initState() {
    super.initState();
    selectedKategoriId = widget.kategoriId;
    selectedOncelikId = widget.oncelikId;
  }

  @override
  void didUpdateWidget(covariant KontrolListeForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.kategoriId != oldWidget.kategoriId) {
      selectedKategoriId = widget.kategoriId;
    }
    if (widget.oncelikId != oldWidget.oncelikId) {
      selectedOncelikId = widget.oncelikId;
    }
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

  Widget _buildKategoriDropdown() {
    final local = AppLocalizations.of(context);
    if (widget.kategoriListesi.isEmpty) {
      return Text(local.translate('general_noDataAvailable'));
    }

    // Seçili ID listede yoksa null yap (Güvenlik)
    if (selectedKategoriId != null &&
        !widget.kategoriListesi.any((e) => e.id == selectedKategoriId)) {
      selectedKategoriId = null;
    }

    return DropdownButtonFormField<int>(
      initialValue: selectedKategoriId,
      items: widget.kategoriListesi.map((kategori) {
        return DropdownMenuItem<int>(
          value: kategori.id,
          child: Text(kategori.baslik),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => selectedKategoriId = value);
          widget.onChangedKategori(value);
        }
      },
      decoration: InputDecoration(
        labelText:
            '${local.translate('general_categori')} ${local.translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildOncelikDropdown() {
    final local = AppLocalizations.of(context);
    if (widget.oncelikListesi.isEmpty) {
      return Text(local.translate('general_noDataAvailable'));
    }

    if (selectedOncelikId != null &&
        !widget.oncelikListesi.any((e) => e.id == selectedOncelikId)) {
      selectedOncelikId = null;
    }

    return DropdownButtonFormField<int>(
      initialValue: selectedOncelikId,
      items: widget.oncelikListesi.map((oncelik) {
        return DropdownMenuItem<int>(
          value: oncelik.id,
          child: Text(oncelik.baslik),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => selectedOncelikId = value);
          widget.onChangedOncelik(value);
        }
      },
      decoration: InputDecoration(
        labelText:
            '${local.translate('general_priority')} ${local.translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildBaslik() {
    final local = AppLocalizations.of(context);
    return TextFormField(
      maxLines: 1,
      initialValue: widget.baslik,
      style: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: local.translate('general_title'),
        hintText: local.translate('general_enterTitle'),
      ),
      validator: (value) => value != null && value.isEmpty
          ? '${local.translate('general_title')} ${local.translate('general_notEmpty')}'
          : null,
      onChanged: widget.onChangedBaslik,
    );
  }

  Widget _buildAciklama() {
    final local = AppLocalizations.of(context);
    return TextFormField(
      maxLines: 5,
      initialValue: widget.aciklama,
      style: const TextStyle(color: Colors.black, fontSize: 20),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: local.translate('general_explanation'),
        hintText: local.translate('general_somethingWriteHereMessage'),
      ),
      validator: (value) => value != null && value.isEmpty
          ? '${local.translate('general_explanation')} ${local.translate('general_notEmpty')}'
          : null,
      onChanged: widget.onChangedAciklama,
    );
  }
}
