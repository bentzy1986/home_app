import 'package:flutter/material.dart';
import '../family_state.dart';
import '../models/family_models.dart';

class FamilyCalendar extends StatefulWidget {
  final FamilyState state;
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const FamilyCalendar({
    super.key,
    required this.state,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<FamilyCalendar> createState() => _FamilyCalendarState();
}

class _FamilyCalendarState extends State<FamilyCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
    );
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    int startOffset = firstDay.weekday == 7 ? 0 : firstDay.weekday;
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayedMonth.year, _displayedMonth.month, d));
    }
    return cells;
  }

  String _hebrewMonth(int m) {
    const months = [
      'ינואר',
      'פברואר',
      'מרץ',
      'אפריל',
      'מאי',
      'יוני',
      'יולי',
      'אוגוסט',
      'ספטמבר',
      'אוקטובר',
      'נובמבר',
      'דצמבר',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCalendarDays();
    const weekDays = ['א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                  () => _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  ),
                ),
              ),
              Text(
                '${_hebrewMonth(_displayedMonth.month)} ${_displayedMonth.year}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: weekDays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: cells.length,
            itemBuilder: (context, i) {
              final day = cells[i];
              if (day == null) return const SizedBox();

              final isSelected = DateUtils.isSameDay(day, widget.selectedDay);
              final isToday = DateUtils.isSameDay(day, DateTime.now());
              final events = widget.state.eventsForDate(day);
              final activities = widget.state.activitiesForWeekday(day.weekday);
              final hasContent = events.isNotEmpty || activities.isNotEmpty;

              final List<Color> dotColors = [
                ...events.map<Color>(
                  (e) =>
                      widget.state.getMember(e.memberId)?.color ?? e.type.color,
                ),
                ...activities.map<Color>(
                  (a) =>
                      widget.state.getMember(a.memberId)?.color ??
                      Colors.orange,
                ),
              ];

              return GestureDetector(
                onTap: () => widget.onDaySelected(day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A1A1A)
                        : isToday
                        ? Colors.grey.withValues(alpha: 0.15)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isToday
                              ? const Color(0xFF1A1A1A)
                              : Colors.black87,
                        ),
                      ),
                      if (hasContent)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dotColors
                              .take(3)
                              .map(
                                (c) => Container(
                                  width: 5,
                                  height: 5,
                                  margin: const EdgeInsets.only(
                                    top: 2,
                                    left: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : c,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
