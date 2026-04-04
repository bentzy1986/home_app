import 'package:flutter/material.dart';
import '../../main.dart';
import 'family_state.dart';
import 'models/family_models.dart';
import 'widgets/family_calendar.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/add_activity_sheet.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen>
    with SingleTickerProviderStateMixin {
  final FamilyState _state = globalFamilyState;
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  String _hebrewWeekday(int w) {
    const days = {
      1: 'שני',
      2: 'שלישי',
      3: 'רביעי',
      4: 'חמישי',
      5: 'שישי',
      6: 'שבת',
      7: 'ראשון',
    };
    return days[w] ?? '';
  }

  void _showDeleteActivityDialog(
    WeeklyActivity activity,
    Weekday day,
    DateTime specificDate,
  ) {
    final hasMultipleDays = activity.weekdays.length > 1;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('מחיקת חוג', textAlign: TextAlign.right),
        content: Text(
          'מה תרצה למחוק עבור "${activity.title}"?',
          textAlign: TextAlign.right,
        ),
        actions: [
          // ביטול
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ביטול'),
          ),
          // רק היום הספציפי הזה
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _state.cancelActivityOnDate(activity.id, specificDate);
            },
            child: Text(
              'רק ${_formatDate(specificDate)}',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          // כל יום X בשבוע (רק אם יש מספר ימים)
          if (hasMultipleDays)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _state.deleteActivityDay(activity.id, day);
              },
              child: Text(
                'כל יום ${day.label}',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          // מחק הכל
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _state.deleteActivity(activity.id);
            },
            child: const Text('כל הימים', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditMemberSheet(FamilyMember member) {
    final nameController = TextEditingController(text: member.name);
    DateTime? birthday = member.birthday;
    Color selectedColor = member.color;

    final colors = [
      const Color(0xFF2193B0),
      const Color(0xFFEB3349),
      const Color(0xFF11998E),
      const Color(0xFFF7971E),
      const Color(0xFF4A00E0),
      const Color(0xFFE91E63),
      const Color(0xFF607D8B),
      const Color(0xFF388E3C),
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
                  'עריכת בן משפחה',
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
                const SizedBox(height: 15),
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
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: birthday ?? DateTime(2000),
                      firstDate: DateTime(1940),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setModal(() => birthday = picked);
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
                          birthday != null
                              ? _formatDate(birthday!)
                              : 'בחר תאריך לידה',
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
                      if (nameController.text.isEmpty) return;
                      _state.updateMember(
                        member.copyWith(
                          name: nameController.text,
                          color: selectedColor,
                          birthday: birthday,
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

  void _showEditEventSheet(FamilyEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEventSheet(state: _state, existingEvent: event),
    );
  }

  void _showEditActivitySheet(WeeklyActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddActivitySheet(state: _state, existingActivity: activity),
    );
  }

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
              Icons.celebration_rounded,
              'אירוע / יום הולדת',
              Colors.purple,
              () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddEventSheet(state: _state),
                );
              },
            ),
            const SizedBox(height: 12),
            _addOption(
              Icons.sports_soccer_rounded,
              'חוג שבועי',
              Colors.orange,
              () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddActivitySheet(state: _state),
                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'משפחה',
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
          tabs: const [
            Tab(text: 'יומן'),
            Tab(text: 'חוגים'),
            Tab(text: 'משפחה'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          _buildActivitiesTab(),
          _buildMembersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A1A),
        onPressed: _showAddMenu,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarTab() {
    final selectedEvents = _state.eventsForDate(_selectedDay);
    // ← שימוש ב-activitiesForDate במקום activitiesForWeekday
    final todayActivities = _state.activitiesForDate(_selectedDay);
    final upcoming = _state.upcomingEvents;
    final birthdays = _state.upcomingBirthdays
        .where((b) => (b['days'] as int) <= 30)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (upcoming.isNotEmpty || birthdays.isNotEmpty)
            _buildAlertsBanner(upcoming, birthdays),
          FamilyCalendar(
            state: _state,
            selectedDay: _selectedDay,
            onDaySelected: (day) => setState(() => _selectedDay = day),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'יום ${_hebrewWeekday(_selectedDay.weekday)}, ${_formatDate(_selectedDay)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                if (selectedEvents.isEmpty && todayActivities.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'אין אירועים ביום זה',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ...selectedEvents.map((e) => _buildEventTile(e)),
                ...todayActivities.map((a) => _buildActivityTile(a)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsBanner(
    List<FamilyEvent> upcoming,
    List<Map<String, dynamic>> birthdays,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'קרוב אליך',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...birthdays.map((b) {
            final m = b['member'] as FamilyMember;
            final days = b['days'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.cake_rounded, color: m.color, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    days == 0
                        ? '🎉 יום הולדת של ${m.name} — היום!'
                        : 'יום הולדת של ${m.name} — בעוד $days ימים',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            );
          }),
          ...upcoming.map((e) {
            final days = e.date.difference(DateTime.now()).inDays;
            final member = _state.getMember(e.memberId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    e.type.icon,
                    color: member?.color ?? Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${e.title} — בעוד $days ימים',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEventTile(FamilyEvent event) {
    final member = _state.getMember(event.memberId);
    final color = event.type.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(event.type.icon, color: color, size: 20),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: member != null
            ? Text(member.name, style: TextStyle(color: member.color))
            : Text(event.type.label, style: TextStyle(color: color)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => _showEditEventSheet(event),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => _state.deleteEvent(event.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(WeeklyActivity activity) {
    final member = _state.getMember(activity.memberId);
    final color = member?.color ?? Colors.orange;

    final Weekday displayDay = activity.weekdays.firstWhere(
      (d) => d.flutterWeekday == _selectedDay.weekday,
      orElse: () => activity.weekdays.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.sports_soccer_rounded, color: color, size: 20),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${activity.time}${activity.location != null ? ' | ${activity.location}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (member != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: Text(
                  member.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => _showEditActivitySheet(activity),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () =>
                  _showDeleteActivityDialog(activity, displayDay, _selectedDay),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    final days = [
      Weekday.sunday,
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
    ];
    final dayMap = {
      Weekday.sunday: 7,
      Weekday.monday: 1,
      Weekday.tuesday: 2,
      Weekday.wednesday: 3,
      Weekday.thursday: 4,
      Weekday.friday: 5,
    };

    final hasAny = days.any(
      (d) => _state.activitiesForWeekday(dayMap[d]!).isNotEmpty,
    );

    return hasAny
        ? ListView(
            padding: const EdgeInsets.all(16),
            children: days.map((day) {
              final acts = _state.activitiesForWeekday(dayMap[day]!);
              if (acts.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'יום ${day.label}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  ...acts.map((a) {
                    final member = _state.getMember(a.memberId);
                    final color = member?.color ?? Colors.orange;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.sports_soccer_rounded,
                            color: color,
                          ),
                        ),
                        title: Text(
                          a.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${a.time}${a.location != null ? ' | ${a.location}' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (member != null)
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: color,
                                child: Text(
                                  member.name[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => _showEditActivitySheet(a),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => _showDeleteActivityDialog(
                                a,
                                day,
                                DateTime.now(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Divider(),
                ],
              );
            }).toList(),
          )
        : const Center(
            child: Text(
              'אין חוגים עדיין',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
  }

  Widget _buildMembersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'בני המשפחה',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 15),
        ..._state.members.map((m) {
          final bdays = _state.upcomingBirthdays
              .where((b) => (b['member'] as FamilyMember).id == m.id)
              .toList();
          final daysUntil = bdays.isNotEmpty
              ? bdays.first['days'] as int
              : null;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
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
              subtitle: m.birthday != null
                  ? Text(
                      daysUntil == 0
                          ? '🎉 יום הולדת היום!'
                          : daysUntil != null
                          ? 'יום הולדת בעוד $daysUntil ימים'
                          : 'יום הולדת: ${_formatDate(m.birthday!)}',
                      style: TextStyle(
                        color: m.color,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                onPressed: () => _showEditMemberSheet(m),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        const Text(
          'ימי הולדת קרובים',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 15),
        ..._state.upcomingBirthdays.take(4).map((b) {
          final m = b['member'] as FamilyMember;
          final days = b['days'] as int;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: m.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: m.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.cake_rounded, color: m.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: m.color,
                        ),
                      ),
                      Text(
                        _formatDate(b['date'] as DateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: m.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    days == 0 ? 'היום! 🎉' : 'עוד $days ימים',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
