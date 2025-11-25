import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/entities/kategori.dart';
import 'package:notlarim/domain/entities/oncelik.dart';
import 'package:notlarim/domain/usecases/kategori/get_all_kategori.dart';
import 'package:notlarim/domain/usecases/oncelik/get_all_oncelik.dart';
import 'package:notlarim/localization/localization.dart';

/// 🧩 Hatırlatıcı form bileşeni — Create / Update işlemlerinde ortak kullanılır.
/// Entity (Hatirlatici) yapısındaki tüm alanları kapsar.
class HatirlaticiForm extends StatefulWidget {
  final Hatirlatici? initialHatirlatici;

  /// Callbackler
  final ValueChanged<int> onChangedKategori;
  final ValueChanged<int> onChangedOncelik;
  final ValueChanged<String> onChangedBaslik;
  final ValueChanged<String> onChangedAciklama;
  final ValueChanged<DateTime> onChangedHatirlatmaTarihi;
  final ValueChanged<int>? onChangedDurum; // opsiyonel durum alanı

  /// UseCase'ler
  final GetAllKategori getAllKategoriUseCase;
  final GetAllOncelik getAllOncelikUseCase;

  const HatirlaticiForm({
    super.key,
    this.initialHatirlatici,
    required this.onChangedKategori,
    required this.onChangedOncelik,
    required this.onChangedBaslik,
    required this.onChangedAciklama,
    required this.onChangedHatirlatmaTarihi,
    required this.getAllKategoriUseCase,
    required this.getAllOncelikUseCase,
    this.onChangedDurum,
  });

  @override
  State<HatirlaticiForm> createState() => _HatirlaticiFormState();
}

class _HatirlaticiFormState extends State<HatirlaticiForm> {
  late TextEditingController _hatirlatmaTarihiController;
  late TextEditingController _kayitZamaniController;

  int? _selectedKategoriId;
  int? _selectedOncelikId;
  int _selectedDurumId = 1;

  String _baslik = '';
  String _aciklama = '';
  DateTime _hatirlatmaTarihi = DateTime.now();
  DateTime _kayitZamani = DateTime.now();

  @override
  void initState() {
    super.initState();

    final h = widget.initialHatirlatici;
    _selectedKategoriId = h?.kategoriId;
    _selectedOncelikId = h?.oncelikId;
    _selectedDurumId = h?.durumId ?? 1;
    _baslik = h?.baslik ?? '';
    _aciklama = h?.aciklama ?? '';
    _hatirlatmaTarihi = h?.hatirlatmaTarihiZamani ?? DateTime.now();
    _kayitZamani = h?.kayitZamani ?? DateTime.now();

    _hatirlatmaTarihiController = TextEditingController(
      text: DateFormat('dd.MM.yyyy').format(_hatirlatmaTarihi),
    );
    _kayitZamaniController = TextEditingController(
      text: DateFormat('dd.MM.yyyy HH:mm').format(_kayitZamani),
    );
  }

  @override
  void dispose() {
    _hatirlatmaTarihiController.dispose();
    _kayitZamaniController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// 🗂️ Kategori & Öncelik
          Row(
            children: [
              Expanded(child: _buildKategoriDropdown(loc)),
              const SizedBox(width: 8),
              Expanded(child: _buildOncelikDropdown(loc)),
            ],
          ),
          const SizedBox(height: 12),

          /// 🏷️ Başlık
          _buildTextField(
            label: loc.translate('general_title'),
            hint: '${loc.translate('general_enter')} ${loc.translate('general_title')}',
            initialValue: _baslik,
            onChanged: (v) {
              _baslik = v;
              widget.onChangedBaslik(v);
            },
          ),
          const SizedBox(height: 12),

          /// 📝 Açıklama
          _buildTextField(
            label: loc.translate('general_explanation'),
            hint: loc.translate('general_somethingWriteHereMessage'),
            initialValue: _aciklama,
            maxLines: 3,
            onChanged: (v) {
              _aciklama = v;
              widget.onChangedAciklama(v);
            },
          ),
          const SizedBox(height: 12),

          /// ⏰ Hatırlatma Tarihi
          _buildDatePickerField(
            loc: loc,
            controller: _hatirlatmaTarihiController,
            label: loc.translate('general_reminderDate'),
            selectedDate: _hatirlatmaTarihi,
            onChanged: (picked) {
              setState(() {
                _hatirlatmaTarihi = picked;
                _hatirlatmaTarihiController.text =
                    DateFormat('dd.MM.yyyy').format(picked);
              });
              widget.onChangedHatirlatmaTarihi(picked);
            },
          ),
          const SizedBox(height: 12),

          /// 🕓 Kayıt Zamanı (sadece bilgi amaçlı, kullanıcı değiştirmez)
          TextFormField(
            controller: _kayitZamaniController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: loc.translate('general_createdDate'),
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.info_outline),
            ),
          ),
          const SizedBox(height: 12),

          /// ⚙️ Durum (isteğe bağlı)
          _buildDurumDropdown(loc),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🧩 ALT BİLEŞENLER
  // --------------------------------------------------------------------------

  Widget _buildKategoriDropdown(AppLocalizations loc) {
    return FutureBuilder<List<Kategori>>(
      future: widget.getAllKategoriUseCase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('${loc.translate('general_dataLoadingError')}: ${snapshot.error}');
        }

        final items = snapshot.data!
            .map(
              (k) => DropdownMenuItem<int>(
                value: k.id,
                child: Text(k.baslik),
              ),
            )
            .toList();

        return DropdownButtonFormField<int>(
          initialValue: _selectedKategoriId,
          items: items,
          onChanged: (v) {
            setState(() => _selectedKategoriId = v);
            if (v != null) widget.onChangedKategori(v);
          },
          decoration: InputDecoration(
            labelText: '${loc.translate('general_category')} ${loc.translate('general_select')}',
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _buildOncelikDropdown(AppLocalizations loc) {
    return FutureBuilder<List<Oncelik>>(
      future: widget.getAllOncelikUseCase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('${loc.translate('general_dataLoadingError')}: ${snapshot.error}');
        }

        final items = snapshot.data!
            .map(
              (o) => DropdownMenuItem<int>(
                value: o.id,
                child: Text(o.baslik),
              ),
            )
            .toList();

        return DropdownButtonFormField<int>(
          initialValue: _selectedOncelikId,
          items: items,
          onChanged: (v) {
            setState(() => _selectedOncelikId = v);
            if (v != null) widget.onChangedOncelik(v);
          },
          decoration: InputDecoration(
            labelText: '${loc.translate('general_priority')} ${loc.translate('general_select')}',
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    int maxLines = 1,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickerField({
    required AppLocalizations loc,
    required TextEditingController controller,
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) onChanged(pickedDate);
      },
    );
  }

  Widget _buildDurumDropdown(AppLocalizations loc) {
    final durumlar = [
      {'id': 1, 'ad': loc.translate('general_active')},
      {'id': 2, 'ad': loc.translate('general_passive')},
    ];

    return DropdownButtonFormField<int>(
      initialValue: _selectedDurumId,
      items: durumlar
          .map(
            (d) => DropdownMenuItem<int>(
              value: d['id'] as int,
              child: Text(d['ad'] as String),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() => _selectedDurumId = v);
          widget.onChangedDurum?.call(v);
        }
      },
      decoration: InputDecoration(
        labelText: loc.translate('general_status'),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
