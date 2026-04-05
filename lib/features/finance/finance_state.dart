import 'package:flutter/material.dart';
import 'models/finance_models.dart';
import '../../services/storage_service.dart';

class FinanceState extends ChangeNotifier {
  List<Transaction> transactions = [];
  List<BudgetItem> budgetItems = [];
  List<SavingGoal> savingGoals = [];
  List<LoanAccount> loans = [];
  List<IncomeSource> incomeSources = [];

  // ====== Persistence ======
  Future<void> loadFromStorage() async {
    final transData = StorageService.loadJson('finance_transactions');
    final budgetData = StorageService.loadJson('finance_budget');
    final savingsData = StorageService.loadJson('finance_savings');
    final loansData = StorageService.loadJson('finance_loans');
    final incomeData = StorageService.loadJson('finance_income_sources');

    transactions = transData != null
        ? (transData as List).map((t) => _transactionFromJson(t)).toList()
        : _defaultTransactions();

    budgetItems = budgetData != null
        ? (budgetData as List).map((b) => _budgetFromJson(b)).toList()
        : _defaultBudget();

    savingGoals = savingsData != null
        ? (savingsData as List).map((s) => _savingFromJson(s)).toList()
        : [];

    loans = loansData != null
        ? (loansData as List).map((l) => _loanFromJson(l)).toList()
        : [];

    incomeSources = incomeData != null
        ? (incomeData as List).map((i) => _incomeSourceFromJson(i)).toList()
        : _defaultIncomeSources();

    notifyListeners();
  }

  Future<void> _save() async {
    await StorageService.saveJson(
      'finance_transactions',
      transactions.map((t) => _transactionToJson(t)).toList(),
    );
    await StorageService.saveJson(
      'finance_budget',
      budgetItems.map((b) => _budgetToJson(b)).toList(),
    );
    await StorageService.saveJson(
      'finance_savings',
      savingGoals.map((s) => _savingToJson(s)).toList(),
    );
    await StorageService.saveJson(
      'finance_loans',
      loans.map((l) => _loanToJson(l)).toList(),
    );
    await StorageService.saveJson(
      'finance_income_sources',
      incomeSources.map((i) => _incomeSourceToJson(i)).toList(),
    );
  }

  // ====== Serialization ======
  Map<String, dynamic> _transactionToJson(Transaction t) => {
    'id': t.id,
    'title': t.title,
    'amount': t.amount,
    'isIncome': t.isIncome,
    'category': t.category.index,
    'date': t.date.toIso8601String(),
    'notes': t.notes,
    'incomeSourceId': t.incomeSourceId,
  };

