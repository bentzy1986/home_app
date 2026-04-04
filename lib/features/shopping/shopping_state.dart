import 'package:flutter/material.dart';
import 'models/shopping_models.dart';

class ShoppingState extends ChangeNotifier {
  final List<ShoppingList> lists = [
    ShoppingList(
      id: 'l1',
      name: 'קניות שבועיות',
      type: ListType.weekly,
      createdAt: DateTime.now(),
      items: [
        ShoppingItem(
          id: 'i1',
          name: 'עגבניות',
          category: ShoppingCategory.produce,
          quantity: 1,
          unit: 'ק"ג',
        ),
        ShoppingItem(
          id: 'i2',
          name: 'חזה עוף',
          category: ShoppingCategory.meat,
          quantity: 1.5,
          unit: 'ק"ג',
        ),
        ShoppingItem(
          id: 'i3',
          name: 'חלב',
          category: ShoppingCategory.dairy,
          quantity: 2,
          unit: 'ליטר',
        ),
        ShoppingItem(
          id: 'i4',
          name: 'לחם',
          category: ShoppingCategory.bakery,
          quantity: 1,
          unit: 'כיכר',
        ),
        ShoppingItem(
          id: 'i5',
          name: 'אבקת כביסה',
          category: ShoppingCategory.cleaning,
          quantity: 1,
          unit: 'יח׳',
        ),
        ShoppingItem(
          id: 'i6',
          name: 'מיץ תפוזים',
          category: ShoppingCategory.drinks,
          quantity: 2,
          unit: 'ליטר',
        ),
        ShoppingItem(
          id: 'i7',
          name: 'פסטה',
          category: ShoppingCategory.pantry,
          quantity: 3,
          unit: 'יח׳',
        ),
        ShoppingItem(
          id: 'i8',
          name: 'גבינה צהובה',
          category: ShoppingCategory.dairy,
          quantity: 200,
          unit: 'גר׳',
        ),
      ],
    ),
  ];

  final List<PantryItem> pantry = [
    PantryItem(
      id: 'p1',
      name: 'שמן זית',
      category: ShoppingCategory.pantry,
      quantity: 1,
      minQuantity: 1,
      unit: 'בקבוק',
    ),
    PantryItem(
      id: 'p2',
      name: 'אורז',
      category: ShoppingCategory.pantry,
      quantity: 3,
      minQuantity: 1,
      unit: 'ק"ג',
    ),
    PantryItem(
      id: 'p3',
      name: 'סוכר',
      category: ShoppingCategory.pantry,
      quantity: 0,
      minQuantity: 1,
      unit: 'ק"ג',
    ),
    PantryItem(
      id: 'p4',
      name: 'קפה',
      category: ShoppingCategory.drinks,
      quantity: 1,
      minQuantity: 1,
      unit: 'יח׳',
    ),
    PantryItem(
      id: 'p5',
      name: 'נייר טואלט',
      category: ShoppingCategory.cleaning,
      quantity: 2,
      minQuantity: 3,
      unit: 'יח׳',
    ),
    PantryItem(
      id: 'p6',
      name: 'שמפו',
      category: ShoppingCategory.personal,
      quantity: 1,
      minQuantity: 1,
      unit: 'יח׳',
    ),
  ];

  ShoppingList? get activeList => lists.where((l) => l.isActive).isNotEmpty
      ? lists.where((l) => l.isActive).first
      : null;

  List<PantryItem> get lowPantryItems => pantry.where((p) => p.isLow).toList();

  int get totalItemsToBuy =>
      lists.fold(0, (sum, l) => sum + l.uncheckedItems.length);

  // ====== פעולות רשימות ======
  void addList(ShoppingList list) {
    lists.add(list);
    notifyListeners();
  }

  void deleteList(String id) {
    lists.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  void renameList(String id, String name) {
    final l = lists.firstWhere((l) => l.id == id);
    l.name = name;
    notifyListeners();
  }

  void clearChecked(String listId) {
    final l = lists.firstWhere((l) => l.id == listId);
    l.items.removeWhere((i) => i.isChecked);
    notifyListeners();
  }

  void resetList(String listId) {
    final l = lists.firstWhere((l) => l.id == listId);
    for (final item in l.items) {
      item.isChecked = false;
    }
    notifyListeners();
  }

  // ====== פעולות פריטים ======
  void addItem(String listId, ShoppingItem item) {
    final l = lists.firstWhere((l) => l.id == listId);
    l.items.add(item);
    notifyListeners();
  }

  void toggleItem(String listId, String itemId) {
    final l = lists.firstWhere((l) => l.id == listId);
    final item = l.items.firstWhere((i) => i.id == itemId);
    item.isChecked = !item.isChecked;
    notifyListeners();
  }

  void deleteItem(String listId, String itemId) {
    final l = lists.firstWhere((l) => l.id == listId);
    l.items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  void updateItem(String listId, ShoppingItem updated) {
    final l = lists.firstWhere((l) => l.id == listId);
    final i = l.items.indexWhere((item) => item.id == updated.id);
    if (i != -1) {
      l.items[i] = updated;
      notifyListeners();
    }
  }

  // ====== פעולות מזווה ======
  void addPantryItem(PantryItem item) {
    pantry.add(item);
    notifyListeners();
  }

  void updatePantryQuantity(String id, int quantity) {
    final p = pantry.firstWhere((p) => p.id == id);
    p.quantity = quantity;
    notifyListeners();
  }

  void deletePantryItem(String id) {
    pantry.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addLowPantryToList(String listId) {
    final l = lists.firstWhere((l) => l.id == listId);
    for (final p in lowPantryItems) {
      final exists = l.items.any((i) => i.name == p.name);
      if (!exists) {
        l.items.add(
          ShoppingItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + p.id,
            name: p.name,
            category: p.category,
            quantity: (p.minQuantity - p.quantity + 1).toDouble(),
            unit: p.unit,
            isPantryItem: true,
          ),
        );
      }
    }
    notifyListeners();
  }
}
