import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:notlarim/core/localization/localization.dart';
import '../../../../core/config/app_config.dart';

// Domain
import '../../domain/entities/kontrol_liste.dart';

// ✅ DI Providers
import '../providers/kontrol_liste_di_providers.dart';

// UI
import 'kontrol_liste_add_edit.dart';

class KontrolListeDetail extends ConsumerStatefulWidget {
  final int kontrolListeId;
  const KontrolListeDetail({super.key, required this.kontrolListeId});

  @override
  ConsumerState<KontrolListeDetail> createState() => _KontrolListeDetailState();
}

class _KontrolListeDetailState extends ConsumerState<KontrolListeDetail> {
  KontrolListe? kontrolListe;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshKontrolListe();
  }

  Future<void> _refreshKontrolListe() async {
    setState(() => isLoading = true);
    try {
      // ✅ ref.read Generic GetById
      final data = await ref
          .read(getKontrolListeByIdProvider)
          .call(widget.kontrolListeId);
      setState(() => kontrolListe = data);
    } catch (e) {
      debugPrint("Hata: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteKontrolListe() async {
    // ✅ ref.read Generic Delete
    await ref
        .read(deleteKontrolListeGenericProvider)
        .call(widget.kontrolListeId);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_checkList')} ${local.translate('general_detail')}',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        actions: [
          if (!isLoading && kontrolListe != null) ...[
            _editButton(),
            _deleteButton(local),
          ]
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kontrolListe == null
              ? Center(
                  child: Text(local.translate('general_noDataFound'),
                      style: const TextStyle(fontSize: 18)))
              : _buildDetailBody(local),
    );
  }

  Widget _buildDetailBody(AppLocalizations local) {
    final k = kontrolListe!;
    final dateText = AppConfig.dateFormat.format(k.kayitZamani);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildLabel(local.translate('general_title')),
          _buildValue(k.baslik, isBold: true),
          const SizedBox(height: 12),
          _buildLabel(local.translate('general_explanation')),
          _buildValue(k.aciklama),
          const SizedBox(height: 12),
          _buildLabel(local.translate('general_registrationDate')),
          _buildValue(dateText),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red));
  Widget _buildValue(String text, {bool isBold = false}) => Text(text,
      style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal));

  Widget _editButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        onPressed: () async {
          if (isLoading || kontrolListe == null) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    KontrolListeAddEdit(kontrolListe: kontrolListe!)),
          );
          _refreshKontrolListe();
        },
      );

  Widget _deleteButton(AppLocalizations local) => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(local.translate('general_deleteConfirmation')),
              content: Text(local.translate('general_deleteQuestion')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(local.translate('general_no'))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(local.translate('general_yes'))),
              ],
            ),
          );
          if (confirm == true) {
            await _deleteKontrolListe();
            if (mounted) Navigator.of(context).pop();
          }
        },
      );
}
