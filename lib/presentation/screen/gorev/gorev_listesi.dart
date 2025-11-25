import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/domain/entities/gorev.dart';
import 'package:notlarim/domain/usecases/gorev/get_all_gorev.dart';
import 'package:notlarim/localization/localization.dart';

// UseCases
import '../../../../domain/usecases/gorev/create_gorev.dart';
import '../../../../domain/usecases/gorev/update_gorev.dart';
import '../../../../domain/usecases/kategori/get_all_kategori.dart';
import '../../../../domain/usecases/oncelik/get_all_oncelik.dart';

// Repositories
import '../../../data/datasources/database_helper.dart';
import '../../../data/repositories/gorev_repository_impl.dart';
import '../../../data/repositories/kategori_repository_impl.dart';
import '../../../data/repositories/oncelik_repository_impl.dart';

// UI
import 'gorev_card.dart';
import 'gorev_detail.dart';
import 'gorev_add_edit.dart';

class GorevListesi extends StatefulWidget {
  final GetAllGorev getAllGorevUseCase;

  const GorevListesi({super.key, required this.getAllGorevUseCase});

  @override
  State<GorevListesi> createState() => _GorevListesiState();
}

class _GorevListesiState extends State<GorevListesi> {
  List<Gorev> gorevList = [];
  bool isLoading = false;

  // UseCases
  late final CreateGorev _createGorevUseCase;
  late final UpdateGorev _updateGorevUseCase;
  late final GetAllKategori _getAllKategoriUseCase;
  late final GetAllOncelik _getAllOncelikUseCase;

  @override
  void initState() {
    super.initState();
    _setupUseCases();
    refreshGorevler();
  }

  void _setupUseCases() {
    final gorevRepo = GorevRepositoryImpl(DatabaseHelper.instance);
    final kategoriRepo = KategoriRepositoryImpl(DatabaseHelper.instance);
    final oncelikRepo = OncelikRepositoryImpl(DatabaseHelper.instance);

    _createGorevUseCase = CreateGorev(gorevRepo);
    _updateGorevUseCase = UpdateGorev(gorevRepo);
    _getAllKategoriUseCase = GetAllKategori(kategoriRepo);
    _getAllOncelikUseCase = GetAllOncelik(oncelikRepo);
  }

  Future<void> refreshGorevler() async {
    setState(() => isLoading = true);
    try {
      gorevList = await widget.getAllGorevUseCase();
    } catch (e) {
      if (kDebugMode) print('Görevler yüklenirken hata: $e');
      gorevList = [];
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_missionJob')} ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : gorevList.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} ${local.translate('general_missionJob')} ${local.translate('general_notFound')}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                    ),
                  )
                : buildGorevler(),
      ),
      backgroundColor: Colors.deepPurple[50],
      floatingActionButton: FloatingActionButton(
         heroTag: 'gorev_listesi_fab', // ← benzersiz heroTag ekledik
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GorevAddEdit(
                createGorevUseCase: _createGorevUseCase,
                updateGorevUseCase: _updateGorevUseCase,
                getAllKategoriUseCase: _getAllKategoriUseCase,
                getAllOncelikUseCase: _getAllOncelikUseCase,
              ),
            ),
          );
          refreshGorevler();
        },
      ),
    );
  }

  Widget buildGorevler() => SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: List.generate(
            gorevList.length,
            (index) {
              final gorev = gorevList[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GorevDetail(gorevId: gorev.id!),
                    ),
                  );
                  refreshGorevler();
                },
                child: GorevCard(gorev: gorev),
              );
            },
          ),
        ),
      );
}
