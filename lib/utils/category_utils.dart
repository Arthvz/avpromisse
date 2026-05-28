import 'package:flutter/material.dart';

class CategoryUtils {
  static const List<String> categories = [
    'Família',
    'Trabalho',
    'Estudo',
    'Saúde',
    'Pessoal',
    'Outro',
  ];

  static const Map<String, Color> _colors = {
    'Família': Colors.pink,
    'Trabalho': Colors.blue,
    'Estudo': Colors.orange,
    'Saúde': Colors.green,
    'Pessoal': Colors.purple,
    'Outro': Colors.grey,
  };

  static Color colorOf(String category) =>
      _colors[category] ?? Colors.grey;
}
