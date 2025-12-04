import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import '../../../../core/localization/localization.dart';
import '../../../../../core/config/app_config.dart';

// Domain
import '../../domain/entities/durum.dart';

// ✅ DI Providers
import '../providers/durum_di_providers.dart';

// UI
import 'durum_add_edit.dart';

class DurumDetail extends ConsumerStatefulWidget {
  final int durumId;

  const DurumDetail({super.key, required this.durumId});

  @override
  ConsumerState<DurumDetail> createState() => _DurumDetailState();
}

class _DurumDetailState extends ConsumerState<DurumDetail> {
  Durum? durum;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDurum();
  }

  Future<void> _loadDurum() async {
    setState(() => isLoading = true);
    try {
      // ✅ ref.read ile veri çekme
      final data = await ref.read(getDurumByIdProvider).call(widget.durumId);
      setState(() => durum = data);
    } catch (e) {
      debugPrint('❌ Durum yüklenemedi: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
                // ✅ ref.read ile silme
                await ref.read(deleteDurumProvider).call(widget.durumId);
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

    // ... (UI kodları aynı kalıyor, sadece _buildEditButton içindeki route güncellendi)

    if (isLoading || durum == null) {
      return Scaffold(
        backgroundColor: Colors.green.shade50,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Renk dönüşümü
    final color = Color(int.parse(durum!.renkKodu.substring(1), radix: 16))
        .withAlpha(255);

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
            '${local.translate('general_situation')} ${local.translate('general_detail')}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddEditDurum(durum: durum),
              ));
              _loadDurum();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(14),
          child: ListView(
            children: [
              _buildDetailRow(local.translate('general_title'), durum!.baslik,
                  isBold: true),
              const SizedBox(height: 10),
              _buildDetailRow(
                  local.translate('general_explanation'), durum!.aciklama),
              const SizedBox(height: 10),
              _buildDetailRow(local.translate('general_registrationDate'),
                  AppConfig.dateFormat.format(durum!.kayitZamani)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16)),
      ],
    );
  }
}
