import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ 1. Riverpod Eklendi
import 'package:notlarim/features/oncelik/providers/oncelik_di_providers.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/color_helper.dart';
import '../../../../core/localization/localization.dart';

// 🧠 Domain Entities
import '../../domain/entities/not.dart';

// 🔌 DI Providers (Generic UseCase'lere erişim için)
import '../providers/not_di_providers.dart'; // ✅ 2. Provider Dosyası

// 📄 UI
import 'not_add_edit.dart';

// ✅ 3. ConsumerStatefulWidget yapıldı
class NotDetail extends ConsumerStatefulWidget {
  final int noteId;

  const NotDetail({super.key, required this.noteId});

  @override
  ConsumerState<NotDetail> createState() => _NotDetailState();
}

class _NotDetailState extends ConsumerState<NotDetail> {
  bool isLoading = false;
  Not? not;
  Color selectedColor = Colors.greenAccent;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  /// 🧩 Not detayını ve renk kodunu yükler
  Future<void> _loadNote() async {
    setState(() => isLoading = true);
    try {
      // ✅ 4. UseCase'i Riverpod üzerinden okuyoruz
      // ref.read kullanarak provider'daki UseCase'i çağırıyoruz
      final fetchedNote =
          await ref.read(getNotByIdProvider).call(widget.noteId);

      if (fetchedNote == null) throw Exception('Note not found');

      // Öncelik bilgisini (rengi) çekiyoruz
      final oncelik =
          await ref.read(getOncelikByIdProvider).call(fetchedNote.oncelikId);
      final renk = ColorHelper.hexToColor(oncelik?.renkKodu ?? '#A5D6A7');

      if (mounted) {
        setState(() {
          not = fetchedNote;
          selectedColor = renk;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                  .translate('general_errorOccurredWhileLoading'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// ❌ Not silme onayı
  Future<void> _confirmDelete() async {
    final loc = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('general_deleteConfirmationTitle')),
        content: Text(loc.translate('general_deleteConfirmationMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.translate('general_Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.translate('general_Confirm')),
          ),
        ],
      ),
    );

    if (result == true) {
      // ✅ 5. Silme işlemi için Riverpod Provider'ı kullanılıyor
      await ref.read(deleteNotProvider).call(widget.noteId);

      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: selectedColor,
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${loc.translate('general_note')} ${loc.translate('general_detail')}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [editButton(), deleteButton()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : not == null
              ? Center(
                  child: Text(
                    loc.translate('general_noDataFound'),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : _buildDetailBody(loc),
    );
  }

  Widget _buildDetailBody(AppLocalizations loc) {
    final current = not!;
    final formattedDate = AppConfig.dateFormat.format(current.kayitZamani);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(loc.translate('general_title'), current.baslik),
        _buildSection(loc.translate('general_explanation'), current.aciklama),
        _buildSection(
          loc.translate('general_registrationDate'),
          formattedDate,
        ),
      ],
    );
  }

  Widget _buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// ✏️ Düzenleme butonu
  Widget editButton() => IconButton(
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        onPressed: () async {
          if (isLoading || not == null) return;
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotAddEdit(not: not!),
            ),
          ).then((_) => _loadNote());
        },
      );

  /// 🗑️ Silme butonu
  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete, color: Colors.white),
        onPressed: _confirmDelete,
      );
}
