import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/core/localization/localization.dart';

// Provider
import '../providers/not_providers.dart';

// UI
import '../widgets/not_card.dart';
import 'not_detail.dart';
import 'not_add_edit.dart';

class NotListesi extends ConsumerStatefulWidget {
  const NotListesi({super.key});

  @override
  ConsumerState<NotListesi> createState() => _NotListesiState();
}

class _NotListesiState extends ConsumerState<NotListesi> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ✅ 1. ScrollController Tanımlıyoruz
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer? _debounce;
    // İlk verileri yükle
    Future.microtask(() => ref.read(notNotifierProvider.notifier).loadNotlar());

    // Arama Dinleyicisi
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text;
        if (query.isEmpty) {
          ref.read(notNotifierProvider.notifier).loadNotlar();
        } else {
          ref.read(notNotifierProvider.notifier).searchFromDb(query);
        }
      });
    });

    // ✅ 2. Scroll Listener Ekliyoruz
    _scrollController.addListener(_onScroll);
  }

  // ✅ Scroll Mantığı
  void _onScroll() {
    // Klavyeyi kapat (opsiyonel UX iyileştirmesi)
    if (_searchController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
    }

    // Listenin sonuna yaklaşıldı mı? (Max scroll - 200 piksel kala)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Provider'daki loadNotlar fonksiyonunu 'Load More' modunda çağır
      final notifier = ref.read(notNotifierProvider.notifier);
      // Şu an yükleme yapmıyorsa isteği gönder
      // Not: Notifier içindeki isLoading kontrolü zaten var ama burada da yapmak güvenlidir.
      notifier.loadNotlar(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose(); // ✅ Controller'ı dispose etmeyi unutma
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    // STATE DİNLEME
    final state = ref.watch(notNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,

      body: RefreshIndicator(
        onRefresh: () async {
          // Yukarı çekince listeyi sıfırla (Refresh)
          await ref.read(notNotifierProvider.notifier).loadNotlar();
        },
        child: CustomScrollView(
          // ✅ 3. Controller'ı buraya bağlıyoruz
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER
            SliverAppBar(
              backgroundColor: Colors.green.shade900,
              title: Text(
                local.translate('menu_notes') ??
                    'Notlar', // Çeviri anahtarını düzelttim
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

            // 3. DURUMLAR (Yükleniyor / Boş / Liste)

            // Eğer ilk açılışta yükleniyorsa ve liste boşsa (Tam ekran loading)
            if (state.isLoading && state.notlar.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.filteredNotlar.isEmpty && !state.isLoading)
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
                  childCount: state.filteredNotlar.length,
                  itemBuilder: (context, index) {
                    final not = state.filteredNotlar[index];
                    return GestureDetector(
                      onTap: () async {
                        _searchFocusNode.unfocus();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NotDetail(
                              noteId: not.id!,
                            ),
                          ),
                        );
                        // Detaydan dönünce listeyi güncelle (Refresh)
                        // İsteğe bağlı: Sadece ilgili notu güncellemek daha performanslıdır
                        // ama şimdilik refresh kalsın.
                        ref.read(notNotifierProvider.notifier).loadNotlar();
                      },
                      child: NotCard(not: not),
                    );
                  },
                ),
              ),

            // ✅ 5. ALT YÜKLEME İKONU (Infinite Scroll Indicator)
            // Eğer liste doluysa ve şu an yeni veri yükleniyorsa altta spinner göster
            if (state.isLoading && state.notlar.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            // Alt boşluk (FAB için)
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // FAB BUTTON
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'not_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          local.translate('general_save') ?? 'Kaydet', // Çeviriye dikkat
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          _searchFocusNode.unfocus();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NotAddEdit()),
          );
          // Yeni not ekleyince listeyi yenile
          ref.read(notNotifierProvider.notifier).loadNotlar();
        },
      ),
    );
  }

  // ... (SearchBar ve EmptyState metodları aynen kalabilir)
  Widget _buildModernSearchBar(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
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
            Icon(isSearching ? Icons.search_off : Icons.note_alt_outlined,
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
                      "Henüz bir Not eklenmemiş."),
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
