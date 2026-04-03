import 'package:flutter/material.dart';
import '../family_state.dart';
import '../models/family_models.dart';

class AddEventSheet extends StatefulWidget {
  final FamilyState state;
  final FamilyEvent? existingEvent;

  const AddEventSheet({super.key, required this.state, this.existingEvent});

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  late TextEditingController _titleController;
  late EventType _type;
  late DateTime _date;
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;
    _titleController = TextEditingController(text: e?.title ?? '');
    _type = e?.type ?? EventType.familyEvent;
    _date = e?.date ?? DateTime.now();
    _selectedMemberId = e?.memberId;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEvent != null;
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
              isEditing ? 'עריכת אירוע' : 'אירוע חדש',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventType.values
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t.label),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                      selectedColor: t.color,
                      labelStyle: TextStyle(
                        color: _type == t ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'כותרת',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
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
                      _formatDate(_date),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'בן משפחה (אופציונלי)',
                border: OutlineInputBorder(),
              ),
              initialValue: _selectedMemberId, // ← תוקן מ-value ל-initialValue
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
                  final newEvent = FamilyEvent(
                    id:
                        widget.existingEvent?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    date: _date,
                    type: _type,
                    memberId: _selectedMemberId,
                  );
                  if (isEditing) {
                    widget.state.updateEvent(newEvent);
                  } else {
                    widget.state.addEvent(newEvent);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  isEditing ? 'שמור שינויים' : 'הוסף אירוע',
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
