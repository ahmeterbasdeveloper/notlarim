import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../localization/localization.dart';
import '../../../data/datasources/database_update_notifier.dart';

// Provider Importu
import 'providers/not_providers.dart';

// UI Widgets
import 'not_card.dart';
import 'not_detail.dart';
import 'not_add_edit.dart';

/// 🗒️ NOT LİSTESİ EKRANI (TAMAMEN TEMİZLENMİŞ SÜRÜM)
class NotListesi extends ConsumerStatefulWidget {
  const NotListesi({super.key});

  @override
  ConsumerState<NotListesi> createState() => _NotListesiState();
}

class _NotListesiState extends ConsumerState<NotListesi> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Veritabanı değiştiğinde listeyi yenilemek için listener
    DatabaseUpdateNotifier.instance.addListener(_onDatabaseChanged);

    // Arama dinleyicisi
    _searchController.addListener(() {
      ref
          .read(notNotifierProvider.notifier)
          .filterLocalNotes(_searchController.text);
    });
  }

  @override
  void dispose() {
    DatabaseUpdateNotifier.instance.removeListener(_onDatabaseChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDatabaseChanged() {
    // Provider üzerindeki veriyi yenile
    ref.read(notNotifierProvider.notifier).loadNotlar();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // STATE İZLEME
    final notState = ref.watch(notNotifierProvider);

    // Hata kontrolü (SnackBar ile)
    ref.listen(notNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

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
          // --- ARAMA ALANI ---
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
              onSubmitted: (query) {
                ref.read(notNotifierProvider.notifier).searchFromDb(query);
              },
            ),
          ),

          // --- LİSTE ALANI ---
          Expanded(
            child: notState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : notState.filteredNotlar.isEmpty
                    ? _buildEmptyState(loc)
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(notNotifierProvider.notifier)
                              .loadNotlar();
                        },
                        child: MasonryGridView.count(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          itemCount: notState.filteredNotlar.length,
                          itemBuilder: (context, index) {
                            final not = notState.filteredNotlar[index];
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
                                // Detaydan dönünce listeyi yenile
                                ref
                                    .read(notNotifierProvider.notifier)
                                    .loadNotlar();
                              },
                              child: NotCard(
                                not: not,
                                // 🚨 DÜZELTME: Artık parametre göndermiyoruz.
                                // NotCard kendi içinde 'sl' ile çözüyor.
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),

      // --- FAB BUTTON ---
      floatingActionButton: FloatingActionButton(
        heroTag: 'not_listesi_fab',
        backgroundColor: const Color(0xFF4E125C),
        tooltip: loc.translate('add_new_note'),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotAddEdit(
                  // 🚨 DÜZELTME: Artık parametre göndermiyoruz.
                  // NotAddEdit kendi içinde 'sl' ile çözüyor.
                  ),
            ),
          );
          // Ekleme ekranından dönünce listeyi yenile
          ref.read(notNotifierProvider.notifier).loadNotlar();
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
