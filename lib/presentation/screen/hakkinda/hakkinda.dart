// program_hakkinda_widget.dart
import 'package:flutter/material.dart';
import 'package:notlarim/localization/localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProgramHakkindaWidget extends StatelessWidget {
  const ProgramHakkindaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Hata oluştu'));
        } else if (snapshot.hasData) {
          final packageInfo = snapshot.data!;
          return AlertDialog(
            title:
                Text(AppLocalizations.of(context).translate('app_abouttheApp')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)
                        .translate('app_abouttheAppMessage1'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)
                        .translate('app_abouttheAppMessage2'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)
                        .translate('app_abouttheAppMessage3'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppLocalizations.of(context).translate('menu_version')}: ${packageInfo.version}\nBuild Numarası: ${packageInfo.buildNumber}',
                    style: const TextStyle(fontSize: 16),
                  ),
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
