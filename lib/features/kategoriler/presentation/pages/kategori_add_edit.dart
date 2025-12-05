import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notlarim/core/widgets/custom_text_field.dart';

// Core & Localization
import '../../../../core/utils/color_helper.dart';
import '../../../../core/localization/localization.dart';

// Domain Entity
import '../../domain/entities/kategori.dart';

// DI Provider (Generic UseCases)
import '../providers/kategori_di_providers.dart';

class AddEditKategori extends ConsumerStatefulWidget {
  final Kategori? kategori;

  const AddEditKategori({super.key, this.kategori});

  @override
  ConsumerState<AddEditKategori> createState() => _AddEditKategoriState();
}

class _AddEditKategoriState extends ConsumerState<AddEditKategori> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late String renkKodu;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    baslik = widget.kategori?.baslik ?? '';
    aciklama = widget.kategori?.aciklama ?? '';
    renkKodu = widget.kategori?.renkKodu ?? '';
    selectedColor = renkKodu.isNotEmpty
        ? ColorHelper.hexToColor(renkKodu)
        : ColorHelper.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isEditing = widget.kategori != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${local.translate('general_categori')} ${isEditing ? local.translate('general_update') : local.translate('general_add')}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
        ),
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // withOpacity yerine withValues kullanımı
              color: selectedColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // --- BAŞLIK ALANI (CustomTextField) ---
                CustomTextField(
                  label: local.translate('general_title') ?? 'Başlık',
                  initialValue: baslik,
                  onChanged: (val) => baslik = val,
                  validator: (val) => val == null || val.isEmpty
                      ? local.translate('general_notEmpty')
                      : null,
                ),
                const SizedBox(height: 12),

                // --- AÇIKLAMA ALANI (CustomTextField) ---
                CustomTextField(
                  label: local.translate('general_explanation') ?? 'Açıklama',
                  initialValue: aciklama,
                  maxLines: 3, // Çok satırlı
                  onChanged: (val) => aciklama = val,
                  validator: (val) => val == null || val.isEmpty
                      ? local.translate('general_notEmpty')
                      : null,
                ),
                const SizedBox(height: 12),

                // --- RENK SEÇİCİ ---
                _buildRenkSecici(local),
                const SizedBox(height: 20),

                // --- KAYDET BUTONU ---
                _buildKaydetButton(local, isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Yardımcı Widget'lar ---

  Widget _buildRenkSecici(AppLocalizations local) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              local.translate('general_colorCode'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () => _showColorPickerDialog(),
              child: Text(local.translate('general_chooseColorMessage')),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Renk Kodunu Gösteren Alan (CustomTextField yerine sade bir Container)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
          child: Text(
            renkKodu.isEmpty
                ? (local.translate('general_colorCode') ?? '#FFFFFF')
                : renkKodu,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildKaydetButton(AppLocalizations local, bool isEditing) {
    final isFormValid =
        baslik.isNotEmpty && aciklama.isNotEmpty && renkKodu.isNotEmpty;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade700,
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: _saveKategori,
      child: Text(
        local.translate('general_save'),
        style: const TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _saveKategori() async {
    if (!_formKey.currentState!.validate()) return;

    final kategori = Kategori(
      id: widget.kategori?.id,
      baslik: baslik,
      aciklama: aciklama,
      renkKodu: renkKodu,
      kayitZamani: DateTime.now(),
      sabitMi: widget.kategori?.sabitMi ?? false,
    );

    try {
      if (widget.kategori == null) {
        // Generic Create
        await ref.read(createKategoriProvider).call(kategori);
      } else {
        // Generic Update
        await ref.read(updateKategoriProvider).call(kategori);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Kategori kaydedilemedi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori kaydedilemedi: $e')),
        );
      }
    }
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)
            .translate('general_chooseColorMessage')),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
                renkKodu = ColorHelper.colorToHex(color);
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('general_ok')),
          ),
        ],
      ),
    );
  }
}
