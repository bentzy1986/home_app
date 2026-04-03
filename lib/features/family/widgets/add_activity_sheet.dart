import 'package:flutter/material.dart';
import '../family_state.dart';
import '../models/family_models.dart';

class AddActivitySheet extends StatefulWidget {
  final FamilyState state;
  final WeeklyActivity? existingActivity;

  const AddActivitySheet({
    super.key,
    required this.state,
    this.existingActivity,
  });

  @override
  State<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<AddActivitySheet> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _timeController;
  late ActivityRecurrence _recurrence;
  late List<Weekday> _selectedWeekdays;
  DateTime? _specificDate;
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    final a = widget.existingActivity;
    _titleController = TextEditingController(text: a?.title ?? '');
    _locationController = TextEditingController(text: a?.location ?? '');
    _timeController = TextEditingController(text: a?.time ?? '16:00');
    _recurrence = a?.recurrence ?? ActivityRecurrence.weekly;
    _selectedWeekdays = List.from(a?.weekdays ?? [Weekday.monday]);
    _specificDate = a?.specificDate;
    _selectedMemberId = a?.memberId;
  }

  Future<void> _pickTime() async {
    final parts = _timeController.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 16,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _timeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _specificDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingActivity != null;
    return Container(
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
            Text(
              isEditing ? 'עריכת חוג' : 'חוג חדש',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ====== בחירת סוג חזרתיות ======
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'סוג:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ActivityRecurrence.values.map((r) {
                final isSelected = _recurrence == r;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _recurrence = r),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A1A1A)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            r.icon,
                            color: isSelected ? Colors.white : Colors.grey,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 15),

            // ====== שם החוג ======
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'שם החוג',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // ====== מיקום ======
            TextField(
              controller: _locationController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'מיקום (אופציונלי)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // ====== בחירת ימים / תאריך לפי הסוג ======
            if (_recurrence == ActivityRecurrence.weekly) ...[
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ימים בשבוע:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Weekday.values.map((d) {
                  final isSelected = _selectedWeekdays.contains(d);
                  return FilterChip(
                    label: Text(d.label),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedWeekdays.add(d);
                        } else {
                          if (_selectedWeekdays.length > 1) {
                            _selectedWeekdays.remove(d);
                          }
                        }
                      });
                    },
                    selectedColor: const Color(0xFF1A1A1A),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // חד פעמי — בחר תאריך
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'תאריך:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
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
                        _specificDate != null
                            ? _formatDate(_specificDate!)
                            : 'בחר תאריך',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _specificDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 15),

            // ====== שעה ======
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    Text(
                      _timeController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // ====== בן משפחה ======
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'של מי?',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedMemberId,
              items: [
                const DropdownMenuItem(value: null, child: Text('כל המשפחה')),
                ...widget.state.members.map(
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
              onChanged: (v) => setState(() => _selectedMemberId = v),
            ),
            const SizedBox(height: 20),

            // ====== כפתור שמירה ======
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
                  if (_titleController.text.isEmpty) return;
                  if (_recurrence == ActivityRecurrence.oneTime &&
                      _specificDate == null)
                    return;
                  if (_recurrence == ActivityRecurrence.weekly &&
                      _selectedWeekdays.isEmpty)
                    return;

                  final updated = WeeklyActivity(
                    id:
                        widget.existingActivity?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    recurrence: _recurrence,
                    weekdays: _recurrence == ActivityRecurrence.weekly
                        ? List.from(_selectedWeekdays)
                        : [],
                    specificDate: _recurrence == ActivityRecurrence.oneTime
                        ? _specificDate
                        : null,
                    time: _timeController.text,
                    memberId: _selectedMemberId,
                    location: _locationController.text.isEmpty
                        ? null
                        : _locationController.text,
                    cancelledDates:
                        widget.existingActivity?.cancelledDates ?? [],
                  );

                  if (isEditing) {
                    widget.state.updateActivity(updated);
                  } else {
                    widget.state.addActivity(updated);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  isEditing ? 'שמור שינויים' : 'הוסף חוג',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
