import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:notlarim/core/widgets/custom_text_field.dart';

// Core & Localization
import '../../../../../core/utils/color_helper.dart';
import '../../../../core/localization/localization.dart';

// Domain
import '../../domain/entities/durum.dart';

// DI Providers
import '../providers/durum_di_providers.dart';

class AddEditDurum extends ConsumerStatefulWidget {
  final Durum? durum;

  const AddEditDurum({super.key, this.durum});

  @override
  ConsumerState<AddEditDurum> createState() => _AddEditDurumState();
}

class _AddEditDurumState extends ConsumerState<AddEditDurum> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late String renkKodu;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    baslik = widget.durum?.baslik ?? '';
    aciklama = widget.durum?.aciklama ?? '';
    renkKodu = widget.durum?.renkKodu ?? '';
    selectedColor = renkKodu.isNotEmpty
        ? ColorHelper.hexToColor(renkKodu)
        : ColorHelper.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isEditing = widget.durum != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${local.translate('general_situation')} '
          '${isEditing ? local.translate('general_update') : local.translate('general_add')}',
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
          child: Container(
            decoration: BoxDecoration(
              // Deprecated 'withOpacity' yerine 'withValues'
              color: selectedColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- BAŞLIK ALANI (CustomTextField) ---
                  CustomTextField(
                    label: local.translate('general_title') ?? 'Başlık',
                    initialValue: baslik,
                    onChanged: (val) => baslik = val,
                    validator: (val) => val == null || val.isEmpty
                        ? local.translate('general_fillBlankFieldsMessage')
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // --- AÇIKLAMA ALANI (CustomTextField) ---
                  CustomTextField(
                    label: local.translate('general_explanation') ?? 'Açıklama',
                    initialValue: aciklama,
                    maxLines: 3, // Çok satırlı görünüm
                    onChanged: (val) => aciklama = val,
                    validator: (val) => val == null || val.isEmpty
                        ? local.translate('general_fillBlankFieldsMessage')
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
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black),
            ),
            ElevatedButton(
              onPressed: () => _showColorPickerDialog(local),
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
    final isFormValid = baslik.isNotEmpty && aciklama.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade700,
          ),
          onPressed: _saveDurum,
          child: Text(
            local.translate('general_save'),
            style: const TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDurum() async {
    final local = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final durum = Durum(
      id: widget.durum?.id,
      baslik: baslik,
      aciklama: aciklama,
      renkKodu: renkKodu,
      kayitZamani: DateTime.now(),
      sabitMi: widget.durum?.sabitMi ?? 0,
    );

    try {
      if (widget.durum == null) {
        // Generic Create Provider
        await ref.read(createDurumProvider).call(durum);
        _showSnack(local.translate('general_saveSuccess'));
      } else {
        // Generic Update Provider
        await ref.read(updateDurumProvider).call(durum);
        _showSnack(local.translate('general_updateSuccess'));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Durum kaydedilemedi: $e');
      _showSnack(local.translate('general_errorMessage'));
    }
  }

  void _showColorPickerDialog(AppLocalizations local) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(local.translate('general_chooseColorMessage')),
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
            child: Text(local.translate('general_ok')),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
