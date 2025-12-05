import 'package:flutter/material.dart';
import 'package:notlarim/core/localization/localization.dart';

class KullanimKilavuzuWidget extends StatelessWidget {
  const KullanimKilavuzuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Localization nesnesini değişkene atıyoruz
    final loc = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.menu_book_outlined, color: Colors.indigo),
          const SizedBox(width: 10),
          Expanded(
              child: Text(loc.translate('userGuide') ?? 'Kullanım Kılavuzu')),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SOL MENÜ ---
              TopLevelExpansionTile(
                title: loc.translate('kilavuz_leftMenu') ?? 'Sol Menü',
                children: [
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_situations'),
                    content: loc.translate('kilavuz_situationsContent'),
                  ),
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_categories'),
                    content: loc.translate('kilavuz_categoriesContent'),
                  ),
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_priorities'),
                    content: loc.translate('kilavuz_prioritiesContent'),
                  ),
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_notes'),
                    content: loc.translate('kilavuz_notesContent'),
                  ),
                  // ✅ EKLENEN: Kontrol Listeleri
                  SubLevelExpansionTile(
                    title: loc.translate('menu_checklists'),
                    content: loc.translate('kilavuz_checklistsContent'),
                  ),
                  // ✅ EKLENEN: Hatırlatıcı
                  SubLevelExpansionTile(
                    title: loc.translate('general_reminder'),
                    content: loc.translate('kilavuz_reminderContent'),
                  ),
                  const Divider(), // Ayıraç
                  // ✅ EKLENEN: Güvenlik Kodunu Değiştir
                  SubLevelExpansionTile(
                    title: loc.translate('menu_changeSecurityCode'),
                    content: loc.translate('kilavuz_changeSecurityCodeContent'),
                  ),
                  // ✅ EKLENEN: Şifre Değiştir
                  SubLevelExpansionTile(
                    title: loc.translate('menu_changePassword'),
                    content: loc.translate('kilavuz_changePasswordContent'),
                  ),
                  // ✅ EKLENEN: Çıkış Yap
                  SubLevelExpansionTile(
                    title: loc.translate('menu_logout'),
                    content: loc.translate('kilavuz_logoutContent'),
                  ),
                ],
              ),

              const SizedBox(height: 10), // Gruplar arası boşluk

              // --- SAĞ MENÜ ---
              TopLevelExpansionTile(
                title: loc.translate('kilavuz_rightMenu') ?? 'Sağ Menü',
                children: [
                  SubLevelExpansionTile(
                    title: loc.translate('database_getBackup'),
                    content: loc.translate('kilavuz_getBackupContent'),
                  ),
                  SubLevelExpansionTile(
                    title: loc.translate('database_restoreBackup'),
                    content: loc.translate('kilavuz_restoreBackupContent'),
                  ),
                  // ✅ EKLENEN: Yedekleri Yönet
                  SubLevelExpansionTile(
                    title: loc.translate('database_manageBackups'),
                    content: loc.translate('kilavuz_manageBackupsContent'),
                  ),
                  const Divider(),
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_versionInformation'),
                    content: loc.translate('kilavuz_versionInformationContent'),
                  ),
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_abouttheProgram'),
                    content: loc.translate('kilavuz_abouttheProgramContent'),
                  ),
                  SubLevelExpansionTile(
                    title: loc.translate('kilavuz_userGuide'),
                    content: loc.translate('kilavuz_userGuideContent'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            loc.translate('general_ok') ?? 'Tamam',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// --- ÜST SEVİYE MENÜ ELEMANI ---
class TopLevelExpansionTile extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const TopLevelExpansionTile({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  State<TopLevelExpansionTile> createState() => _TopLevelExpansionTileState();
}

class _TopLevelExpansionTileState extends State<TopLevelExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
          color: Colors.indigo,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() => isExpanded = expanded);
        },
        childrenPadding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
        children: widget.children,
      ),
    );
  }
}

// --- ALT SEVİYE MENÜ ELEMANI ---
class SubLevelExpansionTile extends StatefulWidget {
  final String? title;
  final String? content;

  const SubLevelExpansionTile({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  State<SubLevelExpansionTile> createState() => _SubLevelExpansionTileState();
}

class _SubLevelExpansionTileState extends State<SubLevelExpansionTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.title == null) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          widget.title!,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        trailing: Icon(
          isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
          size: 20,
          color: isExpanded ? Colors.redAccent : Colors.green,
        ),
        onExpansionChanged: (bool expanded) {
          setState(() => isExpanded = expanded);
        },
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.content ?? 'İçerik bulunamadı.',
              style: const TextStyle(
                  fontSize: 14, height: 1.4, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
