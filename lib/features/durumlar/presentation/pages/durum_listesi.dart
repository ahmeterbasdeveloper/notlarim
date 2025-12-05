import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/features/durumlar/presentation/providers/durum_providers.dart';

// Localization
import '../../../../core/localization/localization.dart';

// UI
import '../widgets/durum_card.dart';
import 'durum_detail.dart';
import 'durum_add_edit.dart';

class DurumListesi extends ConsumerStatefulWidget {
  const DurumListesi({super.key});

  @override
  ConsumerState<DurumListesi> createState() => _DurumListesiState();
}

class _DurumListesiState extends ConsumerState<DurumListesi> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ✅ 1. ScrollController
  final ScrollController _scrollController = ScrollController();

  // ❌ _searchQuery değişkenini kaldırdık (Gerek kalmadı)

  @override
  void initState() {
    super.initState();
    Timer? _debounce;
    // İlk verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(durumNotifierProvider.notifier).loadDurumlar();
    });

    // 🔍 Arama Dinleyicisi
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text;
        if (query.isEmpty) {
          ref.read(durumNotifierProvider.notifier).loadDurumlar();
        } else {
          ref.read(durumNotifierProvider.notifier).searchFromDb(query);
        }
      });
    });

    // ✅ 2. Scroll Listener
    _scrollController.addListener(_onScroll);
  }

  // ✅ Scroll Mantığı
  void _onScroll() {
    if (_searchController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      return; // Arama yapılıyorsa pagination'ı durdurabiliriz
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(durumNotifierProvider.notifier).loadDurumlar(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ❌ _replaceTurkishChars fonksiyonunu kaldırdık (Backend'de yapılıyor veya SQL like ile çözülüyor)

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(durumNotifierProvider);

    // ❌ filteredList mantığını tamamen kaldırdık.
    // Artık doğrudan 'state.durumlar' kullanıyoruz.

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,

      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          await ref.read(durumNotifierProvider.notifier).loadDurumlar();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER
            SliverAppBar(
              backgroundColor: Colors.green.shade900,
              title: Text(
                local.translate('general_situation'),
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

            // 3. LİSTE DURUMLARI
            if (state.isLoading && state.durumlar.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            // Filtreleme sonucu boşsa
            else if (state.durumlar.isEmpty && !state.isLoading)
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
                  // Doğrudan state.durumlar kullanıyoruz
                  childCount: state.durumlar.length,
                  itemBuilder: (context, index) {
                    final durum = state.durumlar[index];
                    return GestureDetector(
                      onTap: () async {
                        _searchFocusNode.unfocus();
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DurumDetail(durumId: durum.id!),
                          ),
                        );
                        ref.read(durumNotifierProvider.notifier).loadDurumlar();
                      },
                      child: DurumCard(durum: durum),
                    );
                  },
                ),
              ),

            // 5. YÜKLENİYOR İKONU
            if (state.isLoading && state.durumlar.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // FAB BUTTON
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'durum_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          local.translate('general_add') ?? 'Ekle',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          _searchFocusNode.unfocus();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDurum()),
          );
          ref.read(durumNotifierProvider.notifier).loadDurumlar();
        },
      ),
    );
  }

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
        // ❌ onChanged kaldırıldı, listener hallediyor
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
            Icon(isSearching ? Icons.search_off : Icons.list_alt,
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
                      "Henüz bir durum eklenmemiş."),
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
