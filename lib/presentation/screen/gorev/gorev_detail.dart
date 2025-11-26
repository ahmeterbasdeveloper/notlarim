import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';
import '../../../../core/config/app_config.dart';

// Domain
import '../../../../domain/entities/gorev.dart';
import '../../../../domain/usecases/gorev/get_gorev_by_id.dart';
import '../../../../domain/usecases/gorev/delete_gorev.dart';

// DI
import '../../../../core/di/injection_container.dart';

// UI
import 'gorev_add_edit.dart';

class GorevDetail extends StatefulWidget {
  final int gorevId;

  const GorevDetail({super.key, required this.gorevId});

  @override
  State<GorevDetail> createState() => _GorevDetailState();
}

class _GorevDetailState extends State<GorevDetail> {
  // ✅ UseCase'leri DI'dan çekiyoruz
  final GetGorevById _getGorevByIdUseCase = sl<GetGorevById>();
  final DeleteGorev _deleteGorevUseCase = sl<DeleteGorev>();

  Gorev? gorev;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshGorev();
  }

  Future<void> _refreshGorev() async {
    setState(() => isLoading = true);
    try {
      final result = await _getGorevByIdUseCase(widget.gorevId);
      setState(() => gorev = result);
    } catch (e) {
      debugPrint('❌ Görev yüklenirken hata: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteGorev() async {
    try {
      await _deleteGorevUseCase(widget.gorevId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ Görev silinirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.green.shade900,
        title: Text(
          '${local.translate('general_missionJob')} ${local.translate('general_detail')}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: Colors.white,
            onPressed: isLoading || gorev == null
                ? null
                : () async {
                    // Düzenleme ekranına parametre göndermeden yönlendiriyoruz
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => GorevAddEdit(gorev: gorev!),
                    ));
                    _refreshGorev();
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: isLoading ? null : _deleteGorev,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gorev == null
              ? Center(
                  child: Text(
                    local.translate('general_notFound'),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : _buildDetail(context, gorev!, local),
    );
  }

  Widget _buildDetail(
      BuildContext context, Gorev gorev, AppLocalizations local) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildField(local.translate('general_title'), gorev.baslik),
          _buildField(local.translate('general_explanation'), gorev.aciklama),
          _buildField(
            local.translate('general_startingDate'),
            AppConfig.dateFormat.format(gorev.baslamaTarihiZamani),
          ),
          _buildField(
            local.translate('general_endDate'),
            AppConfig.dateFormat.format(gorev.bitisTarihiZamani),
          ),
          _buildField(
            local.translate('general_registrationDate'),
            AppConfig.dateFormat.format(gorev.kayitZamani),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
