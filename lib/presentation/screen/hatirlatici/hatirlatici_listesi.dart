import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/get_all_hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/get_hatirlatici_by_id.dart';
import 'package:notlarim/domain/usecases/hatirlatici/create_hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/update_hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/delete_hatirlatici.dart';
import 'package:notlarim/domain/usecases/kategori/get_all_kategori.dart';
import 'package:notlarim/domain/usecases/oncelik/get_all_oncelik.dart';
import 'package:notlarim/localization/localization.dart';

import 'hatirlatici_card.dart';
import 'hatirlatici_detail.dart';
import 'hatirlatici_add_edit.dart';

/// 📋 Hatırlatıcı Listesi Ekranı — Clean Architecture uyumlu sürüm
class HatirlaticiListesi extends StatefulWidget {
  final GetAllHatirlatici getAllHatirlaticiUseCase;
  final GetHatirlaticiById getHatirlaticiByIdUseCase;
  final CreateHatirlatici createHatirlaticiUseCase;
  final UpdateHatirlatici updateHatirlaticiUseCase;
  final DeleteHatirlatici deleteHatirlaticiUseCase;
  final GetAllKategori getAllKategoriUseCase;
  final GetAllOncelik getAllOncelikUseCase;

  const HatirlaticiListesi({
    super.key,
    required this.getAllHatirlaticiUseCase,
    required this.getHatirlaticiByIdUseCase,
    required this.createHatirlaticiUseCase,
    required this.updateHatirlaticiUseCase,
    required this.deleteHatirlaticiUseCase,
    required this.getAllKategoriUseCase,
    required this.getAllOncelikUseCase,
  });

  @override
  State<HatirlaticiListesi> createState() => _HatirlaticiListesiState();
}

class _HatirlaticiListesiState extends State<HatirlaticiListesi> {
  List<Hatirlatici> _hatirlaticilar = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHatirlaticilar();
  }

  /// 🔹 Verileri yeniler
  Future<void> _loadHatirlaticilar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.getAllHatirlaticiUseCase();
      if (!mounted) return;
      setState(() => _hatirlaticilar = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${loc.translate('general_reminder')} ${loc.translate('general_list')}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHatirlaticilar,
          )
        ],
      ),
      body: _buildBody(context, loc),
      backgroundColor: Colors.deepPurple[50],

      /// ➕ Yeni Hatırlatıcı Ekle
      floatingActionButton: FloatingActionButton(
         heroTag: 'hatirlatici_listesi_fab', // ← benzersiz heroTag ekledik
        backgroundColor: const Color.fromARGB(255, 78, 18, 92),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HatirlaticiAddEdit(
                createHatirlaticiUseCase: widget.createHatirlaticiUseCase,
                updateHatirlaticiUseCase: widget.updateHatirlaticiUseCase,
                getAllKategoriUseCase: widget.getAllKategoriUseCase,
                getAllOncelikUseCase: widget.getAllOncelikUseCase,
              ),
            ),
          );
          if (result == true && mounted) _loadHatirlaticilar();
        },
      ),
    );
  }

  /// 🔹 İçerik Gövdesi
  Widget _buildBody(BuildContext context, AppLocalizations loc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          '${loc.translate('general_dataLoadingError')}\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    if (_hatirlaticilar.isEmpty) {
      return Center(
        child: Text(
          '${loc.translate('general_no')} ${loc.translate('general_reminder')} ${loc.translate('general_found')}',
          style: const TextStyle(fontSize: 20, color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHatirlaticilar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        child: MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          itemCount: _hatirlaticilar.length,
          itemBuilder: (context, index) {
            final hatirlatici = _hatirlaticilar[index];
            return HatirlaticiCard(
              hatirlatici: hatirlatici,
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HatirlaticiDetail(
                      hatirlaticiId: hatirlatici.id!,
                      getHatirlaticiByIdUseCase:
                          widget.getHatirlaticiByIdUseCase,
                      deleteHatirlaticiUseCase: widget.deleteHatirlaticiUseCase,
                      createHatirlaticiUseCase: widget.createHatirlaticiUseCase,
                      updateHatirlaticiUseCase: widget.updateHatirlaticiUseCase,
                      getAllKategoriUseCase:
                          widget.getAllKategoriUseCase, // ✅ EKLENDİ
                      getAllOncelikUseCase:
                          widget.getAllOncelikUseCase, // ✅ EKLENDİ
                    ),
                  ),
                );
                if (result == true && mounted) _loadHatirlaticilar();
              },
            );
          },
        ),
      ),
    );
  }
}
