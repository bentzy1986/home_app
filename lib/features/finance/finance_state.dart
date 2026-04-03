import 'package:flutter/material.dart';
import 'models/finance_models.dart';

class FinanceState extends ChangeNotifier {
  // ====== תנועות ======
  final List<Transaction> transactions = [
    Transaction(
      id: 't1',
      title: 'משכורת',
      amount: 15000,
      isIncome: true,
      category: ExpenseCategory.income,
      date: DateTime(DateTime.now().year, DateTime.now().month, 1),
    ),
    Transaction(
      id: 't2',
      title: 'סופרמרקט',
      amount: 450,
      isIncome: false,
      category: ExpenseCategory.food,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: 't3',
      title: 'דלק',
      amount: 320,
      isIncome: false,
      category: ExpenseCategory.fuel,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: 't4',
      title: 'שכירות נכס',
      amount: 3500,
      isIncome: true,
      category: ExpenseCategory.income,
      date: DateTime(DateTime.now().year, DateTime.now().month, 5),
    ),
  ];

  // ====== תקציב חודשי ======
  final List<BudgetItem> budgetItems = [
    BudgetItem(category: ExpenseCategory.food, budgetAmount: 3000),
    BudgetItem(category: ExpenseCategory.fuel, budgetAmount: 800),
    BudgetItem(category: ExpenseCategory.education, budgetAmount: 1500),
    BudgetItem(category: ExpenseCategory.health, budgetAmount: 500),
    BudgetItem(category: ExpenseCategory.entertainment, budgetAmount: 600),
    BudgetItem(category: ExpenseCategory.clothing, budgetAmount: 400),
    BudgetItem(category: ExpenseCategory.bills, budgetAmount: 2000),
    BudgetItem(category: ExpenseCategory.other, budgetAmount: 500),
  ];

  // ====== יעדי חיסכון ======
  final List<SavingGoal> savingGoals = [
    SavingGoal(
      id: 's1',
      title: 'חופשה משפחתית',
      targetAmount: 15000,
      currentAmount: 4500,
      targetDate: DateTime(DateTime.now().year + 1, 7, 1),
      color: const Color(0xFF2193B0),
    ),
    SavingGoal(
      id: 's2',
      title: 'קרן חירום',
      targetAmount: 30000,
      currentAmount: 12000,
      color: const Color(0xFF11998E),
    ),
  ];

  // ====== הלוואות ======
  final List<LoanAccount> loans = [
    LoanAccount(
      id: 'l1',
      title: 'הלוואת רכב',
      totalAmount: 60000,
      paidAmount: 24000,
      monthlyPayment: 1500,
      startDate: DateTime(2023, 1, 1),
    ),
  ];

  // ====== חישובים ======

  // תנועות החודש הנוכחי
  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    return transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // סך הכנסות החודש
  double get monthlyIncome {
    return thisMonthTransactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // סך הוצאות החודש
  double get monthlyExpenses {
    return thisMonthTransactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // יתרה
  double get balance => monthlyIncome - monthlyExpenses;

  // הוצאות לפי קטגוריה החודש
  Map<ExpenseCategory, double> get expensesByCategory {
    final map = <ExpenseCategory, double>{};
    for (final t in thisMonthTransactions.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  // תקציב לפי קטגוריה
  double budgetFor(ExpenseCategory category) {
    try {
      return budgetItems.firstWhere((b) => b.category == category).budgetAmount;
    } catch (_) {
      return 0;
    }
  }

  // הוצאה בפועל לפי קטגוריה
  double spentFor(ExpenseCategory category) {
    return expensesByCategory[category] ?? 0;
  }

  // סך התקציב החודשי
  double get totalBudget =>
      budgetItems.fold(0, (sum, b) => sum + b.budgetAmount);

  // נתוני גרף — הוצאות לפי חודש (6 חודשים אחרונים)
  List<Map<String, dynamic>> get monthlyExpensesChart {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final expenses = transactions
          .where(
            (t) =>
                !t.isIncome &&
                t.date.year == month.year &&
                t.date.month == month.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      result.add({'month': _hebrewMonth(month.month), 'amount': expenses});
    }
    return result;
  }

  String _hebrewMonth(int m) {
    const months = [
      'ינו',
      'פבר',
      'מרץ',
      'אפר',
      'מאי',
      'יוני',
      'יולי',
      'אוג',
      'ספט',
      'אוק',
      'נוב',
      'דצמ',
    ];
    return months[(m - 1) % 12];
  }

  // ====== פעולות ======

  void addTransaction(Transaction t) {
    transactions.insert(0, t);
    notifyListeners();
  }

  void updateTransaction(Transaction updated) {
    final i = transactions.indexWhere((t) => t.id == updated.id);
    if (i != -1) {
      transactions[i] = updated;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updateBudget(ExpenseCategory category, double amount) {
    final i = budgetItems.indexWhere((b) => b.category == category);
    if (i != -1) {
      budgetItems[i].budgetAmount = amount;
      notifyListeners();
    }
  }

  void addSavingGoal(SavingGoal goal) {
    savingGoals.add(goal);
    notifyListeners();
  }

  void updateSavingGoal(String id, double addAmount) {
    final i = savingGoals.indexWhere((s) => s.id == id);
    if (i != -1) {
      savingGoals[i].currentAmount += addAmount;
      notifyListeners();
    }
  }

  void deleteSavingGoal(String id) {
    savingGoals.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void addLoan(LoanAccount loan) {
    loans.add(loan);
    notifyListeners();
  }

  void updateLoanPayment(String id, double amount) {
    final i = loans.indexWhere((l) => l.id == id);
    if (i != -1) {
      loans[i].paidAmount += amount;
      notifyListeners();
    }
  }

  void deleteLoan(String id) {
    loans.removeWhere((l) => l.id == id);
    notifyListeners();
  }
}
