import 'package:flutter/material.dart';

// ====== קטגוריות הוצאה ======
enum ExpenseCategory {
  food,
  fuel,
  education,
  health,
  entertainment,
  clothing,
  bills,
  savings,
  income,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'מזון';
      case ExpenseCategory.fuel:
        return 'דלק ורכב';
      case ExpenseCategory.education:
        return 'חינוך';
      case ExpenseCategory.health:
        return 'בריאות';
      case ExpenseCategory.entertainment:
        return 'בילוי';
      case ExpenseCategory.clothing:
        return 'ביגוד';
      case ExpenseCategory.bills:
        return 'חשבונות בית';
      case ExpenseCategory.savings:
        return 'חיסכון';
      case ExpenseCategory.income:
        return 'הכנסה';
      case ExpenseCategory.other:
        return 'שונות';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.fuel:
        return Icons.local_gas_station_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_rounded;
      case ExpenseCategory.clothing:
        return Icons.checkroom_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.savings:
        return Icons.savings_rounded;
      case ExpenseCategory.income:
        return Icons.payments_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF9800);
      case ExpenseCategory.fuel:
        return const Color(0xFF607D8B);
      case ExpenseCategory.education:
        return const Color(0xFF2196F3);
      case ExpenseCategory.health:
        return const Color(0xFFE91E63);
      case ExpenseCategory.entertainment:
        return const Color(0xFF9C27B0);
      case ExpenseCategory.clothing:
        return const Color(0xFF00BCD4);
      case ExpenseCategory.bills:
        return const Color(0xFF795548);
      case ExpenseCategory.savings:
        return const Color(0xFF4CAF50);
      case ExpenseCategory.income:
        return const Color(0xFF11998E);
      case ExpenseCategory.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

// ====== סוג הכנסה ======
enum IncomeType { salary, rent, freelance, other }

extension IncomeTypeExtension on IncomeType {
  String get label {
    switch (this) {
      case IncomeType.salary:
        return 'משכורת';
      case IncomeType.rent:
        return 'שכירות';
      case IncomeType.freelance:
        return 'פרילנס';
      case IncomeType.other:
        return 'אחר';
    }
  }
}

// ====== תנועה פיננסית ======
class Transaction {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final ExpenseCategory category;
  final DateTime date;
  final String? notes;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.notes,
  });
}

// ====== תקציב לקטגוריה ======
class BudgetItem {
  final ExpenseCategory category;
  double budgetAmount;

  BudgetItem({required this.category, required this.budgetAmount});
}

// ====== חיסכון / יעד ======
class SavingGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final DateTime? targetDate;
  final Color color;

  SavingGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.color,
  });

  double get progress =>
      currentAmount >= targetAmount ? 1.0 : currentAmount / targetAmount;

  int? get daysLeft => targetDate?.difference(DateTime.now()).inDays;
}

// ====== הלוואה / חשבון ======
class LoanAccount {
  final String id;
  final String title;
  final double totalAmount;
  double paidAmount;
  final double monthlyPayment;
  final DateTime startDate;

  LoanAccount({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.paidAmount,
    required this.monthlyPayment,
    required this.startDate,
  });

  double get remainingAmount => totalAmount - paidAmount;
  double get progress => paidAmount / totalAmount;
}
