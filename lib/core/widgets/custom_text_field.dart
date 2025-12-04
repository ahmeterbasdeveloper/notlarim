import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.maxLines = 1,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      // Metin stili: Siyah ve okunaklı
      style: const TextStyle(color: Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        // Kenarlık stili
        border: const OutlineInputBorder(),
        // Arka plan rengi (Mevcut tasarımına uygun olarak yarı saydam beyaz)
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        // Label stili
        labelStyle: const TextStyle(color: Colors.black87),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
