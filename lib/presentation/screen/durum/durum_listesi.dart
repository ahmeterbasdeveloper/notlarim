import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// 🌍 Çoklu dil desteği
import '../../../../localization/localization.dart';

// Domain & Data katmanları
import '../../../domain/entities/durum.dart';
import '../../../domain/usecases/durum/get_all_durum.dart';
import '../../../data/repositories/durum_repository_impl.dart';
import '../../../data/datasources/database_helper.dart';

// UI bileşenleri
import 'durum_add_edit.dart';
import 'durum_card.dart';
import 'durum_detail.dart';

/// 📋 Durumların listelendiği ana ekran.
/// Clean Architecture prensiplerine uygun + Çoklu dil desteği.
class DurumListesi extends StatefulWidget {
  const DurumListesi({super.key});

  @override
  State<DurumListesi> createState() => _DurumListesiState();
}

class _DurumListesiState extends State<DurumListesi> {
  // Repository ve UseCase tanımlamaları
  final repository = DurumRepositoryImpl(DatabaseHelper.instance);
  late final GetAllDurum getAllDurumUseCase;

  List<Durum> durumList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllDurumUseCase = GetAllDurum(repository);
    _loadDurumlar();
  }

  /// 📦 Tüm durumları yükler
  Future<void> _loadDurumlar() async {
    setState(() => isLoading = true);
    try {
      final result = await getAllDurumUseCase();
      setState(() => durumList = result);
    } catch (e) {
      debugPrint('❌ Durum listesi yüklenemedi: $e');
      if (mounted) {
        final local = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(local.translate('general_errorMessage'))),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// 🔁 Listeyi yeniler (ör. yeni kayıt sonrası)
  Future<void> _refreshList() async {
    await _loadDurumlar();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_situation')} ${local.translate('general_list')}',
          style: const TextStyle(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      backgroundColor: Colors.deepPurple[50],

      floatingActionButton: FloatingActionButton(
         heroTag: 'durum_listesi_fab', // ← benzersiz heroTag ekledik
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        tooltip: local.translate('general_addNewSituation'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditDurum()),
          );
          _refreshList();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : durumList.isEmpty
                  ? Text(
                      '${local.translate('general_anyMessage')} '
                      '${local.translate('general_situation')} '
                      '${local.translate('general_notFound')}',
                      style: const TextStyle(color: Colors.red, fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                  : _buildDurumGrid(),
        ),
      ),
    );
  }

  /// 🧱 Durumları grid yapısında gösterir
  Widget _buildDurumGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: durumList.map((durum) {
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DurumDetail(durumId: durum.id!),
                ),
              );
              _refreshList();
            },
            child: DurumCard(durum: durum),
          );
        }).toList(),
      ),
    );
  }
}
