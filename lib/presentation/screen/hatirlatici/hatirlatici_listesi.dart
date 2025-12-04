import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';

// Provider
import 'providers/hatirlatici_providers.dart';

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
    // ✅ DÜZELTME 1: initState içinde Provider çağırmak için güvenli yöntem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    // State Dinleme
    final state = ref.watch(hatirlaticiNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Tutarlı arka plan rengi
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
            tooltip: loc.translate('general_refresh'),
            onPressed: () {
              ref
                  .read(hatirlaticiNotifierProvider.notifier)
                  .loadHatirlaticilar();
            },
          )
        ],
      ),

      // Gövde Oluşturucu
      body: _buildBody(context, loc, state),

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'hatirlatici_listesi_fab', // ✅ Benzersiz Tag
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          loc.translate('general_add') ?? 'Ekle',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HatirlaticiAddEdit(),
            ),
          );
          // Ekleme işleminden dönünce listeyi yenile
          ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar();
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, AppLocalizations loc, HatirlaticiState state) {
    // 1. Yükleniyor Durumu
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Hata Durumu
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                '${loc.translate('general_dataLoadingError')}\n${state.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => ref
                    .read(hatirlaticiNotifierProvider.notifier)
                    .loadHatirlaticilar(),
                child: Text(loc.translate('general_refresh') ?? "Yenile"),
              )
            ],
          ),
        ),
      );
    }

    // 3. Boş Liste Durumu
    if (state.hatirlaticilar.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '${loc.translate('general_no')} ${loc.translate('general_reminder')} ${loc.translate('general_found')}',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 4. Dolu Liste Durumu (Scroll Sorunu Giderilmiş)
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(hatirlaticiNotifierProvider.notifier)
            .loadHatirlaticilar();
      },
      // ✅ DÜZELTME 2: SingleChildScrollView kaldırıldı.
      // MasonryGridView zaten kendi scroll yapısına sahiptir.
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
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
    );
  }
}
