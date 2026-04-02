import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceProvidersScreen extends StatefulWidget {
  const ServiceProvidersScreen({super.key});

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  // רשימת בעלי המקצוע - מתחילה עם ברירת המחדל שלך
  final List<Map<String, dynamic>> _providers = [
    {'role': 'טכנאי מיזוג', 'name': '', 'phone': ''},
    {'role': 'אינסטלטור', 'name': '', 'phone': ''},
    {'role': 'טכנאי דודים וקולט', 'name': '', 'phone': ''},
    {'role': 'מנעולן', 'name': '', 'phone': ''},
    {'role': 'חשמלאי', 'name': '', 'phone': ''},
    {'role': 'טכנאי כביסה', 'name': '', 'phone': ''},
    {'role': 'טכנאי מייבש', 'name': '', 'phone': ''},
    {'role': 'טכנאי מקרר', 'name': '', 'phone': ''},
  ];

  // פונקציה אחת שמטפלת גם בעריכה וגם בהוספה חדשה
  void _showProviderDialog(int? index) {
    final bool isEditing = index != null;

    final roleController = TextEditingController(
      text: isEditing ? _providers[index]['role'] : '',
    );
    final nameController = TextEditingController(
      text: isEditing ? _providers[index]['name'] : '',
    );
    final phoneController = TextEditingController(
      text: isEditing ? _providers[index]['phone'] : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'עריכת איש מקצוע' : 'הוספת בעל מקצוע חדש',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: roleController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'מקצוע / תפקיד',
                hintText: 'למשל: שיפוצניק',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'שם בעל המקצוע',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'מספר נייד',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                if (roleController.text.isNotEmpty) {
                  setState(() {
                    if (isEditing) {
                      // עדכון קיים
                      _providers[index]['role'] = roleController.text;
                      _providers[index]['name'] = nameController.text;
                      _providers[index]['phone'] = phoneController.text;
                    } else {
                      // הוספה לרשימה
                      _providers.add({
                        'role': roleController.text,
                        'name': nameController.text,
                        'phone': phoneController.text,
                      });
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                isEditing ? 'שמור שינויים' : 'הוסף לרשימה',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint("שגיאה בחיוג: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'בעלי מקצוע',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _providers.length,
        itemBuilder: (context, index) {
          final provider = _providers[index];
          final bool hasData =
              provider['name'].isNotEmpty || provider['phone'].isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              onTap: () => _showProviderDialog(index),
              leading: CircleAvatar(
                backgroundColor: hasData
                    ? Colors.indigo.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: hasData ? Colors.indigo : Colors.grey,
                ),
              ),
              title: Text(
                provider['role'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                hasData
                    ? '${provider['name']} | ${provider['phone']}'
                    : 'לחץ להזנת פרטים',
              ),
              trailing: provider['phone'].isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () => _makeCall(provider['phone']),
                    )
                  : const Icon(Icons.edit_note, color: Colors.grey),
            ),
          );
        },
      ),
      // הכפתור החדש להוספת בעל מקצוע שלא ברשימה
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProviderDialog(null),
        backgroundColor: const Color(0xFF1A1A1A),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
