import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';
import 'package:notlarim/presentation/Screen/kategori/kategori_add_edit.dart';

// Provider
import 'providers/kategori_providers.dart';

// UI
import 'kategori_card.dart';
import 'kategori_detail.dart';

class KategoriListesi extends ConsumerStatefulWidget {
  const KategoriListesi({super.key});

  @override
  ConsumerState<KategoriListesi> createState() => _KategoriListesiState();
}

class _KategoriListesiState extends ConsumerState<KategoriListesi> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle
    Future.microtask(
        () => ref.read(kategoriNotifierProvider.notifier).loadKategoriler());

    // 🔍 Arama Dinleyicisi
    _searchController.addListener(() {
      ref
          .read(kategoriNotifierProvider.notifier)
          .filterKategoriler(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    // ✅ STATE DİNLEME
    final state = ref.watch(kategoriNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern arka plan
      resizeToAvoidBottomInset: false,

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(kategoriNotifierProvider.notifier).loadKategoriler();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER
            SliverAppBar(
              backgroundColor: Colors.green.shade900,
              title: Text(
                local.translate('general_category'),
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
            ),

            // 2. ARAMA ÇUBUĞU
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildModernSearchBar(local),
              ),
            ),

            // 3. YÜKLENİYOR / BOŞ / LİSTE DURUMLARI
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            // Not: filteredKategoriler kullanıyoruz
            else if (state.filteredKategoriler.isEmpty)
              SliverFillRemaining(
                child:
                    _buildEmptyState(local, _searchController.text.isNotEmpty),
              )
            else
              // 4. GRID YAPISI
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: state.filteredKategoriler.length,
                  itemBuilder: (context, index) {
                    final kategori = state.filteredKategoriler[index];
                    return GestureDetector(
                      onTap: () async {
                        _searchFocusNode.unfocus(); // Klavyeyi kapat
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

            // Alt boşluk (FAB için)
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // ✅ FAB BUTTON
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'kategori_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          local.translate('general_add') ?? 'Ekle',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          _searchFocusNode.unfocus();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditKategori()),
          );
          ref.read(kategoriNotifierProvider.notifier).loadKategoriler();
        },
      ),
    );
  }

  // ✨ Modern Arama Çubuğu
  Widget _buildModernSearchBar(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        // Listener hallediyor, onChanged'e gerek yok ama kalabilir
        decoration: InputDecoration(
          hintText: '${loc.translate('general_search')}...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc, bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSearching ? Icons.search_off : Icons.category_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? "Sonuç Bulunamadı"
                  : loc.translate('general_notFound'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? "Farklı bir kelime ile aramayı deneyin."
                  : (loc.translate('general_anyMessage') ??
                      "Henüz bir kategori eklenmemiş."),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
