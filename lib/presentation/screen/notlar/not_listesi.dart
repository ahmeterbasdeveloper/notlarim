import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../localization/localization.dart';
import '../../../data/datasources/database_update_notifier.dart';
import '../../../domain/entities/not.dart';
import '../../../domain/usecases/not/get_all_not.dart';
import '../../../domain/usecases/not/search_not.dart';
import '../../../domain/usecases/not/create_not.dart';
import '../../../domain/usecases/not/update_not.dart';
import '../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../domain/usecases/oncelik/get_all_oncelik.dart';
import '../../../domain/usecases/kategori/get_kategori_by_id.dart';
import '../../../domain/usecases/oncelik/get_oncelik_by_id.dart';
import '../../../data/repositories/not_repository_impl.dart';
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';
import 'not_card.dart';
import 'not_detail.dart';
import 'not_add_edit.dart';

/// 🗒️ NOT LİSTESİ EKRANI (GÜNCEL SÜRÜM)
/// - Artık `GetAllNot` dışarıdan beklenmiyor.
/// - Repository ve UseCase'ler içeride oluşturuluyor.
class NotListesi extends StatefulWidget {
  const NotListesi({super.key});

  @override
  State<NotListesi> createState() => _NotListesiState();
}

class _NotListesiState extends State<NotListesi> {
  final TextEditingController _searchController = TextEditingController();

  List<Not> _notlar = [];
  List<Not> _filtered = [];
  bool _isLoading = false;

  // UseCases
  late final GetAllNot _getAllNotUseCase;
  late final SearchNot _searchNotUseCase;
  late final CreateNot _createNotUseCase;
  late final UpdateNot _updateNotUseCase;
  late final GetAllKategori _getAllKategoriUseCase;
  late final GetAllOncelik _getAllOncelikUseCase;
  late final GetKategoriById _getKategoriById;
  late final GetOncelikById _getOncelikById;

  @override
  void initState() {
    super.initState();
    _setupUseCases();
    _loadNotlar();

    DatabaseUpdateNotifier.instance.addListener(_onDatabaseChanged);
    _searchController.addListener(_filterLocalNotes);
  }

  @override
  void dispose() {
    DatabaseUpdateNotifier.instance.removeListener(_onDatabaseChanged);
    _searchController.removeListener(_filterLocalNotes);
    _searchController.dispose();
    super.dispose();
  }

  void _setupUseCases() {
    final db = DatabaseHelper.instance;
    final kategoriRepo = KategoriRepositoryImpl(db);
    final oncelikRepo = OncelikRepositoryImpl(db);
    final notRepo = NotRepositoryImpl(
      db,
      kategoriRepository: kategoriRepo,
      oncelikRepository: oncelikRepo,
    );

    _getAllNotUseCase = GetAllNot(notRepo);
    _searchNotUseCase = SearchNot(notRepo);
    _createNotUseCase = CreateNot(notRepo);
    _updateNotUseCase = UpdateNot(notRepo);
    _getAllKategoriUseCase = GetAllKategori(kategoriRepo);
    _getAllOncelikUseCase = GetAllOncelik(oncelikRepo);
    _getKategoriById = GetKategoriById(kategoriRepo);
    _getOncelikById = GetOncelikById(oncelikRepo);
  }

  void _onDatabaseChanged() {
    debugPrint('📢 NotListesi: Database değişti, liste yenileniyor...');
    _loadNotlar();
  }

  Future<void> _loadNotlar() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final result = await _getAllNotUseCase.call();
      if (!mounted) return;

      setState(() {
        _notlar = result;
        _filtered = result;
      });

      debugPrint('✅ ${result.length} not yüklendi.');
    } catch (e) {
      debugPrint('⚠️ Notlar yüklenemedi: $e');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterLocalNotes() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filtered = _notlar);
      return;
    }

    setState(() {
      _filtered = _notlar.where((not) {
        final baslik = not.baslik.toLowerCase();
        final aciklama = not.aciklama.toLowerCase();
        return baslik.contains(query) || aciklama.contains(query);
      }).toList();
    });
  }

  Future<void> _searchFromDb(String query) async {
    if (query.isEmpty) {
      setState(() => _filtered = _notlar);
      return;
    }

    try {
      final result = await _searchNotUseCase(query);
      if (!mounted) return;
      setState(() => _filtered = result);
    } catch (e) {
      debugPrint('🔎 Arama başarısız: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
        title: Text(
          '${loc.translate('general_note')} ${loc.translate('general_list')}',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '${loc.translate('general_search')}...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _searchFromDb,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _buildEmptyState(loc)
                    : RefreshIndicator(
                        onRefresh: _loadNotlar,
                        child: MasonryGridView.count(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final not = _filtered[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NotDetail(
                                      key: UniqueKey(),
                                      noteId: not.id!,
                                    ),
                                  ),
                                );
                                _loadNotlar();
                              },
                              child: NotCard(
                                not: not,
                                getKategoriById: _getKategoriById,
                                getOncelikById: _getOncelikById,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
         heroTag: 'not_listesi_fab', // ← benzersiz heroTag ekledik
        backgroundColor: const Color(0xFF4E125C),
        tooltip: loc.translate('add_new_note'),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotAddEdit(
                createNotUseCase: _createNotUseCase,
                updateNotUseCase: _updateNotUseCase,
                getAllKategoriUseCase: _getAllKategoriUseCase,
                getAllOncelikUseCase: _getAllOncelikUseCase,
              ),
            ),
          );
          _loadNotlar();
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          '${loc.translate('general_anyMessage')} '
          '${loc.translate('general_note')} '
          '${loc.translate('general_notFound')}',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.redAccent,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
