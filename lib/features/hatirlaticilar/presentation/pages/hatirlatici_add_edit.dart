import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notlarim/features/kategori/providers/kategori_di_providers.dart';
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';
import 'package:notlarim/core/widgets/custom_text_field.dart';

// Localization
import '../../../../core/localization/localization.dart';

// Domain Entities
import '../../domain/entities/hatirlatici.dart';
import '../../../kategori/domain/entities/kategori.dart';
import '../../../oncelik/domain/entities/oncelik.dart';

// DI Providers
import '../providers/hatirlatici_di_providers.dart';

class HatirlaticiAddEdit extends ConsumerStatefulWidget {
  final Hatirlatici? hatirlatici;

  const HatirlaticiAddEdit({super.key, this.hatirlatici});

  @override
  ConsumerState<HatirlaticiAddEdit> createState() => _HatirlaticiAddEditState();
}

class _HatirlaticiAddEditState extends ConsumerState<HatirlaticiAddEdit> {
  final _formKey = GlobalKey<FormState>();

  // Değişkenler
  late String _baslik;
  late String _aciklama;

  // Tarih ve zaman gösterimi için controller kullanmaya devam ediyoruz
  late TextEditingController _hatirlatmaTarihiController;
  late TextEditingController _kayitZamaniController;

  int? _selectedKategoriId;
  int? _selectedOncelikId;
  int _selectedDurumId = 1;

  DateTime _hatirlatmaTarihiZamani = DateTime.now();
  final DateTime _kayitZamani = DateTime.now();

  // Dropdown Listeleri
  List<Kategori> _kategoriList = [];
  List<Oncelik> _oncelikList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Mevcut değerleri veya varsayılanları ata
    _baslik = widget.hatirlatici?.baslik ?? '';
    _aciklama = widget.hatirlatici?.aciklama ?? '';

    _selectedKategoriId = widget.hatirlatici?.kategoriId;
    _selectedOncelikId = widget.hatirlatici?.oncelikId;
    _selectedDurumId = widget.hatirlatici?.durumId ?? 1;

    _hatirlatmaTarihiZamani =
        widget.hatirlatici?.hatirlatmaTarihiZamani ?? DateTime.now();

    // Tarih alanları için controller (Görsel gösterim)
    _hatirlatmaTarihiController = TextEditingController(
      text: DateFormat('dd.MM.yyyy HH:mm').format(_hatirlatmaTarihiZamani),
    );

    // Kayıt zamanı (Salt okunur bilgi amaçlı)
    _kayitZamaniController = TextEditingController(
      text: DateFormat('dd.MM.yyyy')
          .format(widget.hatirlatici?.kayitZamani ?? _kayitZamani),
    );

