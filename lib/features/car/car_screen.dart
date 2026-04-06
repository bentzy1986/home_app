import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import 'car_state.dart';
import 'models/car_models.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});
  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen>
    with SingleTickerProviderStateMixin {
  final CarState _state = globalCarState;
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatAmount(double amount) =>
      '₪${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _formatMileage(int km) =>
      '${km.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ק"מ';

  @override
  Widget build(BuildContext context) {
    final car = _state.currentCar;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'ניהול רכבים',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _showAddCarSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'סקירה'),
            Tab(text: 'טיפולים'),
            Tab(text: 'תזכורות'),
            Tab(text: 'הוצאות'),
            Tab(text: 'מסמכים'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_state.cars.length > 1)
            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _state.cars.asMap().entries.map((entry) {
                    final isSelected = entry.key == _state.currentIndex;
                    return GestureDetector(
                      onTap: () => _state.switchCar(entry.key),
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
                        child: Text(
                          entry.value.nickname,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF1A1A1A)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
                _buildOverview(car),
                _buildServiceHistory(car),
                _buildReminders(car),
                _buildExpenses(car),
                _buildAttachments(car),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A1A),
        onPressed: () => _showAddServiceRecordSheet(car),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ====== טאב סקירה ======
  Widget _buildOverview(CarModel car) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF3A3A3A)],
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
                          car.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (car.brand != null)
                          Text(
                            '${car.brand} ${car.model ?? ''} ${car.year ?? ''}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () => _showEditCarSheet(car),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _showEditCarSheet(car),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Text(
                      car.plate,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _carInfoChip(
                      car.fuelType.icon,
                      car.fuelType.label,
                      car.fuelType.color,
                    ),
                    if (car.currentMileage != null)
                      _carInfoChip(
                        Icons.speed_rounded,
                        _formatMileage(car.currentMileage!),
                        Colors.white70,
                      ),
                    GestureDetector(
                      onTap: () => _showUpdateMileageDialog(car),
                      child: _carInfoChip(
                        Icons.edit_rounded,
                        'עדכן ק"מ',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (car.urgentDocuments.isNotEmpty || car.activeReminders.isNotEmpty)
            _buildAlertsCard(car),
          const SizedBox(height: 15),
          _buildDocumentsCard(car),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _carInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(CarModel car) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEB3349), Color(0xFFF45C43)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'דורש תשומת לב',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...car.urgentDocuments.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(d.icon, color: Colors.white70, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    d.isExpired
                        ? '${d.title} — פג תוקף!'
                        : '${d.title} — נשארו ${d.daysLeft} ימים',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          ...car.activeReminders
              .where((r) => r.isUrgent || r.isOverdue)
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(r.type.icon, color: Colors.white70, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        r.isOverdue
                            ? '${r.title} — באיחור!'
                            : '${r.title} — בעוד ${r.daysLeft} ימים',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(CarModel car) {
    return Container(
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
            'מסמכים ותאריכים',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 15),
          ...car.documents.map((doc) {
            final isExpired = doc.isExpired;
            final isUrgent = doc.isUrgent;
            return GestureDetector(
              onTap: () => _showEditDocumentDialog(car, doc),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.red.withValues(alpha: 0.05)
                      : isUrgent
                      ? Colors.orange.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpired
                        ? Colors.red.withValues(alpha: 0.3)
                        : isUrgent
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: doc.color.withValues(alpha: 0.15),
                      child: Icon(doc.icon, color: doc.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'עד ${_formatDate(doc.expiryDate)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? Colors.red
                            : isUrgent
                            ? Colors.orange
                            : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExpired
                            ? 'פג תוקף'
                            : isUrgent
                            ? '${doc.daysLeft} ימים'
                            : 'תקין',
                        style: const TextStyle(
                          color: Colors.white,
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
        ],
      ),
    );
  }

  // ====== טאב היסטוריית טיפולים ======
  Widget _buildServiceHistory(CarModel car) {
    return car.serviceHistory.isEmpty
        ? const Center(
            child: Text(
              'אין היסטוריית טיפולים',
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: car.serviceHistory.length,
            itemBuilder: (context, index) {
              final record = car.serviceHistory[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: record.type.color.withValues(alpha: 0.15),
                    child: Icon(
                      record.type.icon,
                      color: record.type.color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    record.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(record.date),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (record.garage != null)
                        Text(
                          record.garage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (record.mileage != null)
                        Text(
                          _formatMileage(record.mileage!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatAmount(record.cost),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF11998E),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            _state.deleteServiceRecord(car.id, record.id),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
  }

  // ====== טאב תזכורות ======
  Widget _buildReminders(CarModel car) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'תזכורות טיפול',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton.icon(
              onPressed: () => _showAddReminderSheet(car),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('הוסף'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (car.reminders.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('אין תזכורות', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...car.reminders.map((r) {
            final isOverdue = r.isOverdue;
            final isUrgent = r.isUrgent;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: r.isDone
                      ? Colors.grey.withValues(alpha: 0.15)
                      : r.type.color.withValues(alpha: 0.15),
                  child: Icon(
                    r.type.icon,
                    color: r.isDone ? Colors.grey : r.type.color,
                    size: 20,
                  ),
                ),
                title: Text(
                  r.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: r.isDone ? TextDecoration.lineThrough : null,
                    color: r.isDone ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'תאריך יעד: ${_formatDate(r.dueDate)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (r.dueMileage != null)
                      Text(
                        'ק"מ יעד: ${_formatMileage(r.dueMileage!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!r.isDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? Colors.red
                              : isUrgent
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isOverdue
                              ? 'באיחור'
                              : isUrgent
                              ? '${r.daysLeft} יום'
                              : 'תקין',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Checkbox(
                      value: r.isDone,
                      onChanged: (_) => _state.toggleReminder(car.id, r.id),
                      activeColor: Colors.green,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                        size: 18,
                      ),
                      onPressed: () => _state.deleteReminder(car.id, r.id),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          }),
        const SizedBox(height: 80),
      ],
    );
  }

  // ====== טאב הוצאות ======
  Widget _buildExpenses(CarModel car) {
    final byType = <ServiceType, double>{};
    for (final s in car.serviceHistory) {
      byType[s.type] = (byType[s.type] ?? 0) + s.cost;
    }
    final sortedTypes = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _expenseSummaryItem(
                  'הוצאות השנה',
                  _formatAmount(car.yearlyExpenses),
                  Colors.white,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _expenseSummaryItem(
                  'סה"כ כל הזמן',
                  _formatAmount(car.totalExpenses),
                  Colors.white70,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (sortedTypes.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'הוצאות לפי קטגוריה',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            ...sortedTypes.map((entry) {
              final ratio = car.totalExpenses > 0
                  ? entry.value / car.totalExpenses
                  : 0.0;
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          _formatAmount(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        color: entry.key.color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _expenseSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ====== דיאלוגים ======

  void _showAddCarSheet() {
    final nicknameController = TextEditingController();
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final mileageController = TextEditingController();
    FuelType selectedFuel = FuelType.petrol95;

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
                  'רכב חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nicknameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'כינוי (לדוגמה: הרכב המשפחתי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: plateController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מספר רישוי',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: brandController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'יצרן',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: modelController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'דגם',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'שנה',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: mileageController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ק"מ נוכחי',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'סוג דלק:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FuelType.values.map((f) {
                    final isSelected = selectedFuel == f;
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedFuel = f),
                      selectedColor: f.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
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
                      if (nicknameController.text.isEmpty ||
                          plateController.text.isEmpty)
                        return;
                      _state.addCar(
                        CarModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          nickname: nicknameController.text,
                          plate: plateController.text,
                          brand: brandController.text.isEmpty
                              ? null
                              : brandController.text,
                          model: modelController.text.isEmpty
                              ? null
                              : modelController.text,
                          year: int.tryParse(yearController.text),
                          fuelType: selectedFuel,
                          currentMileage: int.tryParse(mileageController.text),
                          documents: [],
                          serviceHistory: [],
                          reminders: [],
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף רכב',
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

  void _showEditCarSheet(CarModel car) {
    final nicknameController = TextEditingController(text: car.nickname);
    final plateController = TextEditingController(text: car.plate);
    final brandController = TextEditingController(text: car.brand ?? '');
    final modelController = TextEditingController(text: car.model ?? '');
    final yearController = TextEditingController(
      text: car.year?.toString() ?? '',
    );
    final mileageController = TextEditingController(
      text: car.currentMileage?.toString() ?? '',
    );
    FuelType selectedFuel = car.fuelType;

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
                  'עריכת רכב',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nicknameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'כינוי',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: plateController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מספר רישוי',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: brandController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'יצרן',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: modelController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'דגם',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'שנה',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: mileageController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ק"מ נוכחי',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'סוג דלק:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FuelType.values.map((f) {
                    final isSelected = selectedFuel == f;
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedFuel = f),
                      selectedColor: f.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
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
                          _state.deleteCar(car.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'מחק רכב',
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
                          car.nickname = nicknameController.text;
                          car.plate = plateController.text;
                          car.brand = brandController.text.isEmpty
                              ? null
                              : brandController.text;
                          car.model = modelController.text.isEmpty
                              ? null
                              : modelController.text;
                          car.year = int.tryParse(yearController.text);
                          car.currentMileage = int.tryParse(
                            mileageController.text,
                          );
                          car.fuelType = selectedFuel;
                          _state.updateCar(car);
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

  void _showAddServiceRecordSheet(CarModel car) {
    final titleController = TextEditingController();
    final costController = TextEditingController();
    final garageController = TextEditingController();
    final mileageController = TextEditingController(
      text: car.currentMileage?.toString() ?? '',
    );
    ServiceType selectedType = ServiceType.oilChange;
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
                  'טיפול / הוצאה חדשה',
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
                  children: ServiceType.values.map((t) {
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
                TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'תיאור',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'עלות (₪)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: mileageController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ק"מ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: garageController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מוסך / ספק (אופציונלי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2035),
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
                      if (titleController.text.isEmpty) return;
                      _state.addServiceRecord(
                        car.id,
                        ServiceRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          type: selectedType,
                          date: selectedDate,
                          cost: double.tryParse(costController.text) ?? 0,
                          mileage: int.tryParse(mileageController.text),
                          garage: garageController.text.isEmpty
                              ? null
                              : garageController.text,
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

  void _showAddReminderSheet(CarModel car) {
    final titleController = TextEditingController();
    final mileageController = TextEditingController();
    ServiceType selectedType = ServiceType.oilChange;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

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
                  'תזכורת חדשה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ServiceType.values.map((t) {
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
                  controller: mileageController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ק"מ יעד (אופציונלי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
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
                      if (titleController.text.isEmpty) return;
                      _state.addReminder(
                        car.id,
                        ServiceReminder(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          type: selectedType,
                          dueDate: selectedDate,
                          dueMileage: int.tryParse(mileageController.text),
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף תזכורת',
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

  void _showEditDocumentDialog(CarModel car, CarDocument doc) {
    DateTime selectedDate = doc.expiryDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('עדכן תאריך — ${doc.title}', textAlign: TextAlign.right),
          content: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime(2035),
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
                _state.updateDocument(
                  car.id,
                  CarDocument(
                    id: doc.id,
                    title: doc.title,
                    expiryDate: selectedDate,
                    icon: doc.icon,
                    color: doc.color,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('שמור', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateMileageDialog(CarModel car) {
    final controller = TextEditingController(
      text: car.currentMileage?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('עדכון קילומטראז\'', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'ק"מ נוכחי',
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
              final km = int.tryParse(controller.text);
              if (km != null) {
                _state.updateMileage(car.id, km);
              }
              Navigator.pop(ctx);
            },
            child: const Text('שמור', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ====== טאב מסמכים ======
  Widget _buildAttachments(CarModel car) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${car.attachments.length} קבצים',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextButton.icon(
              onPressed: () => _showAddAttachmentSheet(car),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('הוסף'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (car.attachments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 60,
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'אין מסמכים או תמונות',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'הוסף חשבוניות, אסמכתאות וצילומים',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...car.attachments.map((a) => _buildAttachmentTile(car, a)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildAttachmentTile(CarModel car, CarAttachment attachment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: attachment.isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(attachment.filePath),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
        title: Text(
          attachment.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${attachment.createdAt.day}/${attachment.createdAt.month}/${attachment.createdAt.year}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
                size: 20,
              ),
              onPressed: () async {
                try {
                  final file = File(attachment.filePath);
                  if (!await file.exists()) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('הקובץ לא נמצא'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    return;
                  }
                  await Share.shareXFiles([
                    XFile(attachment.filePath),
                  ], subject: attachment.title);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('שגיאה בשיתוף: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () => _state.deleteAttachment(car.id, attachment.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAttachmentSheet(CarModel car) {
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
              'הוסף מסמך או תמונה',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _attachmentOption(
              Icons.camera_alt_rounded,
              'צלם תמונה',
              Colors.blue,
              () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null && mounted) {
                  _showNameAttachmentDialog(car, image.path, true);
                }
              },
            ),
            const SizedBox(height: 10),
            _attachmentOption(
              Icons.photo_library_rounded,
              'בחר מהגלריה',
              Colors.purple,
              () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null && mounted) {
                  _showNameAttachmentDialog(car, image.path, true);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNameAttachmentDialog(CarModel car, String filePath, bool isImage) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('שם המסמך', textAlign: TextAlign.right),
        content: TextField(
          controller: titleController,
          textAlign: TextAlign.right,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'לדוגמה: חשבונית טיפול',
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
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              Navigator.pop(ctx);

              // שמירה לתיקייה קבועה
              final appDir = await getApplicationDocumentsDirectory();
              final fileName =
                  '${DateTime.now().millisecondsSinceEpoch}_${titleController.text.replaceAll(' ', '_')}${isImage ? '.jpg' : '.pdf'}';
              final savedPath = '${appDir.path}/$fileName';
              await File(filePath).copy(savedPath);

              _state.addAttachment(
                car.id,
                CarAttachment(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  filePath: savedPath,
                  isImage: isImage,
                  createdAt: DateTime.now(),
                ),
              );
            },
            child: const Text('שמור', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _attachmentOption(
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
}
