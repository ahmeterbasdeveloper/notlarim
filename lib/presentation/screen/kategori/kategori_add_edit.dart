import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Core & Localization
import '../../../core/utils/color_helper.dart';
import '../../../localization/localization.dart';

// Domain
import '../../../domain/entities/kategori.dart';
import '../../../domain/usecases/kategori/create_kategori.dart';
import '../../../domain/usecases/kategori/update_kategori.dart';

// Data
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

class AddEditKategori extends StatefulWidget {
  final Kategori? kategori;

  const AddEditKategori({super.key, this.kategori});

  @override
  State<AddEditKategori> createState() => _AddEditKategoriState();
}

class _AddEditKategoriState extends State<AddEditKategori> {
  final _formKey = GlobalKey<FormState>();

  late String baslik;
  late String aciklama;
  late String renkKodu;
  late Color selectedColor;

  late final CreateKategori _createKategoriUseCase;
  late final UpdateKategori _updateKategoriUseCase;

  @override
  void initState() {
    super.initState();

    final repo = KategoriRepositoryImpl(DatabaseHelper.instance);
    _createKategoriUseCase = CreateKategori(repo);
    _updateKategoriUseCase = UpdateKategori(repo);

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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.amber),
        ),
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              color: selectedColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildBaslikField(local),
                const SizedBox(height: 12),
                _buildAciklamaField(local),
                const SizedBox(height: 12),
                _buildRenkSecici(local),
                const SizedBox(height: 20),
                _buildKaydetButton(local, isEditing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBaslikField(AppLocalizations local) => TextFormField(
        initialValue: baslik,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: local.translate('general_title'),
        ),
        validator: (v) => v == null || v.isEmpty ? local.translate('general_notEmpty') : null,
        onChanged: (v) => baslik = v,
      );

  Widget _buildAciklamaField(AppLocalizations local) => TextFormField(
        maxLines: 3,
        initialValue: aciklama,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: local.translate('general_explanation'),
        ),
        validator: (v) => v == null || v.isEmpty ? local.translate('general_notEmpty') : null,
        onChanged: (v) => aciklama = v,
      );

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
        TextFormField(
          controller: TextEditingController(text: renkKodu),
          enabled: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: local.translate('general_colorCode'),
          ),
        ),
      ],
    );
  }

  Widget _buildKaydetButton(AppLocalizations local, bool isEditing) {
    final isFormValid = baslik.isNotEmpty && aciklama.isNotEmpty && renkKodu.isNotEmpty;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isFormValid ? Colors.indigo.shade600 : Colors.blueGrey.shade700,
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: _saveKategori,
      child: Text(
        local.translate('general_save'),
        style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
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
        await _createKategoriUseCase(kategori);
      } else {
        await _updateKategoriUseCase(kategori);
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
        title: Text(AppLocalizations.of(context).translate('general_chooseColorMessage')),
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
