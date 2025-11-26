import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod eklendi
import 'package:notlarim/localization/localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 1. PROVIDER: Paket bilgisini çeken basit bir FutureProvider
// Bunu isterseniz ayrı bir dosyaya (ör: core/providers.dart) da taşıyabilirsiniz.
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

// 2. WIDGET: ConsumerWidget'a dönüştürüldü
class VersiyonBilgisiWidget extends ConsumerWidget {
  const VersiyonBilgisiWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. STATE İZLEME: Veriyi provider'dan dinliyoruz
    final packageInfoAsync = ref.watch(packageInfoProvider);

    // 4. AsyncValue ile durum yönetimi (Yükleniyor, Hata, Veri)
    return packageInfoAsync.when(
      loading: () => const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => AlertDialog(
        title: const Text('Hata'),
        content: Text(
            '${AppLocalizations.of(context).translate('general_errorOccurredMessage')}: $err'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('general_ok')),
          ),
        ],
      ),
      data: (packageInfo) => AlertDialog(
        title: Text(
            AppLocalizations.of(context).translate('menu_versionInformation')),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  '${AppLocalizations.of(context).translate('menu_applicationVersion')}: ${packageInfo.version}'),
              Text('Build Numarası: ${packageInfo.buildNumber}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context).translate('general_ok')),
          ),
        ],
      ),
    );
  }
}
