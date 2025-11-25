import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';
import 'package:notlarim/presentation/Screen/kategori/kategori_add_edit.dart';

// Domain
import '../../../../domain/entities/kategori.dart';
import '../../../../domain/usecases/kategori/get_all_kategori.dart';

// Data
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

// UI
import 'kategori_card.dart';
import 'kategori_detail.dart';

/// 🧱 Kategori Listesi Ekranı — Clean Architecture versiyonu.
/// UseCase tabanlı, entity yapısı ile çalışır.
class KategoriListesi extends StatefulWidget {
  const KategoriListesi({super.key});

  @override
  State<KategoriListesi> createState() => _KategoriListesiState();
}

class _KategoriListesiState extends State<KategoriListesi> {
  late final GetAllKategori _getAllKategoriUseCase;

  List<Kategori> kategoriList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final repository = KategoriRepositoryImpl(DatabaseHelper.instance);
    _getAllKategoriUseCase = GetAllKategori(repository);
    _refreshKategoriler();
  }

  Future<void> _refreshKategoriler() async {
    setState(() => isLoading = true);
    try {
      final result = await _getAllKategoriUseCase();
      setState(() => kategoriList = result);
    } catch (e) {
      debugPrint('❌ Kategori yüklenirken hata: $e');
      setState(() => kategoriList = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_category')}  ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : kategoriList.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} ${local.translate('general_category')} ${local.translate('general_notFound')}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  )
                : _buildKategoriler(),
      ),
      backgroundColor: Colors.deepPurple[50],
      floatingActionButton: FloatingActionButton(
         heroTag: 'kategori_listesi_fab', // ← benzersiz heroTag ekledik
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditKategori()),
          );
          _refreshKategoriler();
        },
        tooltip: local.translate('general_addCategory'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildKategoriler() => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(
            kategoriList.length,
            (index) {
              final kategori = kategoriList[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => KategoriDetail(
                        kategoriId: kategori.id!,
                      ),
                    ),
                  );
                  _refreshKategoriler();
                },
                child: KategoriCard(kategori: kategori),
              );
            },
          ),
        ),
      );
}
