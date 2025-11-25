import 'package:flutter/material.dart';
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/get_hatirlatici_by_id.dart';
import 'package:notlarim/domain/usecases/hatirlatici/delete_hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/create_hatirlatici.dart';
import 'package:notlarim/domain/usecases/hatirlatici/update_hatirlatici.dart';
import 'package:notlarim/domain/usecases/kategori/get_all_kategori.dart';
import 'package:notlarim/domain/usecases/oncelik/get_all_oncelik.dart';
import 'package:notlarim/localization/localization.dart';

import '../../../core/config/app_config.dart';
import 'hatirlatici_add_edit.dart';

/// 📘 Hatırlatıcı Detay Sayfası — Clean Architecture uyumlu versiyon
class HatirlaticiDetail extends StatefulWidget {
  final int hatirlaticiId;

  /// UseCase'ler
  final GetHatirlaticiById getHatirlaticiByIdUseCase;
  final DeleteHatirlatici deleteHatirlaticiUseCase;
  final CreateHatirlatici createHatirlaticiUseCase;
  final UpdateHatirlatici updateHatirlaticiUseCase;
  final GetAllKategori getAllKategoriUseCase;
  final GetAllOncelik getAllOncelikUseCase;

  const HatirlaticiDetail({
    super.key,
    required this.hatirlaticiId,
    required this.getHatirlaticiByIdUseCase,
    required this.deleteHatirlaticiUseCase,
    required this.createHatirlaticiUseCase,
    required this.updateHatirlaticiUseCase,
    required this.getAllKategoriUseCase,
    required this.getAllOncelikUseCase,
  });

  @override
  State<HatirlaticiDetail> createState() => _HatirlaticiDetailState();
}

class _HatirlaticiDetailState extends State<HatirlaticiDetail> {
  Hatirlatici? _hatirlatici;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHatirlatici();
  }

  /// 🔹 ID ile hatırlatıcıyı yükler
  Future<void> _loadHatirlatici() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.getHatirlaticiByIdUseCase(widget.hatirlaticiId);
      if (!mounted) return;
      setState(() => _hatirlatici = result);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${loc.translate('general_reminder')} ${loc.translate('general_detail')}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        actions: [
          if (!_isLoading && _hatirlatici != null) ...[
            _editButton(),
            _deleteButton(),
          ],
        ],
      ),
      body: _buildBody(loc),
    );
  }

  /// 🔹 Gövde oluşturma
  Widget _buildBody(AppLocalizations loc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_hatirlatici == null) {
      return Center(child: Text(loc.translate('general_dataNotFound')));
    }

    return _buildDetailBody(loc);
  }

  /// 🔹 Detay içeriği
  Widget _buildDetailBody(AppLocalizations loc) {
    final hatirlatici = _hatirlatici!;
    final dateFormat = AppConfig.dateFormat;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildDetailRow(loc.translate('general_title'), hatirlatici.baslik),
          const SizedBox(height: 12),
          _buildDetailRow(loc.translate('general_explanation'), hatirlatici.aciklama),
          const SizedBox(height: 12),
          _buildDetailRow(loc.translate('general_category'), hatirlatici.kategoriId.toString()),
          const SizedBox(height: 12),
          _buildDetailRow(loc.translate('general_priority'), hatirlatici.oncelikId.toString()),
          const SizedBox(height: 12),
          _buildDetailRow(
            loc.translate('general_reminderDate'),
            dateFormat.format(hatirlatici.hatirlatmaTarihiZamani),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            loc.translate('general_createdDate'),
            dateFormat.format(hatirlatici.kayitZamani),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            loc.translate('general_status'),
            hatirlatici.durumId == 1
                ? loc.translate('general_active')
                : loc.translate('general_passive'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      );

  /// 🔹 Düzenleme butonu
  Widget _editButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        onPressed: () async {
          if (_isLoading || _hatirlatici == null) return;

          final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HatirlaticiAddEdit(
              hatirlatici: _hatirlatici!,
              createHatirlaticiUseCase: widget.createHatirlaticiUseCase,
              updateHatirlaticiUseCase: widget.updateHatirlaticiUseCase,
              getAllKategoriUseCase: widget.getAllKategoriUseCase,
              getAllOncelikUseCase: widget.getAllOncelikUseCase,
            ),
          ));

          if (result == true) await _loadHatirlatici();
        },
      );

  /// 🔹 Silme butonu
  Widget _deleteButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.delete_forever),
        onPressed: () async {
          if (_hatirlatici == null) return;

          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context).translate('general_deleteConfirm')),
              content: Text(AppLocalizations.of(context).translate('general_deleteQuestion')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context).translate('general_no')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AppLocalizations.of(context).translate('general_yes')),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            try {
              await widget.deleteHatirlaticiUseCase(_hatirlatici!.id!);
              if (mounted) {
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).translate('general_deletedSuccessfully'),
                    ),
                    backgroundColor: Colors.green.shade700,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${e.toString()}'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
              }
            }
          }
        },
      );
}
