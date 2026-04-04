import 'package:flutter/material.dart';
import '../../main.dart';
import 'finance_state.dart';
import 'models/finance_models.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  final FinanceState _state = globalFinanceState;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _state.addListener(_onStateChange);
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChange);
    _tabController.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) =>
      '₪${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'פיננסים',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          isScrollable: true,
          tabs: const [
            Tab(text: 'דשבורד'),
            Tab(text: 'תנועות'),
            Tab(text: 'תקציב'),
            Tab(text: 'חיסכון'),
            Tab(text: 'הלוואות'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(),
          _buildTransactions(),
          _buildBudget(),
          _buildSavings(),
          _buildLoans(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A1A),
        onPressed: _showAddTransactionSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ====== דשבורד ======
  Widget _buildDashboard() {
    final chartData = _state.monthlyExpensesChart;
    final maxAmount = chartData.isEmpty
        ? 1.0
        : chartData
              .map((e) => e['amount'] as double)
              .reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const Text(
                  'יתרה החודש',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatAmount(_state.balance),
                  style: TextStyle(
                    color: _state.balance >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _dashboardMiniCard(
                      'הכנסות',
                      _state.monthlyIncome,
                      Colors.greenAccent,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _dashboardMiniCard(
                      'הוצאות',
                      _state.monthlyExpenses,
                      Colors.redAccent,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _dashboardMiniCard(
                      'תקציב',
                      _state.totalBudget,
                      Colors.blueAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'הוצאות — 6 חודשים אחרונים',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: chartData.map((data) {
                      final amount = data['amount'] as double;
                      final ratio = maxAmount > 0 ? amount / maxAmount : 0.0;
                      final isCurrentMonth = data == chartData.last;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (amount > 0)
                            Text(
                              '₪${(amount / 1000).toStringAsFixed(1)}K',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 32,
                            height: (ratio * 80).clamp(4, 80),
                            decoration: BoxDecoration(
                              color: isCurrentMonth
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(
                                      0xFF1A1A1A,
                                    ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['month'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isCurrentMonth
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.grey,
                              fontWeight: isCurrentMonth
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'הוצאות לפי קטגוריה',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 15),
                ..._state.expensesByCategory.entries.map((entry) {
                  final budget = _state.budgetFor(entry.key);
                  final spent = entry.value;
                  final ratio = budget > 0
                      ? (spent / budget).clamp(0.0, 1.0)
                      : 0.0;
                  final isOver = spent > budget && budget > 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: entry.key.color.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                entry.key.icon,
                                color: entry.key.color,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.key.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${_formatAmount(spent)} / ${_formatAmount(budget)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOver ? Colors.red : Colors.grey,
                                fontWeight: isOver
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: Colors.grey.withValues(
                              alpha: 0.15,
                            ),
                            color: isOver ? Colors.red : entry.key.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _dashboardMiniCard(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ====== תנועות ======
  Widget _buildTransactions() {
    final transactions = _state.thisMonthTransactions;
    return transactions.isEmpty
        ? const Center(
            child: Text(
              'אין תנועות החודש',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${transactions.length} תנועות החודש',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatAmount(_state.balance),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _state.balance >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final t = transactions[index - 1];
              return _buildTransactionTile(t);
            },
          );
  }

  Widget _buildTransactionTile(Transaction t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: t.category.color.withValues(alpha: 0.15),
          child: Icon(t.category.icon, color: t.category.color, size: 20),
        ),
        title: Text(
          t.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${t.category.label} • ${_formatDate(t.date)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${t.isIncome ? '+' : '-'}${_formatAmount(t.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: t.isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('עריכה')),
                const PopupMenuItem(value: 'delete', child: Text('מחיקה')),
              ],
              onSelected: (val) {
                if (val == 'edit') {
                  _showEditTransactionSheet(t);
                }
                if (val == 'delete') {
                  _state.deleteTransaction(t.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ====== תקציב ======
  Widget _buildBudget() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'תקציב חודשי כולל',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _formatAmount(_state.totalBudget),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'הוצאה בפועל',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _formatAmount(_state.monthlyExpenses),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'תקציב לפי קטגוריה',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ..._state.budgetItems.map((item) {
          final spent = _state.spentFor(item.category);
          final ratio = item.budgetAmount > 0
              ? (spent / item.budgetAmount).clamp(0.0, 1.0)
              : 0.0;
          final isOver = spent > item.budgetAmount;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: item.category.color.withValues(
                          alpha: 0.15,
                        ),
                        child: Icon(
                          item.category.icon,
                          color: item.category.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.category.label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () => _showEditBudgetDialog(item),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'בפועל: ${_formatAmount(spent)}',
                        style: TextStyle(
                          color: isOver ? Colors.red : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isOver
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        'תקציב: ${_formatAmount(item.budgetAmount)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      color: isOver ? Colors.red : item.category.color,
                    ),
                  ),
                  if (isOver)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'חריגה של ${_formatAmount(spent - item.budgetAmount)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  // ====== חיסכון ======
  Widget _buildSavings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'יעדי חיסכון',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton.icon(
              onPressed: _showAddSavingGoalSheet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('הוסף יעד'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_state.savingGoals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'אין יעדי חיסכון עדיין',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._state.savingGoals.map((goal) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: goal.color,
                          child: Text(
                            goal.title[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (goal.daysLeft != null)
                                Text(
                                  '${goal.daysLeft} ימים נותרו',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'add',
                              child: Text('הוסף סכום'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('מחיקה'),
                            ),
                          ],
                          onSelected: (val) {
                            if (val == 'add') {
                              _showAddToSavingDialog(goal);
                            }
                            if (val == 'delete') {
                              _state.deleteSavingGoal(goal.id);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatAmount(goal.currentAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: goal.color,
                          ),
                        ),
                        Text(
                          'מתוך ${_formatAmount(goal.targetAmount)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        color: goal.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}% הושלם',
                      style: TextStyle(
                        color: goal.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 80),
      ],
    );
  }

  // ====== הלוואות ======
  Widget _buildLoans() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'הלוואות',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton.icon(
              onPressed: _showAddLoanSheet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('הוסף הלוואה'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_state.loans.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'אין הלוואות פעילות',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ..._state.loans.map((loan) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFEB3349),
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            loan.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'pay',
                              child: Text('תשלום'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('מחיקה'),
                            ),
                          ],
                          onSelected: (val) {
                            if (val == 'pay') {
                              _showLoanPaymentDialog(loan);
                            }
                            if (val == 'delete') {
                              _state.deleteLoan(loan.id);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'נותר לתשלום',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatAmount(loan.remainingAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFFEB3349),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'תשלום חודשי',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatAmount(loan.monthlyPayment),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: loan.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        color: const Color(0xFF11998E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(loan.progress * 100).toStringAsFixed(0)}% שולם — ${_formatAmount(loan.totalAmount)} סה"כ',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 80),
      ],
    );
  }

  // ====== דיאלוגים ======

  void _showAddTransactionSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    ExpenseCategory selectedCategory = ExpenseCategory.food;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'תנועה חדשה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('הוצאה'),
                    Switch(
                      value: isIncome,
                      activeThumbColor: Colors.green,
                      onChanged: (v) => setModal(() {
                        isIncome = v;
                        selectedCategory = v
                            ? ExpenseCategory.income
                            : ExpenseCategory.food;
                      }),
                    ),
                    const Text('הכנסה'),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'תיאור',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'סכום (₪)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                if (!isIncome)
                  DropdownButtonFormField<ExpenseCategory>(
                    decoration: const InputDecoration(
                      labelText: 'קטגוריה',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedCategory,
                    items: ExpenseCategory.values
                        .where((c) => c != ExpenseCategory.income)
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(c.icon, color: c.color, size: 18),
                                const SizedBox(width: 8),
                                Text(c.label),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setModal(() => selectedCategory = v!),
                  ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setModal(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        Text(
                          _formatDate(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty)
                        return;
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount <= 0) return;
                      _state.addTransaction(
                        Transaction(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          amount: amount,
                          isIncome: isIncome,
                          category: isIncome
                              ? ExpenseCategory.income
                              : selectedCategory,
                          date: selectedDate,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'שמור',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditTransactionSheet(Transaction t) {
    final titleController = TextEditingController(text: t.title);
    final amountController = TextEditingController(
      text: t.amount.toStringAsFixed(0),
    );
    bool isIncome = t.isIncome;
    ExpenseCategory selectedCategory = t.category;
    DateTime selectedDate = t.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'עריכת תנועה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'תיאור',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'סכום (₪)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                if (!isIncome)
                  DropdownButtonFormField<ExpenseCategory>(
                    decoration: const InputDecoration(
                      labelText: 'קטגוריה',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedCategory == ExpenseCategory.income
                        ? ExpenseCategory.food
                        : selectedCategory,
                    items: ExpenseCategory.values
                        .where((c) => c != ExpenseCategory.income)
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(c.icon, color: c.color, size: 18),
                                const SizedBox(width: 8),
                                Text(c.label),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setModal(() => selectedCategory = v!),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          amountController.text.isEmpty)
                        return;
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      _state.updateTransaction(
                        Transaction(
                          id: t.id,
                          title: titleController.text,
                          amount: amount,
                          isIncome: isIncome,
                          category: selectedCategory,
                          date: selectedDate,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'שמור שינויים',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BudgetItem item) {
    final controller = TextEditingController(
      text: item.budgetAmount.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'תקציב — ${item.category.label}',
          textAlign: TextAlign.right,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'סכום תקציב (₪)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
            ),
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              _state.updateBudget(item.category, amount);
              Navigator.pop(ctx);
            },
            child: const Text('שמור', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSavingGoalSheet() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController(text: '0');
    DateTime? targetDate;
    Color selectedColor = const Color(0xFF2193B0);

    final colors = [
      const Color(0xFF2193B0),
      const Color(0xFF11998E),
      const Color(0xFF4A00E0),
      const Color(0xFFEB3349),
      const Color(0xFFF7971E),
      const Color(0xFF607D8B),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'יעד חיסכון חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם היעד',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: targetController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'סכום יעד (₪)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: currentController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'סכום קיים (₪)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'צבע:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: colors
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setModal(() => selectedColor = c),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: selectedColor == c
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                            ),
                            child: selectedColor == c
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setModal(() => targetDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        Text(
                          targetDate != null
                              ? _formatDate(targetDate!)
                              : 'תאריך יעד (אופציונלי)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: targetDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          targetController.text.isEmpty)
                        return;
                      _state.addSavingGoal(
                        SavingGoal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          targetAmount:
                              double.tryParse(targetController.text) ?? 0,
                          currentAmount:
                              double.tryParse(currentController.text) ?? 0,
                          targetDate: targetDate,
                          color: selectedColor,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף יעד',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddToSavingDialog(SavingGoal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('הוסף לחיסכון — ${goal.title}', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'סכום להוספה (₪)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
            ),
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                _state.updateSavingGoal(goal.id, amount);
              }
              Navigator.pop(ctx);
            },
            child: const Text('הוסף', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddLoanSheet() {
    final titleController = TextEditingController();
    final totalController = TextEditingController();
    final paidController = TextEditingController(text: '0');
    final monthlyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 25,
          right: 25,
          top: 25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'הלוואה חדשה',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'שם ההלוואה',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: totalController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'סכום כולל (₪)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: paidController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'כבר שולם (₪)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: monthlyController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'תשלום חודשי (₪)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        totalController.text.isEmpty)
                      return;
                    _state.addLoan(
                      LoanAccount(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        totalAmount: double.tryParse(totalController.text) ?? 0,
                        paidAmount: double.tryParse(paidController.text) ?? 0,
                        monthlyPayment:
                            double.tryParse(monthlyController.text) ?? 0,
                        startDate: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'הוסף הלוואה',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoanPaymentDialog(LoanAccount loan) {
    final controller = TextEditingController(
      text: loan.monthlyPayment.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('תשלום — ${loan.title}', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'סכום תשלום (₪)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
            ),
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                _state.updateLoanPayment(loan.id, amount);
              }
              Navigator.pop(ctx);
            },
            child: const Text('שמור', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
