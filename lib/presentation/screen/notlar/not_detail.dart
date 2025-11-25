import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/color_helper.dart';
import '../../../../localization/localization.dart';

// 🧠 Domain
import '../../../domain/entities/not.dart';
import '../../../domain/usecases/not/get_not_by_id.dart';
import '../../../domain/usecases/oncelik/get_oncelik_by_id.dart';
import '../../../domain/usecases/not/delete_not.dart';
import '../../../domain/usecases/not/create_not.dart';
import '../../../domain/usecases/not/update_not.dart';
import '../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';

// 💾 Data
import '../../../data/repositories/not_repository_impl.dart';
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

// 📄 UI
import 'not_add_edit.dart';

/// 🧾 Not Detay Ekranı — Clean Architecture uyumlu versiyon.
class NotDetail extends StatefulWidget {
  final int noteId;

  const NotDetail({super.key, required this.noteId});

  @override
  State<NotDetail> createState() => _NotDetailState();
}

class _NotDetailState extends State<NotDetail> {
  bool isLoading = false;
  Not? not;
  Color selectedColor = Colors.greenAccent;

  // ✅ UseCase'ler
  late final GetNotById _getNotByIdUseCase;
  late final GetOncelikById _getOncelikByIdUseCase;
  late final DeleteNot _deleteNotUseCase;
  late final CreateNot _createNotUseCase;
  late final UpdateNot _updateNotUseCase;
  late final GetAllKategori _getAllKategoriUseCase;
  late final GetAllOncelik _getAllOncelikUseCase;

  @override
  void initState() {
    super.initState();

    // 💾 Repository ve UseCase bağlantıları
    final db = DatabaseHelper.instance;
    final kategoriRepo = KategoriRepositoryImpl(db);
    final oncelikRepo = OncelikRepositoryImpl(db);
    final notRepo = NotRepositoryImpl(
      db,
      kategoriRepository: kategoriRepo,
      oncelikRepository: oncelikRepo,
    );

    _getNotByIdUseCase = GetNotById(notRepo);
    _getOncelikByIdUseCase = GetOncelikById(oncelikRepo);
    _deleteNotUseCase = DeleteNot(notRepo);
    _createNotUseCase = CreateNot(notRepo);
    _updateNotUseCase = UpdateNot(notRepo);
    _getAllKategoriUseCase = GetAllKategori(kategoriRepo);
    _getAllOncelikUseCase = GetAllOncelik(oncelikRepo);

    _loadNote();
  }

  /// 🧩 Not detayını ve renk kodunu yükler
  Future<void> _loadNote() async {
    setState(() => isLoading = true);
    try {
      final fetchedNote = await _getNotByIdUseCase(widget.noteId);
      if (fetchedNote == null) throw Exception('Note not found');

      final oncelik =
          await _getOncelikByIdUseCase(fetchedNote.oncelikId);
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
      await _deleteNotUseCase(widget.noteId);
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
              builder: (_) => NotAddEdit(
                not: not!,
                createNotUseCase: _createNotUseCase,
                updateNotUseCase: _updateNotUseCase,
                getAllKategoriUseCase: _getAllKategoriUseCase,
                getAllOncelikUseCase: _getAllOncelikUseCase,
              ),
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
