import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';
import 'package:notlarim/presentation/Screen/kategori/kategori_add_edit.dart';

// Provider
import 'providers/kategori_providers.dart'; // ✅ Yeni provider

// UI
import 'kategori_card.dart';
import 'kategori_detail.dart';

class KategoriListesi extends ConsumerStatefulWidget {
  const KategoriListesi({super.key});

  @override
  ConsumerState<KategoriListesi> createState() => _KategoriListesiState();
}

class _KategoriListesiState extends ConsumerState<KategoriListesi> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle (gerekirse)
    // ref.read(kategoriNotifierProvider.notifier).loadKategoriler();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(kategoriNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_category')}  ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.kategoriler.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} ${local.translate('general_category')} ${local.translate('general_notFound')}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(kategoriNotifierProvider.notifier)
                          .loadKategoriler();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: List.generate(
                          state.kategoriler.length,
                          (index) {
                            final kategori = state.kategoriler[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => KategoriDetail(
                                      kategoriId: kategori.id!,
                                    ),
                                  ),
                                );
                                // Detaydan dönünce listeyi güncelle
                                ref
                                    .read(kategoriNotifierProvider.notifier)
                                    .loadKategoriler();
                              },
                              child: KategoriCard(kategori: kategori),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
      ),
      backgroundColor: Colors.deepPurple[50],

      // ✅ FAB
      floatingActionButton: FloatingActionButton(
        heroTag: 'kategori_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditKategori()),
          );
          // Ekleme sonrası listeyi güncelle
          ref.read(kategoriNotifierProvider.notifier).loadKategoriler();
        },
        tooltip: local.translate('general_addCategory'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
