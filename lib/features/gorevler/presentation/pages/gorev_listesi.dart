import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/core/localization/localization.dart';

// Provider
import '../providers/gorev_providers.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer? _debounce;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gorevNotifierProvider.notifier).loadGorevler();
    });

    // ✅ Arama Dinleyicisi
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        final query = _searchController.text;
        if (query.isEmpty) {
          ref.read(gorevNotifierProvider.notifier).loadGorevler();
        } else {
          ref.read(gorevNotifierProvider.notifier).searchFromDb(query);
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
      ref.read(gorevNotifierProvider.notifier).loadGorevler(isLoadMore: true);
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
    final local = AppLocalizations.of(context);
    final state = ref.watch(gorevNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          await ref.read(gorevNotifierProvider.notifier).loadGorevler();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER
            SliverAppBar(
              backgroundColor: Colors.green.shade900,
              title: Text(
                '${local.translate('general_missionJob')} ${local.translate('general_list')}',
                style: const TextStyle(fontSize: 24, color: Colors.amber),
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
                child: _buildModernSearchBar(local),
              ),
            ),

            // 3. LİSTE
            if (state.isLoading && state.gorevler.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.gorevler.isEmpty && !state.isLoading)
              SliverFillRemaining(
                child:
                    _buildEmptyState(local, _searchController.text.isNotEmpty),
              )
            else
              // 4. GRID
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childCount: state.gorevler.length,
                  itemBuilder: (context, index) {
                    final gorev = state.gorevler[index];
                    return GestureDetector(
                      onTap: () async {
                        _searchFocusNode.unfocus();
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                GorevDetail(gorevId: gorev.id!),
                          ),
                        );
                        ref.read(gorevNotifierProvider.notifier).loadGorevler();
                      },
                      child: GorevCard(gorev: gorev),
                    );
                  },
                ),
              ),

            // 5. YÜKLENİYOR İKONU
            if (state.isLoading && state.gorevler.isNotEmpty)
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
        heroTag: 'gorev_listesi_fab',
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
            MaterialPageRoute(
              builder: (context) => const GorevAddEdit(),
            ),
          );
          ref.read(gorevNotifierProvider.notifier).loadGorevler();
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
            Icon(isSearching ? Icons.search_off : Icons.task_alt,
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
                  : '${loc.translate('general_anyMessage')} ${loc.translate('general_missionJob')} ${loc.translate('general_notFound')}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
