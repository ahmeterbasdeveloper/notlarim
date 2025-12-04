import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod
import 'package:notlarim/domain/entities/hatirlatici.dart';
import 'package:notlarim/localization/localization.dart';

// ✅ DI Providers
import '../../../../core/di/hatirlatici_di_providers.dart';

import '../../../core/config/app_config.dart';
import 'hatirlatici_add_edit.dart';

class HatirlaticiDetail extends ConsumerStatefulWidget {
  final int hatirlaticiId;

  const HatirlaticiDetail({super.key, required this.hatirlaticiId});

  @override
  ConsumerState<HatirlaticiDetail> createState() => _HatirlaticiDetailState();
}

class _HatirlaticiDetailState extends ConsumerState<HatirlaticiDetail> {
  Hatirlatici? _hatirlatici;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHatirlatici();
  }

  Future<void> _loadHatirlatici() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // ✅ ref.read Generic GetById
      // Hatırlatıcı için özel ID metodunuz varsa (getHatirlaticiByIdProvider) onu kullanın,
      // yoksa generic olanı (getByIdUseCase) kullanabilirsiniz.
      // app_providers.dart dosyanızda 'getHatirlaticiByIdProvider' tanımlıydı.
      final result =
          await ref.read(getHatirlaticiByIdProvider).call(widget.hatirlaticiId);

      if (mounted) setState(() => _hatirlatici = result);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (Build metodları UI olarak aynı kalabilir, sadece buton eylemlerini güncelleyin)

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        // ... (AppBar kodları aynı)
        backgroundColor: Colors.green.shade900,
        title: Text(
            '${loc.translate('general_reminder')} ${loc.translate('general_detail')}',
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
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

  // ... (_buildBody ve _buildDetailBody metodları aynı kalabilir)
  Widget _buildBody(AppLocalizations loc) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (_hatirlatici == null) {
      return Center(child: Text(loc.translate('general_dataNotFound')));
    }
    return _buildDetailBody(loc);
  }

  Widget _buildDetailBody(AppLocalizations loc) {
    final hatirlatici = _hatirlatici!;
    final dateFormat = AppConfig.dateFormat;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildDetailRow(loc.translate('general_title'), hatirlatici.baslik),
          const SizedBox(height: 12),
          _buildDetailRow(
              loc.translate('general_explanation'), hatirlatici.aciklama),
          const SizedBox(height: 12),
          _buildDetailRow(loc.translate('general_reminderDate'),
              dateFormat.format(hatirlatici.hatirlatmaTarihiZamani)),
          // ... diğer alanlar
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value)
      ]);

  Widget _editButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        onPressed: () async {
          if (_isLoading || _hatirlatici == null) return;
          final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                HatirlaticiAddEdit(hatirlatici: _hatirlatici!),
          ));
          if (result == true) await _loadHatirlatici();
        },
      );

  Widget _deleteButton() => IconButton(
        color: Colors.white,
        icon: const Icon(Icons.delete_forever),
        onPressed: () async {
          if (_hatirlatici == null) return;
          // ... Dialog kodları aynı ...
          // Silme işlemi:
          try {
            // ✅ ref.read Generic Delete
            await ref.read(deleteHatirlaticiProvider).call(_hatirlatici!.id!);
            if (mounted) Navigator.of(context).pop(true);
          } catch (e) {
            // Hata gösterimi
          }
        },
      );
}
