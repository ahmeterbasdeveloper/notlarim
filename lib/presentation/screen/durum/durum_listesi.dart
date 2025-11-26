import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Localization
import '../../../../localization/localization.dart';

// Provider
import 'providers/durum_providers.dart'; // ✅ Yeni provider

// UI
import 'durum_add_edit.dart';
import 'durum_card.dart';
import 'durum_detail.dart';

class DurumListesi extends ConsumerStatefulWidget {
  const DurumListesi({super.key});

  @override
  ConsumerState<DurumListesi> createState() => _DurumListesiState();
}

class _DurumListesiState extends ConsumerState<DurumListesi> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle
    // (Provider init bloğunda zaten çağırılıyor ama manuel refresh için burası kalabilir)
    // Future.microtask(() => ref.read(durumNotifierProvider.notifier).loadDurumlar());
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(durumNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_situation')} ${local.translate('general_list')}',
          style: const TextStyle(
              fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.deepPurple[50],

      // ✅ FAB: Yeni Ekleme
      floatingActionButton: FloatingActionButton(
        heroTag: 'durum_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        tooltip: local.translate('general_addNewSituation'),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDurum()),
          );
          // Geri dönünce listeyi yenile
          ref.read(durumNotifierProvider.notifier).loadDurumlar();
        },
      ),

      // ✅ GÖVDE
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.durumlar.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} '
                    '${local.translate('general_situation')} '
                    '${local.translate('general_notFound')}',
                    style: const TextStyle(color: Colors.red, fontSize: 20),
                    textAlign: TextAlign.center,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(durumNotifierProvider.notifier)
                          .loadDurumlar();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          children: state.durumlar.map((durum) {
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DurumDetail(durumId: durum.id!),
                                  ),
                                );
                                // Detaydan dönünce listeyi güncelle
                                ref
                                    .read(durumNotifierProvider.notifier)
                                    .loadDurumlar();
                              },
                              child: DurumCard(durum: durum),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
