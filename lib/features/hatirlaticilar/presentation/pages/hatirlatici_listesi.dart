import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/core/localization/localization.dart';

// Provider
import '../providers/hatirlatici_providers.dart';

// UI
import '../widgets/hatirlatici_card.dart';
import 'hatirlatici_detail.dart';
import 'hatirlatici_add_edit.dart';

class HatirlaticiListesi extends ConsumerStatefulWidget {
  const HatirlaticiListesi({super.key});

  @override
  ConsumerState<HatirlaticiListesi> createState() => _HatirlaticiListesiState();
}

class _HatirlaticiListesiState extends ConsumerState<HatirlaticiListesi> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer? _debounce;
    // İlk verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar();
    });

    // ✅ Arama Dinleyicisi
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text;
        if (query.isEmpty) {
          ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar();
        } else {
          ref.read(hatirlaticiNotifierProvider.notifier).searchFromDb(query);
        }
      });
    });

    // ✅ Scroll Listener
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_searchController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      return;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(hatirlaticiNotifierProvider.notifier)
          .loadHatirlaticilar(isLoadMore: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(hatirlaticiNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          await ref
              .read(hatirlaticiNotifierProvider.notifier)
              .loadHatirlaticilar();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER
            SliverAppBar(
              backgroundColor: Colors.green.shade900,
              title: Text(
                '${loc.translate('general_reminder')} ${loc.translate('general_list')}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              centerTitle: true,
              floating: true,
              pinned: true,
              snap: true,
              elevation: 0,
            ),

            // 2. ARAMA ÇUBUĞU (YENİ)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildModernSearchBar(loc),
              ),
            ),

            // 3. LİSTE DURUMLARI
            if (state.isLoading && state.hatirlaticilar.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.hatirlaticilar.isEmpty && !state.isLoading)
              SliverFillRemaining(
                child: _buildEmptyState(loc, _searchController.text.isNotEmpty),
              )
            else
              // 4. GRID YAPISI
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: state.hatirlaticilar.length,
                  itemBuilder: (context, index) {
                    final hatirlatici = state.hatirlaticilar[index];
                    return HatirlaticiCard(
                      hatirlatici: hatirlatici,
                      onTap: () async {
                        _searchFocusNode.unfocus();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HatirlaticiDetail(
                              hatirlaticiId: hatirlatici.id!,
                            ),
                          ),
                        );
                        ref
                            .read(hatirlaticiNotifierProvider.notifier)
                            .loadHatirlaticilar();
                      },
                    );
                  },
                ),
              ),

            // 5. YÜKLENİYOR İKONU
            if (state.isLoading && state.hatirlaticilar.isNotEmpty)
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'hatirlatici_listesi_fab',
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          loc.translate('general_add') ?? 'Ekle',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          _searchFocusNode.unfocus();
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HatirlaticiAddEdit(),
            ),
          );
          ref.read(hatirlaticiNotifierProvider.notifier).loadHatirlaticilar();
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
            Icon(isSearching ? Icons.search_off : Icons.alarm_off,
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
                  : "${loc.translate('general_no')} ${loc.translate('general_reminder')} ${loc.translate('general_found')}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
