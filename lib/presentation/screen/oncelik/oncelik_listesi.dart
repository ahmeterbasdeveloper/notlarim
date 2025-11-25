import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/localization/localization.dart';

// Domain
import '../../../../domain/entities/oncelik.dart';
import '../../../../domain/usecases/oncelik/get_all_oncelik.dart';

// Data
import '../../../data/repositories/oncelik_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

// UI
import 'oncelik_card.dart';
import 'oncelik_detail.dart';
import 'oncelik_add_edit.dart';

/// 🧱 Öncelik Listesi Ekranı — Clean Architecture versiyonu.
/// UseCase tabanlı, entity yapısı ile çalışır.
class OncelikListesi extends StatefulWidget {
  const OncelikListesi({super.key});

  @override
  State<OncelikListesi> createState() => _OncelikListesiState();
}

class _OncelikListesiState extends State<OncelikListesi> {
  late final GetAllOncelik _getAllOncelikUseCase;

  List<Oncelik> oncelikList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final repository = OncelikRepositoryImpl(DatabaseHelper.instance);
    _getAllOncelikUseCase = GetAllOncelik(repository);
    _refreshOncelikler();
  }

  Future<void> _refreshOncelikler() async {
    setState(() => isLoading = true);
    try {
      final result = await _getAllOncelikUseCase();
      setState(() => oncelikList = result);
    } catch (e) {
      debugPrint('❌ Öncelikler yüklenirken hata: $e');
      setState(() => oncelikList = []);
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
          '${local.translate('general_priority')}  ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 24, color: Colors.amber),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : oncelikList.isEmpty
                ? Text(
                    '${local.translate('general_anyMessage')} ${local.translate('general_priority')} ${local.translate('general_notFound')}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  )
                : _buildOncelikler(),
      ),
      backgroundColor: Colors.deepPurple[50],
      floatingActionButton: FloatingActionButton(
         heroTag: 'oncelik_listesi_fab', // ← benzersiz heroTag ekledik
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditOncelik()),
          );
          _refreshOncelikler();
        },
        tooltip: local.translate('general_addPriority'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildOncelikler() => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(
            oncelikList.length,
            (index) {
              final oncelik = oncelikList[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          OncelikDetail(oncelikId: oncelik.id!),
                    ),
                  );
                  _refreshOncelikler();
                },
                child: OncelikCard(oncelik: oncelik),
              );
            },
          ),
        ),
      );
}
