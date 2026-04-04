import 'package:flutter/material.dart';
import '../../main.dart';
import 'health_state.dart';
import 'models/health_models.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen>
    with SingleTickerProviderStateMixin {
  final HealthState _state = globalHealthState;
  late TabController _tabController;
  String? _selectedMemberId;

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

  String _formatDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEB3349),
        elevation: 0,
        title: const Text(
          'בריאות',
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
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'סקירה'),
            Tab(text: 'תורים'),
            Tab(text: 'תרופות'),
            Tab(text: 'בדיקות'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverview(),
          _buildAppointments(),
          _buildMedications(),
          _buildTests(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEB3349),
        onPressed: _showAddMenu,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ====== סינון לפי בן משפחה ======
  Widget _buildMemberFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _filterChip(null, 'הכל'),
          ..._state.members.map((m) => _filterChip(m.id, m.name, m.color)),
        ],
      ),
    );
  }

  Widget _filterChip(String? id, String label, [Color? color]) {
    final isSelected = _selectedMemberId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMemberId = id),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? const Color(0xFFEB3349))
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? const Color(0xFFEB3349))
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null && isSelected) ...[
              CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.4),
                child: Text(
                  label[0],
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== טאב סקירה ======
  Widget _buildOverview() {
    final upcoming = _state.upcomingAppointments.take(3).toList();
    final activeMeds = _state.activeMedications;
    final pendingTests = _state.pendingTests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  Icons.calendar_today_rounded,
                  '${upcoming.length}',
                  'תורים קרובים',
                  const Color(0xFF2196F3),
                  () => _tabController.animateTo(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  Icons.medication_rounded,
                  '${activeMeds.length}',
                  'תרופות פעילות',
                  const Color(0xFF9C27B0),
                  () => _tabController.animateTo(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  Icons.biotech_rounded,
                  '${pendingTests.length}',
                  'בדיקות ממתינות',
                  const Color(0xFFFF9800),
                  () => _tabController.animateTo(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (upcoming.isNotEmpty) ...[
            _sectionHeader(
              'תורים קרובים',
              Icons.event_rounded,
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 10),
            ...upcoming.map((a) => _buildAppointmentTile(a)),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(
                'בני המשפחה',
                Icons.people_rounded,
                const Color(0xFFEB3349),
              ),
              TextButton.icon(
                onPressed: _showManageMembersSheet,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('ערוך'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._state.members.map((m) {
            final memberAppointments = _state
                .appointmentsForMember(m.id)
                .where((a) => !a.isDone)
                .length;
            final memberMeds = _state.activeMedications
                .where((med) => med.memberId == m.id)
                .length;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: m.color,
                  child: Text(
                    m.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  m.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  m.age != null ? 'גיל ${m.age}' : '',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (memberAppointments > 0)
                      _badge(
                        '$memberAppointments תורים',
                        const Color(0xFF2196F3),
                      ),
                    if (memberMeds > 0) ...[
                      const SizedBox(width: 6),
                      _badge('$memberMeds תרופות', const Color(0xFF9C27B0)),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _summaryCard(
    IconData icon,
    String count,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ====== טאב תורים ======
  Widget _buildAppointments() {
    final filtered = _selectedMemberId == null
        ? _state.appointments
        : _state.appointments
              .where((a) => a.memberId == _selectedMemberId)
              .toList();

    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final upcoming = filtered.where((a) => !a.isDone && !a.isPast).toList();
    final past = filtered.where((a) => a.isDone || a.isPast).toList();

    return Column(
      children: [
        _buildMemberFilter(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            children: [
              if (upcoming.isEmpty && past.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'אין תורים',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                if (upcoming.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'קרובים',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  ...upcoming.map((a) => _buildAppointmentTile(a)),
                ],
                if (past.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'עברו / הושלמו',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ...past.map((a) => _buildAppointmentTile(a)),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentTile(Appointment a) {
    final member = _state.getMember(a.memberId);
    final isToday = a.isToday;
    final isPast = a.isPast;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: a.isDone
              ? Colors.grey.withValues(alpha: 0.1)
              : a.type.color.withValues(alpha: 0.15),
          child: Icon(
            a.type.icon,
            color: a.isDone ? Colors.grey : a.type.color,
            size: 20,
          ),
        ),
        title: Text(
          a.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: a.isDone ? TextDecoration.lineThrough : null,
            color: a.isDone ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateTime(a.dateTime),
              style: TextStyle(
                fontSize: 12,
                color: isToday ? const Color(0xFFEB3349) : Colors.grey,
              ),
            ),
            if (a.doctorName != null)
              Text(
                a.doctorName!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            if (a.location != null)
              Text(
                a.location!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: member.color,
                child: Text(
                  member.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            const SizedBox(width: 4),
            if (isToday && !a.isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEB3349),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'היום',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isPast && !a.isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'עבר',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'done', child: Text('סמן כהושלם')),
                const PopupMenuItem(value: 'delete', child: Text('מחיקה')),
              ],
              onSelected: (val) {
                if (val == 'done') {
                  _state.toggleAppointment(a.id);
                }
                if (val == 'delete') {
                  _state.deleteAppointment(a.id);
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // ====== טאב תרופות ======
  Widget _buildMedications() {
    final filtered = _selectedMemberId == null
        ? _state.medications
        : _state.medications
              .where((m) => m.memberId == _selectedMemberId)
              .toList();

    final active = filtered.where((m) => m.isActive).toList();
    final inactive = filtered.where((m) => !m.isActive).toList();

    return Column(
      children: [
        _buildMemberFilter(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            children: [
              if (active.isEmpty && inactive.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'אין תרופות',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                if (active.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'פעילות',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                  ...active.map((m) => _buildMedicationTile(m)),
                ],
                if (inactive.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'לא פעילות',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ...inactive.map((m) => _buildMedicationTile(m)),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationTile(Medication med) {
    final member = _state.getMember(med.memberId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: med.isActive
              ? const Color(0xFF9C27B0).withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          child: Icon(
            Icons.medication_rounded,
            color: med.isActive ? const Color(0xFF9C27B0) : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          med.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: med.isActive ? null : TextDecoration.lineThrough,
            color: med.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${med.dosage} • ${med.frequency.label}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'מאז ${_formatDate(med.startDate)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: member.color,
                child: Text(
                  member.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(med.isActive ? 'השבת' : 'הפעל'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('מחיקה')),
              ],
              onSelected: (val) {
                if (val == 'toggle') {
                  _state.toggleMedication(med.id);
                }
                if (val == 'delete') {
                  _state.deleteMedication(med.id);
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // ====== טאב בדיקות ======
  Widget _buildTests() {
    final filtered = _selectedMemberId == null
        ? _state.tests
        : _state.tests.where((t) => t.memberId == _selectedMemberId).toList();

    final pending = filtered.where((t) => !t.isDone).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final done = filtered.where((t) => t.isDone).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        _buildMemberFilter(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            children: [
              if (pending.isEmpty && done.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'אין בדיקות',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                if (pending.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'ממתינות',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  ),
                  ...pending.map((t) => _buildTestTile(t)),
                ],
                if (done.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('הושלמו', style: TextStyle(color: Colors.grey)),
                  ),
                  ...done.map((t) => _buildTestTile(t)),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestTile(MedicalTest test) {
    final member = _state.getMember(test.memberId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: test.isDone
              ? Colors.green.withValues(alpha: 0.1)
              : const Color(0xFFFF9800).withValues(alpha: 0.15),
          child: Icon(
            test.type.icon,
            color: test.isDone ? Colors.green : const Color(0xFFFF9800),
            size: 20,
          ),
        ),
        title: Text(
          test.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(test.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (test.result != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'תוצאה: ${test.result}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: member.color,
                child: Text(
                  member.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 18),
              itemBuilder: (_) => [
                if (!test.isDone)
                  const PopupMenuItem(
                    value: 'complete',
                    child: Text('הזן תוצאה'),
                  ),
                const PopupMenuItem(value: 'delete', child: Text('מחיקה')),
              ],
              onSelected: (val) {
                if (val == 'complete') {
                  _showCompleteTestDialog(test);
                }
                if (val == 'delete') {
                  _state.deleteTest(test.id);
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // ====== דיאלוגים ======

  void _showAddMenu() {
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
              Icons.event_rounded,
              'תור לרופא',
              const Color(0xFF2196F3),
              () {
                Navigator.pop(context);
                _showAddAppointmentSheet();
              },
            ),
            const SizedBox(height: 10),
            _addOption(
              Icons.medication_rounded,
              'תרופה',
              const Color(0xFF9C27B0),
              () {
                Navigator.pop(context);
                _showAddMedicationSheet();
              },
            ),
            const SizedBox(height: 10),
            _addOption(
              Icons.biotech_rounded,
              'בדיקה',
              const Color(0xFFFF9800),
              () {
                Navigator.pop(context);
                _showAddTestSheet();
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

  void _showManageMembersSheet() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'בני המשפחה',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddEditMemberSheet(null);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('הוסף'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._state.members.map(
                (m) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: m.color,
                    child: Text(
                      m.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    m.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: m.age != null ? Text('גיל ${m.age}') : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showAddEditMemberSheet(m);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _state.deleteMember(m.id);
                          setModal(() {});
                        },
                      ),
                    ],
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

  void _showAddEditMemberSheet(HealthMember? member) {
    final nameController = TextEditingController(text: member?.name ?? '');
    DateTime? birthDate = member?.birthDate;
    Color selectedColor = member?.color ?? const Color(0xFF2193B0);

    final colors = [
      const Color(0xFF2193B0),
      const Color(0xFFEB3349),
      const Color(0xFF11998E),
      const Color(0xFFF7971E),
      const Color(0xFF4A00E0),
      const Color(0xFF9C27B0),
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
                Text(
                  member == null ? 'בן משפחה חדש' : 'עריכת ${member.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate:
                          birthDate ??
                          DateTime.now().subtract(
                            const Duration(days: 365 * 10),
                          ),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModal(() => birthDate = picked);
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
                        const Icon(Icons.cake_rounded, size: 18),
                        Text(
                          birthDate != null
                              ? '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'
                              : 'תאריך לידה (אופציונלי)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: birthDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
                  children: colors.map((c) {
                    final isSelected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setModal(() => selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEB3349),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      if (member == null) {
                        _state.addMember(
                          HealthMember(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text,
                            color: selectedColor,
                            birthDate: birthDate,
                          ),
                        );
                      } else {
                        _state.updateMember(
                          HealthMember(
                            id: member.id,
                            name: nameController.text,
                            color: selectedColor,
                            birthDate: birthDate,
                          ),
                        );
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      member == null ? 'הוסף' : 'שמור שינויים',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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

  void _showAddAppointmentSheet() {
    final titleController = TextEditingController();
    final doctorController = TextEditingController();
    final locationController = TextEditingController();
    DoctorType selectedType = DoctorType.gp;
    String? selectedMemberId;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

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
                  'תור חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'סוג רופא:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: DoctorType.values.map((t) {
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
                    labelText: 'כותרת',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: doctorController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם הרופא (אופציונלי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מיקום (אופציונלי)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
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
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              Text(
                                _formatDate(selectedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModal(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              Text(
                                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'עבור מי?',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedMemberId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('בחר בן משפחה'),
                    ),
                    ..._state.members.map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: m.color,
                              child: Text(
                                m.name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(m.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setModal(() => selectedMemberId = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEB3349),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty) return;
                      final dt = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      _state.addAppointment(
                        Appointment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          type: selectedType,
                          dateTime: dt,
                          doctorName: doctorController.text.isEmpty
                              ? null
                              : doctorController.text,
                          location: locationController.text.isEmpty
                              ? null
                              : locationController.text,
                          memberId: selectedMemberId,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף תור',
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

  void _showAddMedicationSheet() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    MedicationFrequency selectedFreq = MedicationFrequency.daily;
    String? selectedMemberId;

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
                  'תרופה חדשה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם התרופה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dosageController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'מינון (לדוגמה: 500מג)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'תדירות:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MedicationFrequency.values.map((f) {
                    final isSelected = selectedFreq == f;
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedFreq = f),
                      selectedColor: const Color(0xFF9C27B0),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'עבור מי?',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedMemberId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('בחר בן משפחה'),
                    ),
                    ..._state.members.map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: m.color,
                              child: Text(
                                m.name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(m.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setModal(() => selectedMemberId = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      _state.addMedication(
                        Medication(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          dosage: dosageController.text,
                          frequency: selectedFreq,
                          memberId: selectedMemberId,
                          startDate: DateTime.now(),
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף תרופה',
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

  void _showAddTestSheet() {
    final titleController = TextEditingController();
    TestType selectedType = TestType.blood;
    String? selectedMemberId;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

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
                  'בדיקה חדשה',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TestType.values.map((t) {
                    final isSelected = selectedType == t;
                    return ChoiceChip(
                      label: Text(t.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedType = t),
                      selectedColor: const Color(0xFFFF9800),
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
                    labelText: 'שם הבדיקה',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
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
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'עבור מי?',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedMemberId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('בחר בן משפחה'),
                    ),
                    ..._state.members.map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: m.color,
                              child: Text(
                                m.name[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(m.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setModal(() => selectedMemberId = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (titleController.text.isEmpty) return;
                      _state.addTest(
                        MedicalTest(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          type: selectedType,
                          date: selectedDate,
                          memberId: selectedMemberId,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף בדיקה',
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

  void _showCompleteTestDialog(MedicalTest test) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('תוצאת ${test.title}', textAlign: TextAlign.right),
        content: TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            labelText: 'הזן תוצאה',
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
              backgroundColor: const Color(0xFFEB3349),
            ),
            onPressed: () {
              _state.completeTest(test.id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('שמור', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
