import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';
import '../../../core/config/app_config.dart';

// 🧠 Domain & UseCases
import '../../../domain/entities/kontrol_liste.dart';
import '../../../domain/usecases/kontrol_liste/get_kontrol_liste_by_id.dart';
import '../../../domain/usecases/kontrol_liste/delete_kontrol_liste.dart';

// 💾 Data katmanı
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/kontrol_liste_repository_impl.dart';

// 📱 Presentation
import 'kontrol_liste_add_edit.dart';

class KontrolListeDetail extends StatefulWidget {
  final int kontrolListeId;

  const KontrolListeDetail({
    super.key,
    required this.kontrolListeId,
  });

  @override
  State<KontrolListeDetail> createState() => _KontrolListeDetailState();
}

class _KontrolListeDetailState extends State<KontrolListeDetail> {
  late final _repository =
      KontrolListeRepositoryImpl(DatabaseHelper.instance);
  late final _getKontrolListeById = GetKontrolListeById(_repository);
  late final _deleteKontrolListe = DeleteKontrolListe(_repository);

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
      final data = await _getKontrolListeById(widget.kontrolListeId);
      setState(() => kontrolListe = data);
    } catch (e) {
      debugPrint("Kontrol listesi yüklenirken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri yüklenemedi: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          '${AppLocalizations.of(context).translate('general_checkList')} '
          '${AppLocalizations.of(context).translate('general_detail')}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        actions: [
          if (!isLoading && kontrolListe != null) ...[
            _editButton(),
            _deleteButton(),
          ]
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : kontrolListe == null
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('general_noDataFound'),
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : _buildDetailBody(),
    );
  }

  Widget _buildDetailBody() {
    final k = kontrolListe!;
    final dateText = AppConfig.dateFormat.format(k.kayitZamani);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildLabel(
              AppLocalizations.of(context).translate('general_title')),
          _buildValue(k.baslik, isBold: true),
          const SizedBox(height: 12),

          _buildLabel(
              AppLocalizations.of(context).translate('general_explanation')),
          _buildValue(k.aciklama),
          const SizedBox(height: 12),

          _buildLabel(AppLocalizations.of(context)
              .translate('general_registrationDate')),
          _buildValue(dateText),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      );

  Widget _buildValue(String text, {bool isBold = false}) => Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      );

  Widget _editButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        onPressed: () async {
          if (isLoading || kontrolListe == null) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  KontrolListeAddEdit(kontrolListe: kontrolListe!),
            ),
          );

          _refreshKontrolListe();
        },
      );

  Widget _deleteButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.delete),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)
                  .translate('general_deleteConfirmation')),
              content: Text(AppLocalizations.of(context)
                  .translate('general_deleteQuestion')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child:
                      Text(AppLocalizations.of(context).translate('general_no')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                      AppLocalizations.of(context).translate('general_yes')),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await _deleteKontrolListe(widget.kontrolListeId);
            if (mounted) Navigator.of(context).pop();
          }
        },
      );
}