    // Verileri Yükle
    _loadDropdownData();
  }

  @override
  void dispose() {
    _hatirlatmaTarihiController.dispose();
    _kayitZamaniController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final kategoriler = await ref.read(getAllKategoriProvider).call();
      final oncelikler = await ref.read(getAllOncelikProvider).call();

      if (mounted) {
        setState(() {
          _kategoriList = kategoriler;
          _oncelikList = oncelikler;

          // Yeni kayıt ise ve liste doluysa varsayılan olarak ilk elemanları seç
          if (widget.hatirlatici == null) {
            if (_kategoriList.isNotEmpty)
              _selectedKategoriId = _kategoriList.first.id;
            if (_oncelikList.isNotEmpty)
              _selectedOncelikId = _oncelikList.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Veri yükleme hatası: $e');
      if (mounted) setState(() => _isLoading = false);
    }
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
          '${loc.translate('general_reminder')} ${isUpdating ? loc.translate('general_update') : loc.translate('general_add')}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Yan yana Dropdownlar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildKategoriDropdown(loc)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildOncelikDropdown(loc)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- BAŞLIK ALANI (CustomTextField) ---
                    CustomTextField(
                      label: loc.translate('general_title') ?? 'Başlık',
                      initialValue: _baslik,
                      onChanged: (val) => _baslik = val,
                      validator: (val) => val == null || val.isEmpty
                          ? loc.translate('general_notEmpty')
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // --- AÇIKLAMA ALANI (CustomTextField) ---
                    CustomTextField(
                      label: loc.translate('general_explanation') ?? 'Açıklama',
                      initialValue: _aciklama,
                      maxLines: 3,
                      onChanged: (val) => _aciklama = val,
                    ),
                    const SizedBox(height: 16),

                    _buildTarihSecici(loc),
                    const SizedBox(height: 16),

                    _buildDurumDropdown(loc),
                    const SizedBox(height: 16),

                    // Bilgi amaçlı kayıt tarihi alanı (Salt okunur)
                    TextFormField(
                      controller: _kayitZamaniController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: loc.translate('general_registrationDate'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.info_outline),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildKaydetButton(loc),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // 🧩 YARDIMCI WIDGET METOTLARI
  // ---------------------------------------------------------------------------

  Widget _buildKategoriDropdown(AppLocalizations loc) {
    if (_kategoriList.isEmpty) {
      return Text(loc.translate('general_notFound'));
    }

    // Seçili ID listede yoksa null yap (Güvenlik)
    if (_selectedKategoriId != null &&
        !_kategoriList.any((e) => e.id == _selectedKategoriId)) {
      _selectedKategoriId = null;
    }

    return DropdownButtonFormField<int>(
      value: _selectedKategoriId,
      isExpanded: true,
      items: _kategoriList.map((k) {
        return DropdownMenuItem(
          value: k.id,
          child: Text(k.baslik, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedKategoriId = v),
      decoration: InputDecoration(
        labelText: loc.translate('general_category'),
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      validator: (v) => v == null ? loc.translate('general_notEmpty') : null,
    );
  }

  Widget _buildOncelikDropdown(AppLocalizations loc) {
    if (_oncelikList.isEmpty) {
      return Text(loc.translate('general_notFound'));
    }

    if (_selectedOncelikId != null &&
        !_oncelikList.any((e) => e.id == _selectedOncelikId)) {
      _selectedOncelikId = null;
    }

    return DropdownButtonFormField<int>(
      value: _selectedOncelikId,
      isExpanded: true,
      items: _oncelikList.map((o) {
        return DropdownMenuItem(
          value: o.id,
          child: Text(o.baslik, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedOncelikId = v),
      decoration: InputDecoration(
        labelText: loc.translate('general_priority'),
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      validator: (v) => v == null ? loc.translate('general_notEmpty') : null,
    );
  }

  Widget _buildTarihSecici(AppLocalizations loc) {
    return TextFormField(
      controller: _hatirlatmaTarihiController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: loc.translate('general_reminderDate'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_month),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      onTap: () async {
        // 1. Tarih Seçimi
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _hatirlatmaTarihiZamani,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null && mounted) {
          // 2. Saat Seçimi
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_hatirlatmaTarihiZamani),
          );

          if (pickedTime != null) {
            setState(() {
              _hatirlatmaTarihiZamani = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              _hatirlatmaTarihiController.text = DateFormat('dd.MM.yyyy HH:mm')
                  .format(_hatirlatmaTarihiZamani);
            });
          }
        }
      },
    );
  }

  Widget _buildDurumDropdown(AppLocalizations loc) {
    final durumlar = [
      {'id': 1, 'ad': loc.translate('general_active')},
      {'id': 2, 'ad': loc.translate('general_passive')}
    ];

    return DropdownButtonFormField<int>(
      value: _selectedDurumId,
      items: durumlar.map((d) {
        return DropdownMenuItem(
          value: d['id'] as int,
          child: Text(d['ad'] as String),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedDurumId = v);
      },
      decoration: InputDecoration(
        labelText: loc.translate('general_status'),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.toggle_on),
      ),
    );
  }

  Widget _buildKaydetButton(AppLocalizations loc) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade700,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.save, color: Colors.white),
      label: Text(
        loc.translate('general_save'),
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      onPressed: _saveHatirlatici,
    );
  }

  Future<void> _saveHatirlatici() async {
    if (!_formKey.currentState!.validate()) return;

    // Basit Validasyon: ID'lerin doluluğunu kontrol et
    if (_selectedKategoriId == null || _selectedOncelikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori ve Öncelik seçimi zorunludur.')),
      );
      return;
    }

    final loc = AppLocalizations.of(context);

    final entity = Hatirlatici(
      id: widget.hatirlatici?.id,
      baslik: _baslik,
      aciklama: _aciklama,
      kategoriId: _selectedKategoriId!,
      oncelikId: _selectedOncelikId!,
      hatirlatmaTarihiZamani: _hatirlatmaTarihiZamani,
      kayitZamani: widget.hatirlatici?.kayitZamani ?? DateTime.now(),
      durumId: _selectedDurumId,
    );

    try {
      if (widget.hatirlatici != null) {
        // Generic Update
        await ref.read(updateHatirlaticiProvider).call(entity);
      } else {
        // Generic Create
        await ref.read(createHatirlaticiProvider).call(entity);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Listeyi güncellemek için true dön
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.hatirlatici != null
                ? loc.translate('general_updated')
                : loc.translate('general_added')),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red.shade800),
        );
      }
    }
  }
}
