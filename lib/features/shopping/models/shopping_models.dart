import 'package:flutter/material.dart';

// ====== קטגוריית קניות ======
enum ShoppingCategory {
  produce,
  meat,
  dairy,
  bakery,
  cleaning,
  personal,
  frozen,
  pantry,
  drinks,
  home,
  other,
}

extension ShoppingCategoryExtension on ShoppingCategory {
  String get label {
    switch (this) {
      case ShoppingCategory.produce:
        return 'ירקות ופירות';
      case ShoppingCategory.meat:
        return 'בשר ודגים';
      case ShoppingCategory.dairy:
        return 'מוצרי חלב';
      case ShoppingCategory.bakery:
        return 'לחם ומאפים';
      case ShoppingCategory.cleaning:
        return 'ניקיון';
      case ShoppingCategory.personal:
        return 'טיפוח אישי';
      case ShoppingCategory.frozen:
        return 'קפואים';
      case ShoppingCategory.pantry:
        return 'מזון יבש';
      case ShoppingCategory.drinks:
        return 'שתייה';
      case ShoppingCategory.home:
        return 'לבית';
      case ShoppingCategory.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case ShoppingCategory.produce:
        return Icons.eco_rounded;
      case ShoppingCategory.meat:
        return Icons.set_meal_rounded;
      case ShoppingCategory.dairy:
        return Icons.egg_rounded;
      case ShoppingCategory.bakery:
        return Icons.bakery_dining_rounded;
      case ShoppingCategory.cleaning:
        return Icons.cleaning_services_rounded;
      case ShoppingCategory.personal:
        return Icons.face_rounded;
      case ShoppingCategory.frozen:
        return Icons.ac_unit_rounded;
      case ShoppingCategory.pantry:
        return Icons.inventory_2_rounded;
      case ShoppingCategory.drinks:
        return Icons.local_drink_rounded;
      case ShoppingCategory.home:
        return Icons.chair_rounded;
      case ShoppingCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ShoppingCategory.produce:
        return const Color(0xFF4CAF50);
      case ShoppingCategory.meat:
        return const Color(0xFFEB3349);
      case ShoppingCategory.dairy:
        return const Color(0xFF2196F3);
      case ShoppingCategory.bakery:
        return const Color(0xFFFF9800);
      case ShoppingCategory.cleaning:
        return const Color(0xFF00BCD4);
      case ShoppingCategory.personal:
        return const Color(0xFF9C27B0);
      case ShoppingCategory.frozen:
        return const Color(0xFF3F51B5);
      case ShoppingCategory.pantry:
        return const Color(0xFF795548);
      case ShoppingCategory.drinks:
        return const Color(0xFF009688);
      case ShoppingCategory.home:
        return const Color(0xFF607D8B);
      case ShoppingCategory.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

// ====== סוג רשימה ======
enum ListType { weekly, urgent, occasional, home }

extension ListTypeExtension on ListType {
  String get label {
    switch (this) {
      case ListType.weekly:
        return 'שבועית';
      case ListType.urgent:
        return 'דחופה';
      case ListType.occasional:
        return 'חגיגית';
      case ListType.home:
        return 'לבית';
    }
  }

  IconData get icon {
    switch (this) {
      case ListType.weekly:
        return Icons.repeat_rounded;
      case ListType.urgent:
        return Icons.flash_on_rounded;
      case ListType.occasional:
        return Icons.celebration_rounded;
      case ListType.home:
        return Icons.home_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ListType.weekly:
        return const Color(0xFF2196F3);
      case ListType.urgent:
        return const Color(0xFFEB3349);
      case ListType.occasional:
        return const Color(0xFF9C27B0);
      case ListType.home:
        return const Color(0xFF4CAF50);
    }
  }
}

// ====== פריט קנייה ======
class ShoppingItem {
  final String id;
  String name;
  final ShoppingCategory category;
  double? quantity;
  String? unit;
  bool isChecked;
  double? price;
  String? notes;
  bool isPantryItem; // פריט מזווה

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    this.isChecked = false,
    this.price,
    this.notes,
    this.isPantryItem = false,
  });
}

// ====== רשימת קניות ======
class ShoppingList {
  final String id;
  String name;
  final ListType type;
  final DateTime createdAt;
  final List<ShoppingItem> items;
  bool isActive;

  ShoppingList({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.items,
    this.isActive = true,
  });

  int get totalItems => items.length;
  int get checkedItems => items.where((i) => i.isChecked).length;
  double get progress => totalItems == 0 ? 0 : checkedItems / totalItems;
  double get totalPrice =>
      items.fold(0, (sum, i) => sum + (i.price ?? 0) * (i.quantity ?? 1));

  List<ShoppingItem> get uncheckedItems =>
      items.where((i) => !i.isChecked).toList();
  List<ShoppingItem> get checkedItemsList =>
      items.where((i) => i.isChecked).toList();

  // פריטים לפי קטגוריה
  Map<ShoppingCategory, List<ShoppingItem>> get itemsByCategory {
    final map = <ShoppingCategory, List<ShoppingItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }
}

// ====== פריט מזווה ======
class PantryItem {
  final String id;
  String name;
  final ShoppingCategory category;
  int quantity;
  int minQuantity;
  String? unit;

  PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minQuantity,
    this.unit,
  });

  bool get isLow => quantity <= minQuantity;
}
