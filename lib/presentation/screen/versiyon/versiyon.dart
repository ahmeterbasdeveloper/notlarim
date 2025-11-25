// versiyon_bilgisi_widget.dart
import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersiyonBilgisiWidget extends StatelessWidget {
  const VersiyonBilgisiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(AppLocalizations.of(context)
                  .translate('general_errorOccurredMessage')));
        } else if (snapshot.hasData) {
          final packageInfo = snapshot.data!;
          return AlertDialog(
            title: Text(AppLocalizations.of(context)
                .translate('menu_versionInformation')),
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
                child:
                    Text(AppLocalizations.of(context).translate('general_ok')),
              ),
            ],
          );
        } else {
          return Center(
              child: Text(AppLocalizations.of(context)
                  .translate('general_informationNotFoundMessage')));
        }
      },
    );
  }
}
