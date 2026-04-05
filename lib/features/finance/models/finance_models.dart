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

// ====== סוג מקור הכנסה ======
enum IncomeType { salary, rent, freelance, investment, pension, other }

extension IncomeTypeExtension on IncomeType {
  String get label {
    switch (this) {
      case IncomeType.salary:
        return 'משכורת';
      case IncomeType.rent:
        return 'שכירות';
      case IncomeType.freelance:
        return 'פרילנס';
      case IncomeType.investment:
        return 'השקעות';
      case IncomeType.pension:
        return 'פנסיה';
      case IncomeType.other:
        return 'אחר';
    }
  }

  IconData get icon {
    switch (this) {
      case IncomeType.salary:
        return Icons.work_rounded;
      case IncomeType.rent:
        return Icons.home_rounded;
      case IncomeType.freelance:
        return Icons.laptop_rounded;
      case IncomeType.investment:
        return Icons.show_chart_rounded;
      case IncomeType.pension:
        return Icons.elderly_rounded;
      case IncomeType.other:
        return Icons.payments_rounded;
    }
  }

  Color get color {
    switch (this) {
      case IncomeType.salary:
        return const Color(0xFF2196F3);
      case IncomeType.rent:
        return const Color(0xFF11998E);
      case IncomeType.freelance:
        return const Color(0xFF9C27B0);
      case IncomeType.investment:
        return const Color(0xFF4CAF50);
      case IncomeType.pension:
        return const Color(0xFFFF9800);
      case IncomeType.other:
        return const Color(0xFF607D8B);
    }
  }
}

// ====== מקור הכנסה קבוע ======
class IncomeSource {
  final String id;
  String name;
  final IncomeType type;
  double amount;
  String? owner; // שם בעל ההכנסה (אבא/אמא/וכו׳)
  bool isActive;

  IncomeSource({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.owner,
    this.isActive = true,
  });
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
  final String? incomeSourceId; // קישור למקור הכנסה

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.notes,
    this.incomeSourceId,
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
  final double? interestRate; // ריבית שנתית %
  final bool isCompoundInterest; // ריבית דריבית

  SavingGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.color,
    this.interestRate,
    this.isCompoundInterest = false,
  });

  double get progress =>
      currentAmount >= targetAmount ? 1.0 : currentAmount / targetAmount;

  int? get daysLeft => targetDate?.difference(DateTime.now()).inDays;

  // סכום עם ריבית לאחר X שנים
  double projectedAmount(int years) {
    if (interestRate == null || interestRate == 0) return currentAmount;
    final rate = interestRate! / 100;
    if (isCompoundInterest) {
      return currentAmount * (1 + rate) * years;
    } else {
      return currentAmount * (1 + rate * years);
    }
  }
}

// ====== הלוואה ======
class LoanAccount {
  final String id;
  final String title;
  final double totalAmount;
  double paidAmount;
  final double monthlyPayment;
  final DateTime startDate;
  final double? interestRate; // ריבית שנתית %
  final int? totalMonths; // מספר חודשי הלוואה

  LoanAccount({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.paidAmount,
    required this.monthlyPayment,
    required this.startDate,
    this.interestRate,
    this.totalMonths,
  });

  double get remainingAmount => totalAmount - paidAmount;
  double get progress =>
      totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0;

  // חודשים שנשארו
  int? get monthsLeft {
    if (totalMonths == null) return null;
    final monthsPaid = DateTime.now().difference(startDate).inDays ~/ 30;
    return (totalMonths! - monthsPaid).clamp(0, totalMonths!);
  }

  // סך ריבית לתשלום
  double get totalInterest {
    if (interestRate == null || totalMonths == null) return 0;
    return (monthlyPayment * totalMonths!) - totalAmount;
  }
}

// ====== נתוני חודש להשוואה ======
class MonthlyData {
  final DateTime month;
  final double income;
  final double expenses;

  MonthlyData({
    required this.month,
    required this.income,
    required this.expenses,
  });

  double get balance => income - expenses;
  double get savingsRate => income > 0 ? (balance / income) * 100 : 0;
}
