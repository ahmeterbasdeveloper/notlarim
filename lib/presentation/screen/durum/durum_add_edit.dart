import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../localization/localization.dart';

// Core
import '../../../../core/utils/color_helper.dart';

// Domain
import '../../../../domain/entities/durum.dart';
import '../../../../domain/usecases/durum/create_durum.dart';
import '../../../../domain/usecases/durum/update_durum.dart';

// DI
import '../../../../core/di/injection_container.dart';

class AddEditDurum extends StatefulWidget {
  final Durum? durum;

  const AddEditDurum({super.key, this.durum});

  @override
  State<AddEditDurum> createState() => _AddEditDurumState();
}

class _AddEditDurumState extends State<AddEditDurum> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late String renkKodu;
  late Color selectedColor;

  // ✅ UseCase'leri DI'dan çekiyoruz
  final CreateDurum _createDurumUseCase = sl<CreateDurum>();
  final UpdateDurum _updateDurumUseCase = sl<UpdateDurum>();

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
    final isEditing = widget.durum != null;
    final local = AppLocalizations.of(context);

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
              color: selectedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBaslikField(context),
                  const SizedBox(height: 12),
                  _buildAciklamaField(context),
                  const SizedBox(height: 12),
                  _buildRenkSecici(context),
                  const SizedBox(height: 20),
                  _buildKaydetButton(context, isEditing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... (Geri kalan _build... metodları aynı kalabilir, değişiklik yok)
  // Yer kazanmak için tekrarlamıyorum, sadece _saveDurum güncellenmeli:

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
        await _createDurumUseCase(durum);
        _showSnack(local.translate('general_saveSuccess'));
      } else {
        await _updateDurumUseCase(durum);
        _showSnack(local.translate('general_updateSuccess'));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Durum kaydedilemedi: $e');
      _showSnack(local.translate('general_errorMessage'));
    }
  }

  // ... (Diğer yardımcı metodlar: _buildBaslikField, _showColorPickerDialog vb. aynı)

  Widget _buildBaslikField(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.translate('general_title'),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: baslik,
          maxLines: 1,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: local.translate('general_titleWarningMessage'),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          validator: (v) => v == null || v.isEmpty
              ? local.translate('general_fillBlankFieldsMessage')
              : null,
          onChanged: (v) => setState(() => baslik = v),
        ),
      ],
    );
  }

  Widget _buildAciklamaField(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.translate('general_explanation'),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: aciklama,
          maxLines: 3,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: local.translate('general_explanationWarningMessage'),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          validator: (v) => v == null || v.isEmpty
              ? local.translate('general_fillBlankFieldsMessage')
              : null,
          onChanged: (v) => setState(() => aciklama = v),
        ),
      ],
    );
  }

  Widget _buildRenkSecici(BuildContext context) {
    final local = AppLocalizations.of(context);
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
              onPressed: () => _showColorPickerDialog(context),
              child: Text(local.translate('general_chooseColorMessage')),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          maxLines: 1,
          controller: TextEditingController(text: renkKodu),
          enabled: false,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: local.translate('general_colorCode'),
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildKaydetButton(BuildContext context, bool isEditing) {
    final local = AppLocalizations.of(context);
    final isFormValid = baslik.isNotEmpty && aciklama.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        onPressed: _saveDurum,
        child: Text(
          local.translate('general_save'),
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    final local = AppLocalizations.of(context);
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
