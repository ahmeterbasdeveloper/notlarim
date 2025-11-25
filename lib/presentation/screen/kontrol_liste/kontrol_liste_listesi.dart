import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';

// 🌍 Core

// 🧠 Domain
import '../../../domain/entities/kontrol_liste.dart';
import '../../../domain/usecases/kontrol_liste/get_all_kontrol_liste.dart';

// 💾 Data
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/kontrol_liste_repository_impl.dart';

// 🧱 Presentation
import 'kontrol_liste_card.dart';
import 'kontrol_liste_detail.dart';
import 'kontrol_liste_add_edit.dart';

class KontrolListeListesi extends StatefulWidget {
  const KontrolListeListesi({super.key});

  @override
  State<KontrolListeListesi> createState() => _KontrolListeListesiState();
}

class _KontrolListeListesiState extends State<KontrolListeListesi> {
  late final GetAllKontrolListe _getAllKontrolListe;
  List<KontrolListe> kontrolListeList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final dbHelper = DatabaseHelper.instance;
    final repository = KontrolListeRepositoryImpl(dbHelper);
    _getAllKontrolListe = GetAllKontrolListe(repository);

    refreshKontrolListeListesi();
  }

  Future<void> refreshKontrolListeListesi() async {
    setState(() => isLoading = true);

    try {
      final list = await _getAllKontrolListe();
      setState(() => kontrolListeList = list);
    } catch (e) {
      debugPrint("Kontrol listesi yüklenemedi: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.deepPurple[50],
        appBar: AppBar(
          backgroundColor: Colors.green.shade900,
          title: Text(
            AppLocalizations.of(context).translate('general_checkList'),
            style: const TextStyle(fontSize: 24, color: Colors.amber),
          ),
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : kontrolListeList.isEmpty
                  ? _buildEmptyState(context)
                  : _buildKontrolListeGrid(),
        ),
        floatingActionButton: FloatingActionButton(
           heroTag: 'kontrol_listesi_fab', // ← benzersiz heroTag ekledik
          backgroundColor: const Color.fromARGB(255, 78, 18, 92),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const KontrolListeAddEdit()),
            );
            refreshKontrolListeListesi();
          },
        ),
      );

  /// 🧩 Boş liste durumu
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

  /// 🗂️ Kontrol listesi ızgarası
  Widget _buildKontrolListeGrid() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: List.generate(kontrolListeList.length, (index) {
              final kontrolListe = kontrolListeList[index];

              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          KontrolListeDetail(kontrolListeId: kontrolListe.id!),
                    ),
                  );
                  refreshKontrolListeListesi();
                },
                child: KontrolListeCard(kontrolListe: kontrolListe),
              );
            }),
          ),
        ),
      );
}
