import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../main.dart';
import 'shopping_state.dart';
import 'models/shopping_models.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});
  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen>
    with SingleTickerProviderStateMixin {
  final ShoppingState _state = globalShoppingState;
  late TabController _tabController;
  String? _selectedListId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _state.addListener(_onStateChange);
    if (_state.lists.isNotEmpty) {
      _selectedListId = _state.lists.first.id;
    }
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

  ShoppingList? get _currentList => _selectedListId != null
      ? _state.lists.firstWhere(
          (l) => l.id == _selectedListId,
          orElse: () => _state.lists.first,
        )
      : null;

  // ====== שליחת WhatsApp ======
  Future<void> _sendWhatsApp(ShoppingList list, ShoppingContact contact) async {
    final buffer = StringBuffer();
    buffer.writeln('🛒 *${list.name}*');
    buffer.writeln('');

    final byCategory = list.itemsByCategory;
    for (final entry in byCategory.entries) {
      final unchecked = entry.value.where((i) => !i.isChecked).toList();
      if (unchecked.isEmpty) continue;
      buffer.writeln('*${entry.key.label}*');
      for (final item in unchecked) {
        final qty = item.quantity != null
            ? '${item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1)} ${item.unit ?? ''}'
            : '';
        buffer.writeln('• ${item.name} $qty');
      }
      buffer.writeln('');
    }

    String phone = contact.phone
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll('+', '');
    if (phone.startsWith('0')) {
      phone = '972${phone.substring(1)}';
    }

    final text = Uri.encodeComponent(buffer.toString());
    final url = Uri.parse('https://wa.me/$phone?text=$text');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('לא ניתן לפתוח את WhatsApp'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSendWhatsAppSheet(ShoppingList list) {
    if (_state.contacts.isEmpty) {
      _showManageContactsSheet();
      return;
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'שלח ל...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showManageContactsSheet();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('ערוך'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._state.contacts.map(
              (c) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(
                    0xFF25D366,
                  ).withValues(alpha: 0.15),
                  child: FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: const Color(0xFF25D366),
                    size: 20,
                  ),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  c.phone,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _sendWhatsApp(list, c);
                  },
                  child: const Text(
                    'שלח',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showSendToCustomNumberSheet(list);
                },
                icon: const Icon(Icons.dialpad_rounded),
                label: const Text('מספר אחר'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSendToCustomNumberSheet(ShoppingList list) {
    final phoneController = TextEditingController();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'שלח למספר',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                labelText: 'מספר טלפון',
                border: OutlineInputBorder(),
                prefixText: '+972 ',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (phoneController.text.isEmpty) return;
                  final contact = ShoppingContact(
                    id: 'temp',
                    name: 'מספר ידני',
                    phone: phoneController.text,
                  );
                  Navigator.pop(context);
                  _sendWhatsApp(list, contact);
                },
                icon: FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'שלח',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showManageContactsSheet() {
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
                    'אנשי קשר לקניות',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showAddEditContactSheet(null);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('הוסף'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_state.contacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'אין אנשי קשר עדיין',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ..._state.contacts.map(
                  (c) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF25D366),
                      child: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      c.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(c.phone),
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
                            _showAddEditContactSheet(c);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _state.deleteContact(c.id);
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

  void _showAddEditContactSheet(ShoppingContact? contact) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contact == null ? 'איש קשר חדש' : 'עריכת ${contact.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              controller: phoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'מספר טלפון (לדוגמה: 050-1234567)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7971E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty)
                    return;
                  if (contact == null) {
                    _state.addContact(
                      ShoppingContact(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        phone: phoneController.text,
                      ),
                    );
                  } else {
                    _state.updateContact(
                      ShoppingContact(
                        id: contact.id,
                        name: nameController.text,
                        phone: phoneController.text,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  contact == null ? 'הוסף' : 'שמור שינויים',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7971E),
        elevation: 0,
        title: const Text(
          'קניות',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts_rounded, color: Colors.white),
            onPressed: _showManageContactsSheet,
            tooltip: 'אנשי קשר',
          ),
          IconButton(
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
            ),
            onPressed: _showAddListSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'רשימות'),
            Tab(text: 'קנייה'),
            Tab(text: 'מזווה'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildListsTab(), _buildShoppingTab(), _buildPantryTab()],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF7971E),
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddListSheet();
          } else if (_tabController.index == 1 && _currentList != null) {
            _showAddItemSheet(_currentList!);
          } else if (_tabController.index == 2) {
            _showAddPantryItemSheet();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ====== טאב רשימות ======
  Widget _buildListsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_state.lowPantryItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'פריטים חסרים במזווה',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_state.lowPantryItems.length} פריטים צריכים חידוש',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_state.lists.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _state.addLowPantryToList(_state.lists.first.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('פריטי המזווה נוספו לרשימה הראשונה'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      'הוסף לרשימה',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const Text(
          'הרשימות שלי',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (_state.lists.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 60,
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'אין רשימות עדיין',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showAddListSheet,
                    child: const Text('צור רשימה חדשה'),
                  ),
                ],
              ),
            ),
          )
        else
          ..._state.lists.map((list) => _buildListCard(list)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildListCard(ShoppingList list) {
    final isSelected = _selectedListId == list.id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedListId = list.id);
        _tabController.animateTo(1);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? list.type.color
                : Colors.grey.withValues(alpha: 0.15),
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: list.type.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(list.type.icon, color: list.type.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${list.checkedItems}/${list.totalItems} פריטים',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSendWhatsAppSheet(list),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: const Color(0xFF25D366),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'reset',
                      child: Text('איפוס רשימה'),
                    ),
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('הסר שנקנו'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('מחק רשימה'),
                    ),
                  ],
                  onSelected: (val) {
                    if (val == 'reset') {
                      _state.resetList(list.id);
                    }
                    if (val == 'clear') {
                      _state.clearChecked(list.id);
                    }
                    if (val == 'delete') {
                      _state.deleteList(list.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: list.progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.1),
                color: list.progress == 1.0 ? Colors.green : list.type.color,
              ),
            ),
            if (list.progress == 1.0)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'הרשימה הושלמה! 🎉',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ====== טאב קנייה ======
  Widget _buildShoppingTab() {
    final list = _currentList;

    if (list == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text('אין רשימה פעילה', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showAddListSheet,
              child: const Text('צור רשימה חדשה'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_state.lists.length > 1)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _state.lists.map((l) {
                  final isSelected = _selectedListId == l.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedListId = l.id),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? l.type.color
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${list.uncheckedItems.length} נשאר לקנות',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  if (list.totalPrice > 0)
                    Text(
                      '₪${list.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showSendWhatsAppSheet(list),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: const Color(0xFF25D366),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'שלח',
                            style: TextStyle(
                              color: Color(0xFF25D366),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: list.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 60,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'הרשימה ריקה',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  children: [
                    ...list.itemsByCategory.entries
                        .where((e) => e.value.any((i) => !i.isChecked))
                        .map((entry) {
                          final unchecked = entry.value
                              .where((i) => !i.isChecked)
                              .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      entry.key.icon,
                                      color: entry.key.color,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      entry.key.label,
                                      style: TextStyle(
                                        color: entry.key.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...unchecked.map(
                                (item) => _buildShoppingItemTile(list, item),
                              ),
                            ],
                          );
                        }),
                    if (list.checkedItemsList.isNotEmpty) ...[
                      const Divider(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'נקנו (${list.checkedItems})',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...list.checkedItemsList.map(
                        (item) => _buildShoppingItemTile(list, item),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildShoppingItemTile(ShoppingList list, ShoppingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _state.toggleItem(list.id, item.id),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isChecked ? Colors.green : Colors.transparent,
              border: Border.all(
                color: item.isChecked
                    ? Colors.green
                    : Colors.grey.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: item.isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? Colors.grey : Colors.black87,
            fontSize: 14,
          ),
        ),
        subtitle: item.quantity != null
            ? Text(
                '${item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1)} ${item.unit ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.price != null)
              Text(
                '₪${item.price!.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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
                  _showEditItemSheet(list, item);
                }
                if (val == 'delete') {
                  _state.deleteItem(list.id, item.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemSheet(ShoppingList list, ShoppingItem item) {
    final nameController = TextEditingController(text: item.name);
    final quantityController = TextEditingController(
      text: item.quantity != null
          ? item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1)
          : '',
    );
    final unitController = TextEditingController(text: item.unit ?? '');
    final priceController = TextEditingController(
      text: item.price?.toStringAsFixed(0) ?? '',
    );
    ShoppingCategory selectedCategory = item.category;

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
                  'עריכת פריט',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'קטגוריה:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ShoppingCategory.values.map((c) {
                    final isSelected = selectedCategory == c;
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedCategory = c),
                      selectedColor: c.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם הפריט',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'כמות',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'יחידה',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '₪ מחיר',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7971E),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      _state.updateItem(
                        list.id,
                        ShoppingItem(
                          id: item.id,
                          name: nameController.text,
                          category: selectedCategory,
                          quantity: double.tryParse(quantityController.text),
                          unit: unitController.text.isEmpty
                              ? null
                              : unitController.text,
                          price: double.tryParse(priceController.text),
                          isChecked: item.isChecked,
                          isPantryItem: item.isPantryItem,
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

  // ====== טאב מזווה ======
  Widget _buildPantryTab() {
    final byCategory = <ShoppingCategory, List<PantryItem>>{};
    for (final item in _state.pantry) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_state.lowPantryItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  '${_state.lowPantryItems.length} פריטים חסרים או נמוכים',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ...byCategory.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(entry.key.icon, color: entry.key.color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      entry.key.label,
                      style: TextStyle(
                        color: entry.key.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value.map((p) => _buildPantryTile(p)),
              const Divider(height: 16),
            ],
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildPantryTile(PantryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isLow
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${item.quantity} ${item.unit ?? ''} במלאי | מינימום: ${item.minQuantity}',
                  style: TextStyle(
                    fontSize: 11,
                    color: item.isLow ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (item.isLow)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'חסר',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (item.quantity > 0) {
                    _state.updatePantryQuantity(item.id, item.quantity - 1);
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _state.updatePantryQuantity(item.id, item.quantity + 1),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7971E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Color(0xFFF7971E),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _state.deletePantryItem(item.id),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ====== דיאלוגים ======
  void _showAddListSheet() {
    final nameController = TextEditingController();
    ListType selectedType = ListType.weekly;

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
              const Text(
                'רשימה חדשה',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'שם הרשימה',
                  border: OutlineInputBorder(),
                ),
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
                children: ListType.values.map((t) {
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7971E),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    final newList = ShoppingList(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      type: selectedType,
                      createdAt: DateTime.now(),
                      items: [],
                    );
                    _state.addList(newList);
                    setState(() => _selectedListId = newList.id);
                    Navigator.pop(ctx);
                    _tabController.animateTo(1);
                  },
                  child: const Text(
                    'צור רשימה',
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

  void _showAddItemSheet(ShoppingList list) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final priceController = TextEditingController();
    ShoppingCategory selectedCategory = ShoppingCategory.produce;

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
                  'פריט חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'קטגוריה:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ShoppingCategory.values.map((c) {
                    final isSelected = selectedCategory == c;
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedCategory = c),
                      selectedColor: c.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם הפריט',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'כמות',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'יחידה',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '₪ מחיר',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7971E),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      _state.addItem(
                        list.id,
                        ShoppingItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          category: selectedCategory,
                          quantity: double.tryParse(quantityController.text),
                          unit: unitController.text.isEmpty
                              ? null
                              : unitController.text,
                          price: double.tryParse(priceController.text),
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף פריט',
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

  void _showAddPantryItemSheet() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final minQuantityController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    ShoppingCategory selectedCategory = ShoppingCategory.pantry;

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
                  'פריט מזווה חדש',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ShoppingCategory.values.map((c) {
                    final isSelected = selectedCategory == c;
                    return ChoiceChip(
                      label: Text(c.label),
                      selected: isSelected,
                      onSelected: (_) => setModal(() => selectedCategory = c),
                      selectedColor: c.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'שם הפריט',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'כמות קיימת',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: minQuantityController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'מינימום',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          labelText: 'יחידה',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7971E),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.isEmpty) return;
                      _state.addPantryItem(
                        PantryItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          category: selectedCategory,
                          quantity: int.tryParse(quantityController.text) ?? 1,
                          minQuantity:
                              int.tryParse(minQuantityController.text) ?? 1,
                          unit: unitController.text.isEmpty
                              ? null
                              : unitController.text,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'הוסף למזווה',
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
}
