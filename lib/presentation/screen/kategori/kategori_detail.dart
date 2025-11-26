import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';
import 'package:notlarim/presentation/Screen/kategori/kategori_add_edit.dart';
import '../../../../core/config/app_config.dart';

// Domain
import '../../../../domain/entities/kategori.dart';
import '../../../../domain/usecases/kategori/get_kategori_by_id.dart';
import '../../../../domain/usecases/kategori/delete_kategori.dart';

// DI
import '../../../../core/di/injection_container.dart';

class KategoriDetail extends StatefulWidget {
  final int kategoriId;

  const KategoriDetail({super.key, required this.kategoriId});

  @override
  State<KategoriDetail> createState() => _KategoriDetailState();
}

class _KategoriDetailState extends State<KategoriDetail> {
  Kategori? kategori;
  bool isLoading = false;

  // ✅ UseCase'ler DI'dan
  final GetKategoriById _getKategoriByIdUseCase = sl<GetKategoriById>();
  final DeleteKategori _deleteKategoriUseCase = sl<DeleteKategori>();

  @override
  void initState() {
    super.initState();
    _refreshKategori();
  }

  Future<void> _refreshKategori() async {
    setState(() => isLoading = true);
    try {
      final result = await _getKategoriByIdUseCase(widget.kategoriId);
      setState(() => kategori = result);
    } catch (e) {
      debugPrint('❌ Kategori yüklenirken hata: $e');
      setState(() => kategori = null);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final local = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(local.translate('general_deleteConfirmationTitle')),
          content: Text(local.translate('general_deleteConfirmationMessage')),
          actions: [
            TextButton(
              child: Text(local.translate('general_Cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(local.translate('general_Confirm')),
              onPressed: () async {
                if (kategori != null) {
                  await _deleteKategoriUseCase(kategori!.id!);
                  if (mounted) {
                    Navigator.of(context).pop(); // dialog kapat
                    Navigator.of(context).pop(true); // önceki sayfaya dön
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (kategori == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(local.translate('general_category')),
        ),
        body: Center(
          child: Text(
            local.translate('general_notFound'),
            style: const TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      );
    }

    Color kategoriRengi;
    try {
      kategoriRengi =
          Color(int.parse(kategori!.renkKodu.replaceFirst('#', '0xff')));
    } catch (e) {
      kategoriRengi = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${local.translate('general_category')} ${local.translate('general_detail')}',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        backgroundColor: Colors.green.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.white,
            onPressed: () async {
              if (kategori == null) return;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddEditKategori(kategori: kategori),
              ));
              _refreshKategori();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: kategoriRengi.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildLabelValue(
                local.translate('general_title'),
                kategori!.baslik,
              ),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_explanation'),
                kategori!.aciklama,
              ),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_colorCode'),
                kategori!.renkKodu,
              ),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_registrationDate'),
                AppConfig.dateFormat.format(kategori!.kayitZamani),
              ),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_isFixed'),
                kategori!.sabitMi ? 'Evet' : 'Hayır',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