  Transaction _transactionFromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'],
    title: j['title'],
    amount: (j['amount'] as num).toDouble(),
    isIncome: j['isIncome'],
    category: ExpenseCategory.values[j['category']],
    date: DateTime.parse(j['date']),
    notes: j['notes'],
    incomeSourceId: j['incomeSourceId'],
  );

  Map<String, dynamic> _budgetToJson(BudgetItem b) => {
    'category': b.category.index,
    'budgetAmount': b.budgetAmount,
  };

  BudgetItem _budgetFromJson(Map<String, dynamic> j) => BudgetItem(
    category: ExpenseCategory.values[j['category']],
    budgetAmount: (j['budgetAmount'] as num).toDouble(),
  );

  Map<String, dynamic> _savingToJson(SavingGoal s) => {
    'id': s.id,
    'title': s.title,
    'targetAmount': s.targetAmount,
    'currentAmount': s.currentAmount,
    'targetDate': s.targetDate?.toIso8601String(),
    'color': s.color.toARGB32(),
    'interestRate': s.interestRate,
    'isCompoundInterest': s.isCompoundInterest,
  };

  SavingGoal _savingFromJson(Map<String, dynamic> j) => SavingGoal(
    id: j['id'],
    title: j['title'],
    targetAmount: (j['targetAmount'] as num).toDouble(),
    currentAmount: (j['currentAmount'] as num).toDouble(),
    targetDate: j['targetDate'] != null
        ? DateTime.parse(j['targetDate'])
        : null,
    color: Color(j['color']),
    interestRate: j['interestRate']?.toDouble(),
    isCompoundInterest: j['isCompoundInterest'] ?? false,
  );

  Map<String, dynamic> _loanToJson(LoanAccount l) => {
    'id': l.id,
    'title': l.title,
    'totalAmount': l.totalAmount,
    'paidAmount': l.paidAmount,
    'monthlyPayment': l.monthlyPayment,
    'startDate': l.startDate.toIso8601String(),
    'interestRate': l.interestRate,
    'totalMonths': l.totalMonths,
  };

  LoanAccount _loanFromJson(Map<String, dynamic> j) => LoanAccount(
    id: j['id'],
    title: j['title'],
    totalAmount: (j['totalAmount'] as num).toDouble(),
    paidAmount: (j['paidAmount'] as num).toDouble(),
    monthlyPayment: (j['monthlyPayment'] as num).toDouble(),
    startDate: DateTime.parse(j['startDate']),
    interestRate: j['interestRate']?.toDouble(),
    totalMonths: j['totalMonths'],
  );

  Map<String, dynamic> _incomeSourceToJson(IncomeSource i) => {
    'id': i.id,
    'name': i.name,
    'type': i.type.index,
    'amount': i.amount,
    'owner': i.owner,
    'isActive': i.isActive,
  };

  IncomeSource _incomeSourceFromJson(Map<String, dynamic> j) => IncomeSource(
    id: j['id'],
    name: j['name'],
    type: IncomeType.values[j['type']],
    amount: (j['amount'] as num).toDouble(),
    owner: j['owner'],
    isActive: j['isActive'] ?? true,
  );

  // ====== ברירות מחדל ======
  List<Transaction> _defaultTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: 't1',
        title: 'משכורת אבא',
        amount: 15000,
        isIncome: true,
        category: ExpenseCategory.income,
        date: DateTime(now.year, now.month, 1),
        incomeSourceId: 'is1',
      ),
      Transaction(
        id: 't2',
        title: 'משכורת אמא',
        amount: 12000,
        isIncome: true,
        category: ExpenseCategory.income,
        date: DateTime(now.year, now.month, 1),
        incomeSourceId: 'is2',
      ),
      Transaction(
        id: 't3',
        title: 'סופרמרקט',
        amount: 800,
        isIncome: false,
        category: ExpenseCategory.food,
        date: DateTime(now.year, now.month, 3),
      ),
      Transaction(
        id: 't4',
        title: 'דלק',
        amount: 350,
        isIncome: false,
        category: ExpenseCategory.fuel,
        date: DateTime(now.year, now.month, 5),
      ),
      Transaction(
        id: 't5',
        title: 'חשמל',
        amount: 450,
        isIncome: false,
        category: ExpenseCategory.bills,
        date: DateTime(now.year, now.month, 10),
      ),
      Transaction(
        id: 't6',
        title: 'קניות ביגוד',
        amount: 600,
        isIncome: false,
        category: ExpenseCategory.clothing,
        date: DateTime(now.year, now.month, 12),
      ),
      Transaction(
        id: 't7',
        title: 'מסעדה',
        amount: 280,
        isIncome: false,
        category: ExpenseCategory.entertainment,
        date: DateTime(now.year, now.month, 15),
      ),
    ];
  }

  List<BudgetItem> _defaultBudget() => [
    BudgetItem(category: ExpenseCategory.food, budgetAmount: 3000),
    BudgetItem(category: ExpenseCategory.fuel, budgetAmount: 800),
    BudgetItem(category: ExpenseCategory.education, budgetAmount: 1500),
    BudgetItem(category: ExpenseCategory.health, budgetAmount: 500),
    BudgetItem(category: ExpenseCategory.entertainment, budgetAmount: 600),
    BudgetItem(category: ExpenseCategory.clothing, budgetAmount: 800),
    BudgetItem(category: ExpenseCategory.bills, budgetAmount: 2000),
    BudgetItem(category: ExpenseCategory.savings, budgetAmount: 2000),
  ];

  List<IncomeSource> _defaultIncomeSources() => [
    IncomeSource(
      id: 'is1',
      name: 'משכורת אבא',
      type: IncomeType.salary,
      amount: 15000,
      owner: 'אבא',
    ),
    IncomeSource(
      id: 'is2',
      name: 'משכורת אמא',
      type: IncomeType.salary,
      amount: 12000,
      owner: 'אמא',
    ),
  ];

  // ====== Getters ======
  double get monthlyIncome {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.isIncome &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpenses {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              !t.isIncome &&
              t.date.month == now.month &&
              t.date.year == now.year,
        )
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance => monthlyIncome - monthlyExpenses;
  double get totalBudget =>
      budgetItems.fold(0, (sum, b) => sum + b.budgetAmount);

  // סך הכנסות ממקורות קבועים
  double get totalFixedIncome => incomeSources
      .where((s) => s.isActive)
      .fold(0, (sum, s) => sum + s.amount);

  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    return transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<ExpenseCategory, double> get expensesByCategory {
    final now = DateTime.now();
    final map = <ExpenseCategory, double>{};
    for (final t in transactions) {
      if (!t.isIncome && t.date.month == now.month && t.date.year == now.year) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  double budgetFor(ExpenseCategory category) {
    try {
      return budgetItems.firstWhere((b) => b.category == category).budgetAmount;
    } catch (_) {
      return 0;
    }
  }

  double spentFor(ExpenseCategory category) =>
      expensesByCategory[category] ?? 0;

  // ====== גרף חודשי משופר — הכנסות מול הוצאות ======
  List<MonthlyData> get monthlyComparison {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - 5 + i);
      final income = transactions
          .where(
            (t) =>
                t.isIncome &&
                t.date.month == month.month &&
                t.date.year == month.year,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      final expenses = transactions
          .where(
            (t) =>
                !t.isIncome &&
                t.date.month == month.month &&
                t.date.year == month.year,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      return MonthlyData(month: month, income: income, expenses: expenses);
    });
  }

  // לתאימות עם הקוד הקיים
  List<Map<String, dynamic>> get monthlyExpensesChart {
    final months = [
      'ינו',
      'פבר',
      'מרץ',
      'אפר',
      'מאי',
      'יונ',
      'יול',
      'אוג',
      'ספט',
      'אוק',
      'נוב',
      'דצמ',
    ];
    return monthlyComparison
        .map(
          (d) => {
            'month': months[d.month.month - 1],
            'amount': d.expenses,
            'income': d.income,
          },
        )
        .toList();
  }

  // הכנסות לפי מקור
  Map<IncomeSource, double> get incomeBySource {
    final now = DateTime.now();
    final map = <IncomeSource, double>{};
    for (final t in transactions) {
      if (t.isIncome &&
          t.incomeSourceId != null &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        try {
          final source = incomeSources.firstWhere(
            (s) => s.id == t.incomeSourceId,
          );
          map[source] = (map[source] ?? 0) + t.amount;
        } catch (_) {}
      }
    }
    return map;
  }

  // ====== ייצוא CSV ======
  String exportToCSV() {
    final buffer = StringBuffer();
    buffer.writeln('תאריך,כותרת,סכום,סוג,קטגוריה,הערות');
    for (final t in transactions) {
      final date = '${t.date.day}/${t.date.month}/${t.date.year}';
      final type = t.isIncome ? 'הכנסה' : 'הוצאה';
      buffer.writeln(
        '$date,${t.title},${t.amount},$type,${t.category.label},${t.notes ?? ''}',
      );
    }
    return buffer.toString();
  }

  // ====== פעולות מקורות הכנסה ======
  void addIncomeSource(IncomeSource source) {
    incomeSources.add(source);
    _save();
    notifyListeners();
  }

  void updateIncomeSource(IncomeSource updated) {
    final i = incomeSources.indexWhere((s) => s.id == updated.id);
    if (i != -1) {
      incomeSources[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void deleteIncomeSource(String id) {
    incomeSources.removeWhere((s) => s.id == id);
    _save();
    notifyListeners();
  }

  void toggleIncomeSource(String id) {
    final s = incomeSources.firstWhere((s) => s.id == id);
    s.isActive = !s.isActive;
    _save();
    notifyListeners();
  }

  // ====== פעולות תנועות ======
  void addTransaction(Transaction t) {
    transactions.add(t);
    _save();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  void updateTransaction(Transaction updated) {
    final i = transactions.indexWhere((t) => t.id == updated.id);
    if (i != -1) {
      transactions[i] = updated;
      _save();
      notifyListeners();
    }
  }

  void updateBudget(ExpenseCategory category, double amount) {
    final i = budgetItems.indexWhere((b) => b.category == category);
    if (i != -1) {
      budgetItems[i].budgetAmount = amount;
    } else {
      budgetItems.add(BudgetItem(category: category, budgetAmount: amount));
    }
    _save();
    notifyListeners();
  }

  void addSavingGoal(SavingGoal goal) {
    savingGoals.add(goal);
    _save();
    notifyListeners();
  }

  void updateSavingGoal(String id, double amount) {
    final g = savingGoals.firstWhere((g) => g.id == id);
    g.currentAmount += amount;
    _save();
    notifyListeners();
  }

  void deleteSavingGoal(String id) {
    savingGoals.removeWhere((g) => g.id == id);
    _save();
    notifyListeners();
  }

  void addLoan(LoanAccount loan) {
    loans.add(loan);
    _save();
    notifyListeners();
  }

  void updateLoanPayment(String id, double amount) {
    final l = loans.firstWhere((l) => l.id == id);
    l.paidAmount += amount;
    _save();
    notifyListeners();
  }

  void deleteLoan(String id) {
    loans.removeWhere((l) => l.id == id);
    _save();
    notifyListeners();
  }
}
