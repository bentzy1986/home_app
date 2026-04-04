import 'package:flutter/material.dart';
import '../../main.dart';
import 'home_state.dart';
import 'models/home_models.dart';

class HomeDetailsScreen extends StatefulWidget {
  const HomeDetailsScreen({super.key});
  @override
  State<HomeDetailsScreen> createState() => _HomeDetailsScreenState();
}

class _HomeDetailsScreenState extends State<HomeDetailsScreen>
    with SingleTickerProviderStateMixin {
  final HomeState _state = globalHomeState;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatAmount(double amount) =>
      '₪${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final property = _state.currentProperty;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'ניהול הבית',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_home_rounded, color: Colors.white),
            onPressed: _showAddPropertySheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'סקירה'),
            Tab(text: 'תחזוקה'),
            Tab(text: 'חשבונות'),
            Tab(text: 'ניקיון'),
          ],
        ),
      ),
      body: Column(
        children: [
          // בחירת נכס
          if (_state.properties.length > 1)
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _state.properties.asMap().entries.map((entry) {
                    final isSelected = entry.key == _state.currentIndex;
                    return GestureDetector(
                      onTap: () => _state.switchProperty(entry.key),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              entry.value.type.icon,
                              size: 14,
                              color: isSelected
                                  ? entry.value.type.color
                                  : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              entry.value.name,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverview(property),
                _buildMaintenance(property),
                _buildBills(property),
                _buildCleaning(property),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A1A),
        onPressed: _showAddMenu,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ====== טאב סקירה ======
  Widget _buildOverview(Property property) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // כרטיס נכס ראשי
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  property.type.color,
                  property.type.color.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          property.address,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            property.type.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () => _showEditPropertySheet(property),
                    ),
                  ],
                ),
                // פרטי השכרה אם רלוונטי
                if (property.type == PropertyType.rental) ...[
                  const SizedBox(height: 15),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (property.tenantName != null)
                        _rentalChip(Icons.person_rounded, property.tenantName!),
                      if (property.rentalIncome != null)
                        _rentalChip(
                          Icons.payments_rounded,
                          _formatAmount(property.rentalIncome!),
                        ),
                      if (property.leaseEnd != null)
                        _rentalChip(
                          Icons.calendar_today_rounded,
                          'עד ${_formatDate(property.leaseEnd!)}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // סיכום מהיר
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'משימות פתוחות',
                  '${property.openTasks.length}',
                  Icons.handyman_rounded,
                  Colors.orange,
                  () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'חשבונות לתשלום',
                  '${property.unpaidBills.length}',
                  Icons.receipt_long_rounded,
                  Colors.red,
                  () => _tabController.animateTo(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'ניקיון',
                  '${(property.cleaningProgress * 100).toInt()}%',
                  Icons.cleaning_services_rounded,
                  Colors.cyan,
                  () => _tabController.animateTo(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // משימות דחופות
          if (property.openTasks.isNotEmpty) ...[
            _sectionHeader(
              'משימות דחופות',
              Icons.priority_high_rounded,
              Colors.orange,
            ),
            const SizedBox(height: 10),
            ...property.openTasks
                .where(
                  (t) =>
                      t.priority == TaskPriority.urgent ||
                      t.priority == TaskPriority.high,
                )
                .take(3)
                .map((t) => _buildTaskTileCompact(property, t)),
          ],

          const SizedBox(height: 15),

          // בעלי מקצוע
          if (property.providers.isNotEmpty) ...[
            _sectionHeader(
              'בעלי מקצוע',
              Icons.people_alt_rounded,
              Colors.indigo,
            ),
            const SizedBox(height: 10),
            ...property.providers.map((sp) => _buildProviderTile(property, sp)),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _rentalChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTaskTileCompact(Property property, MaintenanceTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: task.type.color.withValues(alpha: 0.15),
          child: Icon(task.type.icon, color: task.type.color, size: 16),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: task.priority.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            task.priority.label,
            style: TextStyle(
              color: task.priority.color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _tabController.animateTo(1),
      ),
    );
  }

  Widget _buildProviderTile(Property property, ServiceProvider sp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4A00E0).withValues(alpha: 0.1),
          child: Text(
            sp.name[0],
            style: const TextStyle(
              color: Color(0xFF4A00E0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          sp.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(sp.profession),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sp.rating != null) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              Text(sp.rating!.toString(), style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
            ],
            IconButton(
              icon: const Icon(
                Icons.phone_rounded,
                color: Colors.green,
                size: 20,
              ),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('עריכה')),
                const PopupMenuItem(value: 'delete', child: Text('מחיקה')),
              ],
              onSelected: (val) {
                if (val == 'edit') {
                  _showEditProviderSheet(property, sp);
                }
                if (val == 'delete') {
                  _state.deleteProvider(property.id, sp.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ====== טאב תחזוקה ======
  Widget _buildMaintenance(Property property) {
    final open = property.tasks.where((t) => !t.isDone).toList()
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
    final done = property.tasks.where((t) => t.isDone).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${open.length} משימות פתוחות',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => _showAddTaskSheet(property),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('הוסף משימה'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (open.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.center,
            child: const Column(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
                SizedBox(height: 10),
                Text(
                  'אין משימות פתוחות! 🎉',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ...open.map((t) => _buildTaskTileFull(property, t)),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'הושלמו',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          ...done.map((t) => _buildTaskTileFull(property, t)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTaskTileFull(Property property, MaintenanceTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task.isDone
              ? Colors.grey.withValues(alpha: 0.1)
              : task.type.color.withValues(alpha: 0.15),
          child: Icon(
            task.type.icon,
            color: task.isDone ? Colors.grey : task.type.color,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: task.priority.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.priority.label,
                style: TextStyle(
                  color: task.priority.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              task.type.label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isDone,
              onChanged: (_) => _state.toggleTask(property.id, task.id),
              activeColor: Colors.green,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: 18,
              ),
              onPressed: () => _state.deleteTask(property.id, task.id),
            ),
          ],
        ),
      ),
    );
  }

  // ====== טאב חשבונות ======
  Widget _buildBills(Property property) {
    final unpaid = property.bills.where((b) => !b.isPaid).toList();
    final paid = property.bills.where((b) => b.isPaid).toList();
    final total = property.totalBills;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // כרטיס סיכום
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
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
                    'סה"כ החודש',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _formatAmount(total),
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
                  Text(
                    '${unpaid.length} לא שולמו',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _formatAmount(unpaid.fold(0, (s, b) => s + b.amount)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'חשבונות',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => _showAddBillSheet(property),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('הוסף'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (unpaid.isNotEmpty) ...[
          const Text(
            'לתשלום',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...unpaid.map((b) => _buildBillTile(property, b)),
          const SizedBox(height: 10),
        ],
        if (paid.isNotEmpty) ...[
          const Text(
            'שולמו',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...paid.map((b) => _buildBillTile(property, b)),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildBillTile(Property property, Bill bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _state.toggleBill(property.id, bill.id),
          child: CircleAvatar(
            backgroundColor: bill.isPaid
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            child: Icon(
              bill.isPaid
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: bill.isPaid ? Colors.green : Colors.red,
              size: 22,
            ),
          ),
        ),
        title: Text(
          bill.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
            color: bill.isPaid ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: bill.dueDay != null
            ? Text(
                'לתשלום ב-${bill.dueDay} לחודש',
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatAmount(bill.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: bill.isPaid ? Colors.grey : Colors.black,
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('עריכה')),
                const PopupMenuItem(value: 'delete', child: Text('מחיקה')),
              ],
              onSelected: (val) {
                if (val == 'edit') {
                  _showEditBillSheet(property, bill);
                }
                if (val == 'delete') {
                  _state.deleteBill(property.id, bill.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ====== טאב ניקיון ======
  Widget _buildCleaning(Property property) {
    final progress = property.cleaningProgress;
    final done = property.cleaningDone;
    final total = property.cleaningTasks.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // כרטיס התקדמות
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}% הושלם',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.cyan,
                    ),
                  ),
                  Text(
                    '$done מתוך $total',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'משימות ניקיון',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => _state.resetCleaning(property.id),
                  child: const Text(
                    'איפוס',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddCleaningTaskSheet(property),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('הוסף'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (property.cleaningTasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'אין משימות ניקיון',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...property.cleaningTasks.map(
            (task) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: CheckboxListTile(
                activeColor: Colors.cyan,
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? Colors.grey : Colors.black87,
                  ),
                ),
                value: task.isDone,
                onChanged: (_) => _state.toggleCleaning(property.id, task.id),
                secondary: Icon(
                  task.icon,
                  color: task.isDone ? Colors.grey : Colors.cyan,
                ),
              ),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ====== דיאלוגים ======

  void _showAddMenu() {
    final property = _state.currentProperty;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'מה להוסיף?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _addOption(
              Icons.handyman_rounded,
              'משימת תחזוקה',
              Colors.orange,
              () {
                Navigator.pop(context);
                _showAddTaskSheet(property);
              },
            ),
            const SizedBox(height: 10),
            _addOption(Icons.receipt_long_rounded, 'חשבון', Colors.blue, () {
              Navigator.pop(context);
              _showAddBillSheet(property);
            }),
            const SizedBox(height: 10),
            _addOption(
              Icons.people_alt_rounded,
              'בעל מקצוע',
              Colors.indigo,
              () {
                Navigator.pop(context);
                _showAddProviderSheet(property);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _addOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPropertySheet() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    PropertyType selectedType = PropertyType.owned;
    final tenantController = TextEditingController();
    final incomeController = TextEditingController();
    DateTime? leaseEnd;

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
                  'נכס חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם הנכס',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'כתובת',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'סוג נכס:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PropertyType.values.map((t) {
                    final isSelected = selectedType == t;
                    return ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedType = t),
                      selectedColor: t.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                if (selectedType == PropertyType.rental) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: tenantController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'שם השוכר',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: incomeController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'הכנסה חודשית (₪)',
                      border: OutlineInputBorder(),
                    ),
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
                        setModal(() => leaseEnd = picked);
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
                            leaseEnd != null
                                ? 'חוזה עד ${_formatDate(leaseEnd!)}'
                                : 'תאריך סיום חוזה',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: leaseEnd != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
                      if (nameController.text.isEmpty ||
                          addressController.text.isEmpty)
                        return;
                      _state.addProperty(
                        Property(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          address: addressController.text,
                          type: selectedType,
                          tenantName: tenantController.text.isEmpty
                              ? null
                              : tenantController.text,
                          rentalIncome: double.tryParse(incomeController.text),
                          leaseEnd: leaseEnd,
                          tasks: [],
                          bills: [],
                          providers: [],
                          cleaningTasks: [],
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף נכס',
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

  void _showEditPropertySheet(Property property) {
    final nameController = TextEditingController(text: property.name);
    final addressController = TextEditingController(text: property.address);
    PropertyType selectedType = property.type;
    final tenantController = TextEditingController(
      text: property.tenantName ?? '',
    );
    final incomeController = TextEditingController(
      text: property.rentalIncome?.toStringAsFixed(0) ?? '',
    );
    DateTime? leaseEnd = property.leaseEnd;

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
                  'עריכת נכס',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם הנכס',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'כתובת',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PropertyType.values.map((t) {
                    final isSelected = selectedType == t;
                    return ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedType = t),
                      selectedColor: t.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                if (selectedType == PropertyType.rental) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: tenantController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'שם השוכר',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: incomeController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'הכנסה חודשית (₪)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          _state.deleteProperty(property.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'מחק נכס',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          property.name = nameController.text;
                          property.address = addressController.text;
                          property.type = selectedType;
                          property.tenantName = tenantController.text.isEmpty
                              ? null
                              : tenantController.text;
                          property.rentalIncome = double.tryParse(
                            incomeController.text,
                          );
                          property.leaseEnd = leaseEnd;
                          _state.updateProperty(property);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'שמור',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskSheet(Property property) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    final contractorController = TextEditingController();
    MaintenanceType selectedType = MaintenanceType.plumbing;
    TaskPriority selectedPriority = TaskPriority.medium;

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
                  'משימה חדשה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'סוג:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MaintenanceType.values.map((t) {
                    final isSelected = selectedType == t;
                    return ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedType = t),
                      selectedColor: t.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'עדיפות:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskPriority.values.map((p) {
                    final isSelected = selectedPriority == p;
                    return ChoiceChip(
                      label: Text(p.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedPriority = p),
                      selectedColor: p.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'תיאור המשימה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contractorController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'בעל מקצוע (אופציונלי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'הערות (אופציונלי)',
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
                      if (titleController.text.isEmpty) return;
                      _state.addTask(
                        property.id,
                        MaintenanceTask(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          type: selectedType,
                          priority: selectedPriority,
                          createdAt: DateTime.now(),
                          contractor: contractorController.text.isEmpty
                              ? null
                              : contractorController.text,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף משימה',
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

  void _showAddBillSheet(Property property) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dueDayController = TextEditingController();

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
                'חשבון חדש',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'שם החשבון',
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
              TextField(
                controller: dueDayController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'יום תשלום בחודש (אופציונלי)',
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
                        amountController.text.isEmpty)
                      return;
                    _state.addBill(
                      property.id,
                      Bill(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        dueDay: dueDayController.text.isEmpty
                            ? null
                            : dueDayController.text,
                        date: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'הוסף חשבון',
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

  void _showEditBillSheet(Property property, Bill bill) {
    final titleController = TextEditingController(text: bill.title);
    final amountController = TextEditingController(
      text: bill.amount.toStringAsFixed(0),
    );
    final dueDayController = TextEditingController(text: bill.dueDay ?? '');

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
                'עריכת חשבון',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'שם החשבון',
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
              TextField(
                controller: dueDayController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'יום תשלום בחודש',
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
                    _state.updateBill(
                      property.id,
                      Bill(
                        id: bill.id,
                        title: titleController.text,
                        amount: double.tryParse(amountController.text) ?? 0,
                        dueDay: dueDayController.text.isEmpty
                            ? null
                            : dueDayController.text,
                        isPaid: bill.isPaid,
                        date: bill.date,
                      ),
                    );
                    Navigator.pop(context);
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
    );
  }

  void _showAddProviderSheet(Property property) {
    final nameController = TextEditingController();
    final professionController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    double rating = 5.0;

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
                  'בעל מקצוע חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: professionController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מקצוע',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'טלפון',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'הערות (אופציונלי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'דירוג:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () =>
                              setModal(() => rating = (i + 1).toDouble()),
                          child: Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 30,
                          ),
                        );
                      }),
                    ),
                  ],
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
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty)
                        return;
                      _state.addProvider(
                        property.id,
                        ServiceProvider(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          profession: professionController.text,
                          phone: phoneController.text,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                          rating: rating,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף',
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

  void _showEditProviderSheet(Property property, ServiceProvider sp) {
    final nameController = TextEditingController(text: sp.name);
    final professionController = TextEditingController(text: sp.profession);
    final phoneController = TextEditingController(text: sp.phone);
    final notesController = TextEditingController(text: sp.notes ?? '');
    double rating = sp.rating ?? 5.0;

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
                  'עריכת בעל מקצוע',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: professionController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מקצוע',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'טלפון',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'הערות',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'דירוג:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () =>
                              setModal(() => rating = (i + 1).toDouble()),
                          child: Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 30,
                          ),
                        );
                      }),
                    ),
                  ],
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
                      _state.updateProvider(
                        property.id,
                        ServiceProvider(
                          id: sp.id,
                          name: nameController.text,
                          profession: professionController.text,
                          phone: phoneController.text,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                          rating: rating,
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

  void _showAddCleaningTaskSheet(Property property) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('משימת ניקיון חדשה', textAlign: TextAlign.right),
        content: TextField(
          controller: titleController,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'שם המשימה',
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
              if (titleController.text.isEmpty) return;
              _state.addCleaningTask(
                property.id,
                CleaningTask(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  icon: Icons.cleaning_services_rounded,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('הוסף', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
