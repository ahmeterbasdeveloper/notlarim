import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';

// Provider
import 'providers/hatirlatici_providers.dart'; // ✅ Yeni provider

// UI
import 'hatirlatici_card.dart';
import 'hatirlatici_detail.dart';
import 'hatirlatici_add_edit.dart';

class HatirlaticiListesi extends ConsumerStatefulWidget {
  const HatirlaticiListesi({super.key});

  @override
  ConsumerState<HatirlaticiListesi> createState() => _HatirlaticiListesiState();
}

class _HatirlaticiListesiState extends ConsumerState<HatirlaticiListesi> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle
    // Future.microtask(() => ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(hatirlaticiNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${loc.translate('general_reminder')} ${loc.translate('general_list')}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref
                  .read(hatirlaticiNotifierProvider.notifier)
                  .loadHatirlaticilar();
            },
          )
        ],
      ),
      body: _buildBody(context, loc, state),
      backgroundColor: Colors.deepPurple[50],

      /// ➕ Yeni Hatırlatıcı Ekle
      floatingActionButton: FloatingActionButton(
        heroTag: 'hatirlatici_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HatirlaticiAddEdit(),
            ),
          );
          // Liste yenile
          ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar();
        },
      ),
    );
  }

  /// 🔹 İçerik Gövdesi
  Widget _buildBody(
      BuildContext context, AppLocalizations loc, HatirlaticiState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          '${loc.translate('general_dataLoadingError')}\n${state.errorMessage}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    if (state.hatirlaticilar.isEmpty) {
      return Center(
        child: Text(
          '${loc.translate('general_no')} ${loc.translate('general_reminder')} ${loc.translate('general_found')}',
          style: const TextStyle(fontSize: 20, color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(hatirlaticiNotifierProvider.notifier)
            .loadHatirlaticilar();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          itemCount: state.hatirlaticilar.length,
          itemBuilder: (context, index) {
            final hatirlatici = state.hatirlaticilar[index];
            return HatirlaticiCard(
              hatirlatici: hatirlatici,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HatirlaticiDetail(
                      hatirlaticiId: hatirlatici.id!,
                    ),
                  ),
                );
                // Detaydan dönünce yenile
                ref
                    .read(hatirlaticiNotifierProvider.notifier)
                    .loadHatirlaticilar();
              },
            );
          },
        ),
      ),
    );
  }
}
