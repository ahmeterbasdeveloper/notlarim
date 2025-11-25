import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Core
import '../../../core/utils/color_helper.dart';
import '../../../localization/localization.dart';

// Domain
import '../../../domain/entities/oncelik.dart';
import '../../../domain/usecases/oncelik/create_oncelik.dart';
import '../../../domain/usecases/oncelik/update_oncelik.dart';

// Data
import '../../../data/repositories/oncelik_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

/// 🧩 Öncelik ekleme ve güncelleme ekranı.
/// Clean Architecture + Çoklu Dil Desteği (AppLocalizations)
class AddEditOncelik extends StatefulWidget {
  final Oncelik? oncelik;

  const AddEditOncelik({super.key, this.oncelik});

  @override
  State<AddEditOncelik> createState() => _AddEditOncelikState();
}

class _AddEditOncelikState extends State<AddEditOncelik> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late String renkKodu;
  late bool sabitMi;
  late Color selectedColor;

  late final CreateOncelik _createOncelikUseCase;
  late final UpdateOncelik _updateOncelikUseCase;

  @override
  void initState() {
    super.initState();

    final repository = OncelikRepositoryImpl(DatabaseHelper.instance);
    _createOncelikUseCase = CreateOncelik(repository);
    _updateOncelikUseCase = UpdateOncelik(repository);

    baslik = widget.oncelik?.baslik ?? '';
    aciklama = widget.oncelik?.aciklama ?? '';
    renkKodu = widget.oncelik?.renkKodu ?? '';
    sabitMi = widget.oncelik?.sabitMi ?? false;
    selectedColor = renkKodu.isNotEmpty
        ? ColorHelper.hexToColor(renkKodu)
        : ColorHelper.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.oncelik != null;
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${local.translate('general_priority')} '
          '${isEditing ? local.translate('general_update') : local.translate('general_add')}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.amber,
          ),
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

  /// Başlık alanı
  Widget _buildBaslikField(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.translate('general_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
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

  /// Açıklama alanı
  Widget _buildAciklamaField(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.translate('general_explanation'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
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

  /// Renk seçici alanı
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
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

  /// Kaydet / Güncelle butonu
  Widget _buildKaydetButton(BuildContext context, bool isEditing) {
    final local = AppLocalizations.of(context);
    final isFormValid = baslik.isNotEmpty && aciklama.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        onPressed: _saveOncelik,
        child: Text(
          local.translate('general_save'),
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Önceliği kaydet veya güncelle
  Future<void> _saveOncelik() async {
    final local = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final oncelik = Oncelik(
      id: widget.oncelik?.id,
      baslik: baslik,
      aciklama: aciklama,
      renkKodu: renkKodu,
      kayitZamani: DateTime.now(),
      sabitMi: widget.oncelik?.sabitMi ?? false,
    );

    try {
      if (widget.oncelik == null) {
        await _createOncelikUseCase(oncelik);
        _showSnack(local.translate('general_saveSuccess'));
      } else {
        await _updateOncelikUseCase(oncelik);
        _showSnack(local.translate('general_updateSuccess'));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Öncelik kaydedilemedi: $e');
      _showSnack(local.translate('general_errorMessage'));
    }
  }

  /// Renk seçici dialog
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

  /// Snackbar bildirimi
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
