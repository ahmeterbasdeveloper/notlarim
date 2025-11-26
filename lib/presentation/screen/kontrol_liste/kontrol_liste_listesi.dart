import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';

// Provider
import 'providers/kontrol_liste_providers.dart'; // ✅ Yeni provider

// UI
import 'kontrol_liste_card.dart';
import 'kontrol_liste_detail.dart';
import 'kontrol_liste_add_edit.dart';

class KontrolListeListesi extends ConsumerStatefulWidget {
  const KontrolListeListesi({super.key});

  @override
  ConsumerState<KontrolListeListesi> createState() =>
      _KontrolListeListesiState();
}

class _KontrolListeListesiState extends ConsumerState<KontrolListeListesi> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle
    // Future.microtask(() => ref.read(kontrolListeNotifierProvider.notifier).loadKontrolListeleri());
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(kontrolListeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          local.translate('general_checkList'),
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : state.kontrolListeleri.isEmpty
                ? _buildEmptyState(context)
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(kontrolListeNotifierProvider.notifier)
                          .loadKontrolListeleri();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          children: List.generate(state.kontrolListeleri.length,
                              (index) {
                            final kontrolListe = state.kontrolListeleri[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => KontrolListeDetail(
                                        kontrolListeId: kontrolListe.id!),
                                  ),
                                );
                                // Detaydan dönünce listeyi güncelle
                                ref
                                    .read(kontrolListeNotifierProvider.notifier)
                                    .loadKontrolListeleri();
                              },
                              child:
                                  KontrolListeCard(kontrolListe: kontrolListe),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'kontrol_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const KontrolListeAddEdit()),
          );
          // Ekleme sonrası listeyi güncelle
          ref
              .read(kontrolListeNotifierProvider.notifier)
              .loadKontrolListeleri();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${AppLocalizations.of(context).translate('general_anyMessage')} '
          '${AppLocalizations.of(context).translate('general_checkList')} '
          '${AppLocalizations.of(context).translate('general_notFound')}.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
