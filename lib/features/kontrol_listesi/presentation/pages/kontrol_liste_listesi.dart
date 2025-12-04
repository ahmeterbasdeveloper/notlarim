import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/core/localization/localization.dart';

// Provider
import '../providers/kontrol_liste_providers.dart';

// UI
import '../widgets/kontrol_liste_card.dart';
import 'kontrol_liste_detail.dart';
import 'kontrol_liste_add_edit.dart';

class KontrolListeListesi extends ConsumerStatefulWidget {
  const KontrolListeListesi({super.key});

  @override
  ConsumerState<KontrolListeListesi> createState() =>
      _KontrolListeListesiState();
}

class _KontrolListeListesiState extends ConsumerState<KontrolListeListesi> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Arama metnini tutan değişken
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kontrolListeNotifierProvider.notifier).loadKontrolListeleri();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// 🇹🇷 Türkçe karakterleri İngilizce karakterlere çeviren yardımcı fonksiyon
  String _replaceTurkishChars(String input) {
    if (input.isEmpty) return "";
    return input
        .toLowerCase()
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('i', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    // ✅ STATE DİNLEME
    final state = ref.watch(kontrolListeNotifierProvider);

    // 🔎 GELİŞMİŞ FİLTRELEME MANTIĞI
    final filteredList = state.kontrolListeleri.where((liste) {
      if (_searchQuery.isEmpty) return true;

      final searchLower = _replaceTurkishChars(_searchQuery.trim());
      final baslikLower = _replaceTurkishChars(liste.baslik);
      final aciklamaLower = _replaceTurkishChars(liste.aciklama);

      return baslikLower.contains(searchLower) ||
          aciklamaLower.contains(searchLower);
    }).toList();

    return Scaffold(
      // Modern arka plan rengi
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,

      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(kontrolListeNotifierProvider.notifier)
              .loadKontrolListeleri();
        },
        // ✅ CustomScrollView ile Modern Yapı
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER (SliverAppBar)
            SliverAppBar(
              backgroundColor: Colors.green.shade900,
              title: Text(
                local.translate('general_checkList'),
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

            // 3. LİSTE VEYA BOŞ DURUM
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filteredList.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(local, _searchQuery.isNotEmpty),
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
                  childCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final kontrolListe = filteredList[index];
                    return GestureDetector(
                      onTap: () async {
                        _searchFocusNode.unfocus(); // Klavyeyi kapat
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
                      child: KontrolListeCard(kontrolListe: kontrolListe),
                    );
                  },
                ),
              ),

            // Alt boşluk (FAB için)
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),

      // ✅ FAB BUTTON (Modern Görünüm)
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'kontrol_listesi_fab',
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

  // ✨ Modern Arama Çubuğu
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

        // Anlık arama
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },

        decoration: InputDecoration(
          hintText: '${loc.translate('general_search')}...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = "";
                    });
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
            Icon(isSearching ? Icons.search_off : Icons.checklist_rtl,
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
                      "Henüz bir kontrol listesi eklenmemiş."),
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
