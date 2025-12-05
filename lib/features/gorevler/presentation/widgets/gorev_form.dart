import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notlarim/core/localization/localization.dart';

// Domain Entities
import '../../../kategoriler/domain/entities/kategori.dart';
import '../../../oncelik/domain/entities/oncelik.dart';

class GorevlerForm extends StatefulWidget {
  final String? baslik;
  final String? aciklama;
  final int? kategoriId;
  final int? oncelikId;
  final DateTime? baslamaTarihiZamani;
  final DateTime? bitisTarihiZamani;

  final ValueChanged<int> onChangedKategori;
  final ValueChanged<int> onChangedOncelik;
  final ValueChanged<String> onChangedBaslik;
  final ValueChanged<String> onChangedAciklama;
  final ValueChanged<DateTime> onChangedBaslamaTarihiZamani;
  final ValueChanged<DateTime> onChangedBitisTarihiZamani;

  // ✅ ARTIK USECASE YOK, DİREKT LİSTE ALIYORUZ
  final List<Kategori> kategoriListesi;
  final List<Oncelik> oncelikListesi;

  const GorevlerForm({
    super.key,
    this.baslik = '',
    this.aciklama = '',
    required this.kategoriId,
    required this.oncelikId,
    required this.baslamaTarihiZamani,
    required this.bitisTarihiZamani,
    required this.onChangedKategori,
    required this.onChangedOncelik,
    required this.onChangedBaslik,
    required this.onChangedAciklama,
    required this.onChangedBaslamaTarihiZamani,
    required this.onChangedBitisTarihiZamani,
    required this.kategoriListesi, // ✅
    required this.oncelikListesi, // ✅
  });

  @override
  State<GorevlerForm> createState() => _GorevlerFormState();
}

class _GorevlerFormState extends State<GorevlerForm> {
  int? selectedKategoriId;
  int? selectedOncelikId;
  late TextEditingController _baslamaTarihiController;
  late TextEditingController _bitisTarihiController;

  @override
  void initState() {
    super.initState();
    selectedKategoriId = widget.kategoriId;
    selectedOncelikId = widget.oncelikId;

    _baslamaTarihiController = TextEditingController(
      text: _formatDate(widget.baslamaTarihiZamani),
    );
    _bitisTarihiController = TextEditingController(
      text: _formatDate(widget.bitisTarihiZamani),
    );
  }

  // DidUpdateWidget ekleyerek parent state değiştiğinde (veri yüklendiğinde) formu güncelle
  @override
  void didUpdateWidget(covariant GorevlerForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kategoriId != widget.kategoriId) {
      selectedKategoriId = widget.kategoriId;
    }
    if (oldWidget.oncelikId != widget.oncelikId) {
      selectedOncelikId = widget.oncelikId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _buildKategoriDropdown(local)),
                const SizedBox(width: 8),
                Expanded(child: _buildOncelikDropdown(local)),
              ],
            ),
            const SizedBox(height: 8),
            _buildBaslik(local),
            const SizedBox(height: 8),
            _buildAciklama(local),
            const SizedBox(height: 8),
            _buildBaslamaTarihi(local),
            const SizedBox(height: 8),
            _buildBitisTarihi(local),
          ],
        ),
      ),
    );
  }

  Widget _buildKategoriDropdown(AppLocalizations local) {
    // Liste boşsa bilgi ver veya boş göster
    if (widget.kategoriListesi.isEmpty) {
      return Text(local.translate('general_notFound'));
    }

    final items = widget.kategoriListesi
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
            '${local.translate('general_categori')} ${local.translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildOncelikDropdown(AppLocalizations local) {
    if (widget.oncelikListesi.isEmpty) {
      return Text(local.translate('general_notFound'));
    }

    final items = widget.oncelikListesi
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
            '${local.translate('general_priority')} ${local.translate('general_select')}',
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ... (TextField ve DatePicker metodları öncekiyle aynı kalabilir)
  // Kısaltma amacıyla buraya eklemiyorum, dosyanızdaki mevcut _buildBaslik, _buildAciklama vb. kullanın.

  // Sadece context ve controller kullanımlarına dikkat edin.

  Widget _buildBaslik(AppLocalizations local) => TextFormField(
        maxLines: 1,
        initialValue: widget.baslik,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText:
              '${local.translate('general_title')} ${local.translate('general_enter')}',
        ),
        validator: (value) => value == null || value.isEmpty
            ? local.translate('general_notEmpty')
            : null,
        onChanged: widget.onChangedBaslik,
      );

  Widget _buildAciklama(AppLocalizations local) => TextFormField(
        maxLines: 3,
        initialValue: widget.aciklama,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText:
              '${local.translate('general_explanation')} ${local.translate('general_enter')}',
        ),
        validator: (value) => value == null || value.isEmpty
            ? local.translate('general_notEmpty')
            : null,
        onChanged: widget.onChangedAciklama,
      );

  Widget _buildBaslamaTarihi(AppLocalizations local) => TextFormField(
        readOnly: true,
        controller: _baslamaTarihiController,
        decoration: InputDecoration(
          labelText:
              '${local.translate('general_startingDate')} ${local.translate('general_select')}',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(context, _baslamaTarihiController, true),
      );

  Widget _buildBitisTarihi(AppLocalizations local) => TextFormField(
        readOnly: true,
        controller: _bitisTarihiController,
        decoration: InputDecoration(
          labelText:
              '${local.translate('general_endDate')} ${local.translate('general_select')}',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(context, _bitisTarihiController, false),
      );

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
        if (isStart) {
          widget.onChangedBaslamaTarihiZamani(picked);
        } else {
          widget.onChangedBitisTarihiZamani(picked);
        }
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat('dd.MM.yyyy').format(date) : '';
}
