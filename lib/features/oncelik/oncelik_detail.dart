import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import '../../core/localization/localization.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/color_helper.dart';

// Domain
import 'domain/entities/oncelik.dart';

// ✅ DI Providers
import 'providers/oncelik_di_providers.dart';

// UI
import 'oncelik_add_edit.dart';

class OncelikDetail extends ConsumerStatefulWidget {
  final int oncelikId;

  const OncelikDetail({super.key, required this.oncelikId});

  @override
  ConsumerState<OncelikDetail> createState() => _OncelikDetailState();
}

class _OncelikDetailState extends ConsumerState<OncelikDetail> {
  Oncelik? oncelik;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshOncelik();
  }

  Future<void> _refreshOncelik() async {
    setState(() => isLoading = true);
    try {
      // ✅ ref.read Generic GetById
      final result =
          await ref.read(getOncelikByIdProvider).call(widget.oncelikId);
      setState(() => oncelik = result);
    } catch (e) {
      debugPrint('❌ Öncelik yüklenirken hata: $e');
      setState(() => oncelik = null);
    } finally {
      if (mounted) setState(() => isLoading = false);
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
                  // ✅ ref.read Generic Delete
                  await ref.read(deleteOncelikProvider).call(oncelik!.id!);
                  if (mounted) {
                    Navigator.of(context).pop(); // dialog
                    Navigator.of(context).pop(true); // sayfa
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (oncelik == null) {
      return Scaffold(
        appBar: AppBar(title: Text(local.translate('general_priority'))),
        body: Center(
          child: Text(local.translate('general_notFound'),
              style: const TextStyle(fontSize: 20, color: Colors.red)),
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
            color: oncelikRengi.withValues(
                alpha: 0.2), // withOpacity yerine withValues
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildLabelValue(
                  local.translate('general_title'), oncelik!.baslik),
              const SizedBox(height: 12),
              _buildLabelValue(
                  local.translate('general_explanation'), oncelik!.aciklama),
              const SizedBox(height: 12),
              _buildLabelValue(
                  local.translate('general_colorCode'), oncelik!.renkKodu),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_registrationDate'),
                AppConfig.dateFormat.format(oncelik!.kayitZamani),
              ),
              const SizedBox(height: 12),
              _buildLabelValue(
                local.translate('general_isFixed'),
                oncelik!.sabitMi
                    ? local.translate('general_yes')
                    : local.translate('general_no'),
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
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }
}
