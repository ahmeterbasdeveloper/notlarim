import 'package:flutter/material.dart';

// 🌍 Çoklu dil desteği
import '../../../../localization/localization.dart';

// Core config (tarih formatı için)
import '../../../../core/config/app_config.dart';

// Domain & Data
import '../../../domain/entities/durum.dart';
import '../../../domain/usecases/durum/get_durum_by_id.dart';
import '../../../domain/usecases/durum/delete_durum.dart';
import '../../../data/repositories/durum_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

// UI ekranları
import 'durum_add_edit.dart';

/// 🧾 Durum Detay Ekranı (Clean Architecture + Çoklu Dil)
class DurumDetail extends StatefulWidget {
  final int durumId;

  const DurumDetail({super.key, required this.durumId});

  @override
  State<DurumDetail> createState() => _DurumDetailState();
}

class _DurumDetailState extends State<DurumDetail> {
  late final GetDurumById _getDurumUseCase;
  late final DeleteDurum _deleteDurumUseCase;

  Durum? durum;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final repository = DurumRepositoryImpl(DatabaseHelper.instance);
    _getDurumUseCase = GetDurumById(repository);
    _deleteDurumUseCase = DeleteDurum(repository);
    _loadDurum();
  }

  /// 📦 Durum bilgilerini yükler
  Future<void> _loadDurum() async {
    setState(() => isLoading = true);
    try {
      final data = await _getDurumUseCase(widget.durumId);
      setState(() => durum = data);
    } catch (e) {
      debugPrint('❌ Durum yüklenemedi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)
              .translate('general_errorLoading'))),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// 🗑️ Silme onayı penceresi
  Future<void> _showDeleteConfirmationDialog() async {
    final local = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(local.translate('general_deleteConfirmationTitle')),
          content: Text(local.translate('general_deleteConfirmationMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(local.translate('general_Cancel')),
            ),
            TextButton(
              onPressed: () async {
                await _deleteDurumUseCase(widget.durumId);
                if (mounted) {
                  Navigator.of(context).pop(); // dialog
                  Navigator.of(context).pop(true); // sayfa
                }
              },
              child: Text(local.translate('general_Confirm')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    if (isLoading || durum == null) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final color =
        Color(int.parse(durum!.renkKodu.substring(1), radix: 16)).withAlpha(255);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${local.translate('general_situation')} '
          '${local.translate('general_detail')}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        actions: [
          _buildEditButton(context, local),
          _buildDeleteButton(local),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ListView(
              children: [
                _buildDetailRow(
                  title: local.translate('general_title'),
                  value: durum!.baslik,
                  isBold: true,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  title: local.translate('general_explanation'),
                  value: durum!.aciklama,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  title: local.translate('general_colorCode'),
                  value: durum!.renkKodu,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  title: local.translate('general_registrationDate'),
                  value: AppConfig.dateFormat.format(durum!.kayitZamani),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Ortak detay satırı
  Widget _buildDetailRow({
    required String title,
    required String value,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// 🖊️ Düzenle butonu
  Widget _buildEditButton(BuildContext context, AppLocalizations local) {
    return IconButton(
      icon: const Icon(Icons.edit_outlined),
      color: Colors.white,
      tooltip: local.translate('general_update'),
      onPressed: () async {
        if (isLoading) return;
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddEditDurum(durum: durum),
        ));
        _loadDurum();
      },
    );
  }

  /// 🗑️ Sil butonu
  Widget _buildDeleteButton(AppLocalizations local) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: Colors.white,
      tooltip: local.translate('general_delete'),
      onPressed: _showDeleteConfirmationDialog,
    );
  }
}
