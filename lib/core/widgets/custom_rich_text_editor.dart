import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomRichTextEditor extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final String label;
  final double height;

  const CustomRichTextEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiket
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Editör Alanı
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            // Renk ayarı
            color: Colors.white.withValues(alpha: 0.8),
          ),
          child: Column(
            children: [
              // 1. ARAÇ ÇUBUĞU (Toolbar)
              // 🛠️ DÜZELTME: Toolbar sığmazsa hata vermemesi için SingleChildScrollView içine alındı.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    QuillSimpleToolbar(
                      controller: controller,
                      config: const QuillSimpleToolbarConfig(
                        showFontFamily: false,
                        showSearchButton: false,
                        showIndent: true,
                        showListNumbers: true,
                        showListBullets: true,
                        showLink: true,
                        toolbarSectionSpacing: 2,
                        // Butonları biraz küçültebiliriz (isteğe bağlı)
                        buttonOptions: QuillSimpleToolbarButtonOptions(
                          base: QuillToolbarBaseButtonOptions(
                            iconSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.grey),

              // 2. EDİTÖR ALANI
              // Tıklama alanını garantiye almak için GestureDetector ekleyebiliriz
              GestureDetector(
                onTap: () {
                  if (!focusNode.hasFocus) {
                    focusNode.requestFocus();
                  }
                },
                child: SizedBox(
                  height: height,
                  child: QuillEditor.basic(
                    controller: controller,
                    focusNode: focusNode,
                    config: const QuillEditorConfig(
                      padding: EdgeInsets.all(16),
                      placeholder: 'Buraya notunuzu yazın...',
                      autoFocus: false,
                      expands:
                          false, // Scrollview içinde olduğu için false olmalı
                      scrollable: true, // Kendi içinde scroll olabilsin
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
