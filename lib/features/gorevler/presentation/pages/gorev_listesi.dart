import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/core/localization/localization.dart';

// Provider
import '../providers/gorev_providers.dart'; // ✅ Oluşturduğumuz provider

// UI
import '../widgets/gorev_card.dart';
import 'gorev_detail.dart';
import 'gorev_add_edit.dart';

class GorevListesi extends ConsumerStatefulWidget {
  const GorevListesi({super.key});

  @override
  ConsumerState<GorevListesi> createState() => _GorevListesiState();
}

class _GorevListesiState extends ConsumerState<GorevListesi> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle (zaten provider init'te yapıyor ama
    // geri dönüşlerde tetiklemek için refresh mantığı eklenebilir)
    // ref.read(gorevNotifierProvider.notifier).loadGorevler();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE'i dinliyoruz
    final state = ref.watch(gorevNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_missionJob')} ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      backgroundColor: Colors.deepPurple[50],

      // ✅ FAB: Yeni Ekleme
      floatingActionButton: FloatingActionButton(
        heroTag: 'gorev_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              // Parametre göndermiyoruz, AddEdit sayfası kendi DI'ını kullanıyor
              builder: (context) => const GorevAddEdit(),
            ),
          );
          // Geri dönünce listeyi güncelle
          ref.read(gorevNotifierProvider.notifier).loadGorevler();
        },
      ),

      // ✅ GÖVDE: State durumuna göre
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.gorevler.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} ${local.translate('general_missionJob')} ${local.translate('general_notFound')}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(gorevNotifierProvider.notifier)
                          .loadGorevler();
                    },
                    child: SingleChildScrollView(
                      child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        children: List.generate(
                          state.gorevler.length,
                          (index) {
                            final gorev = state.gorevler[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GorevDetail(gorevId: gorev.id!),
                                  ),
                                );
                                // Detaydan dönünce listeyi güncelle
                                ref
                                    .read(gorevNotifierProvider.notifier)
                                    .loadGorevler();
                              },
                              child: GorevCard(gorev: gorev),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
