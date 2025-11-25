import 'package:flutter/material.dart';
import '../../../../localization/localization.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/color_helper.dart';

// Domain
import '../../../domain/entities/oncelik.dart';
import '../../../domain/usecases/oncelik/get_oncelik_by_id.dart';
import '../../../domain/usecases/oncelik/delete_oncelik.dart';

// Data
import '../../../data/repositories/oncelik_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

// UI
import '../oncelik/oncelik_add_edit.dart';

/// 📝 Öncelik detay sayfası.
/// Clean Architecture — Entity & UseCase tabanlı yapı.
class OncelikDetail extends StatefulWidget {
  final int oncelikId;

  const OncelikDetail({super.key, required this.oncelikId});

  @override
  State<OncelikDetail> createState() => _OncelikDetailState();
}

class _OncelikDetailState extends State<OncelikDetail> {
  Oncelik? oncelik;
  bool isLoading = false;

  late final GetOncelikById _getOncelikByIdUseCase;
  late final DeleteOncelik _deleteOncelikUseCase;

  @override
  void initState() {
    super.initState();

    final repository = OncelikRepositoryImpl(DatabaseHelper.instance);
    _getOncelikByIdUseCase = GetOncelikById(repository);
    _deleteOncelikUseCase = DeleteOncelik(repository);

    _refreshOncelik();
  }

  Future<void> _refreshOncelik() async {
    setState(() => isLoading = true);
    try {
      final result = await _getOncelikByIdUseCase(widget.oncelikId);
      setState(() => oncelik = result);
    } catch (e) {
      debugPrint('❌ Öncelik yüklenirken hata: $e');
      setState(() => oncelik = null);
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
                if (oncelik != null) {
                  await _deleteOncelikUseCase(oncelik!.id!);
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

    if (oncelik == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(local.translate('general_priority')),
        ),
        body: Center(
          child: Text(
            local.translate('general_notFound'),
            style: const TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      );
    }

    Color oncelikRengi;
    try {
      oncelikRengi = ColorHelper.hexToColor(oncelik!.renkKodu);
    } catch (e) {
      oncelikRengi = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${local.translate('general_priority')} ${local.translate('general_detail')}',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        backgroundColor: Colors.green.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.white,
            onPressed: () async {
              if (oncelik == null) return;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddEditOncelik(oncelik: oncelik),
              ));
              _refreshOncelik();
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
            color: oncelikRengi.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildLabelValue(local.translate('general_title'), oncelik!.baslik),
              const SizedBox(height: 12),
              _buildLabelValue(local.translate('general_explanation'), oncelik!.aciklama),
              const SizedBox(height: 12),
              _buildLabelValue(local.translate('general_colorCode'), oncelik!.renkKodu),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_registrationDate'),
                AppConfig.dateFormat.format(oncelik!.kayitZamani),
              ),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_isFixed'),
                oncelik!.sabitMi ? local.translate('general_yes') : local.translate('general_no'),
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
