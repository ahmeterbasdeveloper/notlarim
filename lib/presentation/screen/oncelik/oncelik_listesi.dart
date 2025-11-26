import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';

// Provider
import 'providers/oncelik_providers.dart'; // ✅ Yeni provider

// UI
import 'oncelik_card.dart';
import 'oncelik_detail.dart';
import 'oncelik_add_edit.dart';

class OncelikListesi extends ConsumerStatefulWidget {
  const OncelikListesi({super.key});

  @override
  ConsumerState<OncelikListesi> createState() => _OncelikListesiState();
}

class _OncelikListesiState extends ConsumerState<OncelikListesi> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle
    // ref.read(oncelikNotifierProvider.notifier).loadOncelikler();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(oncelikNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_priority')}  ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.oncelikler.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} ${local.translate('general_priority')} ${local.translate('general_notFound')}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(oncelikNotifierProvider.notifier)
                          .loadOncelikler();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: List.generate(
                          state.oncelikler.length,
                          (index) {
                            final oncelik = state.oncelikler[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OncelikDetail(oncelikId: oncelik.id!),
                                  ),
                                );
                                // Detaydan dönünce listeyi güncelle
                                ref
                                    .read(oncelikNotifierProvider.notifier)
                                    .loadOncelikler();
                              },
                              child: OncelikCard(oncelik: oncelik),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
      ),
      backgroundColor: Colors.deepPurple[50],
      floatingActionButton: FloatingActionButton(
        heroTag: 'oncelik_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditOncelik()),
          );
          // Ekleme sonrası listeyi güncelle
          ref.read(oncelikNotifierProvider.notifier).loadOncelikler();
        },
        tooltip: local.translate('general_addPriority'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
