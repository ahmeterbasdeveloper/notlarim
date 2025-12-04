import 'package:flutter/material.dart';
import 'package:notlarim/core/localization/localization.dart';

class KullanimKilavuzuWidget extends StatelessWidget {
  const KullanimKilavuzuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate('userGuide')),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopLevelExpansionTile(
              title: AppLocalizations.of(context).translate('kilavuz_leftMenu'),
              children: [
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('kilavuz_situations'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_situationsContent'),
                ),
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('kilavuz_categories'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_categoriesContent'),
                ),
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('kilavuz_priorities'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_prioritiesContent'),
                ),
                SubLevelExpansionTile(
                  title:
                      AppLocalizations.of(context).translate('kilavuz_notes'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_notesContent'),
                ),
              ],
            ),
            TopLevelExpansionTile(
              title:
                  AppLocalizations.of(context).translate('kilavuz_rightMenu'),
              children: [
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('database_getBackup'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_getBackupContent'),
                ),
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('database_restoreBackup'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_restoreBackupContent'),
                ),
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('kilavuz_versionInformation'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_versionInformationContent'),
                ),
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('kilavuz_abouttheProgram'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_abouttheProgramContent'),
                ),
                SubLevelExpansionTile(
                  title: AppLocalizations.of(context)
                      .translate('kilavuz_userGuide'),
                  content: AppLocalizations.of(context)
                      .translate('kilavuz_userGuideContent'),
                ),
              ],
            ),
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
    );
  }
}

class TopLevelExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const TopLevelExpansionTile({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  _TopLevelExpansionTileState createState() => _TopLevelExpansionTileState();
}

class _TopLevelExpansionTileState extends State<TopLevelExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
      onExpansionChanged: (bool expanded) {
        setState(() {
          isExpanded = expanded;
        });
      },
      children: widget.children,
    );
  }
}

class SubLevelExpansionTile extends StatefulWidget {
  final String title;
  final String content;

  const SubLevelExpansionTile({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  _SubLevelExpansionTileState createState() => _SubLevelExpansionTileState();
}

class _SubLevelExpansionTileState extends State<SubLevelExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      trailing: Icon(isExpanded ? Icons.remove : Icons.add),
      onExpansionChanged: (bool expanded) {
        setState(() {
          isExpanded = expanded;
        });
      },
      children: [
        ListTile(
          title: Text(widget.content),
        ),
      ],
    );
  }
}
