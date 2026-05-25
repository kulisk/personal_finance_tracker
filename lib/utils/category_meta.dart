import 'package:flutter/material.dart';

import '../models/enums.dart';

class CategoryMeta {
  const CategoryMeta({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

const Map<CategoryType, CategoryMeta> categoryMeta = {
  CategoryType.food: CategoryMeta(
    label: 'Food',
    icon: Icons.restaurant,
    color: Color(0xFFE57373),
  ),
  CategoryType.transport: CategoryMeta(
    label: 'Transport',
    icon: Icons.directions_bus,
    color: Color(0xFF64B5F6),
  ),
  CategoryType.bills: CategoryMeta(
    label: 'Bills',
    icon: Icons.receipt_long,
    color: Color(0xFFFFB74D),
  ),
  CategoryType.entertainment: CategoryMeta(
    label: 'Entertainment',
    icon: Icons.movie,
    color: Color(0xFFBA68C8),
  ),
  CategoryType.shopping: CategoryMeta(
    label: 'Shopping',
    icon: Icons.shopping_bag,
    color: Color(0xFF4DB6AC),
  ),
  CategoryType.health: CategoryMeta(
    label: 'Health',
    icon: Icons.health_and_safety,
    color: Color(0xFFAED581),
  ),
  CategoryType.salary: CategoryMeta(
    label: 'Salary',
    icon: Icons.work,
    color: Color(0xFF81C784),
  ),
  CategoryType.other: CategoryMeta(
    label: 'Other',
    icon: Icons.category,
    color: Color(0xFF90A4AE),
  ),
};

CategoryMeta metaFor(CategoryType type) {
  return categoryMeta[type] ?? categoryMeta[CategoryType.other]!;
}
