import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact.dart';
import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final savedDark = await prefs.getBool('isDark') ?? false;

  runApp(PocketNotesApp(startDark: savedDark));
}

class PocketNotesApp extends StatefulWidget {
  final bool startDark;

  const PocketNotesApp({super.key, required this.startDark});

  @override
  State<PocketNotesApp> createState() => _PocketNotesAppState();
}

class _PocketNotesAppState extends State<PocketNotesApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.startDark;
  }

  Future<void> _changeTheme(bool value) async {
    setState(() {
      _isDark = value;
    });
    await SharedPreferencesAsync().setBool('isDark', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts',
      theme: ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.light),
      darkTheme: ThemeData(colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(isDark: _isDark, onThemeChanged: _changeTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final Future<void> Function(bool) onThemeChanged;

  const HomePage({super.key, required this.isDark, required this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts(); 
  }

  Future<void> _loadContacts() async {
    final contacts = await DatabaseHelper.instance.getContacts();
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _showContactDialog({Contact? contact}) async {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phoneNumber ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty || phone.isEmpty) return; 
                if (contact == null) {
                  await DatabaseHelper.instance
                      .insertContact(Contact(name: name, phoneNumber: phone));
                } else {
                  await DatabaseHelper.instance.updateContact(
                    Contact(id: contact.id, name: name, phoneNumber: phone),
                  );
                }

                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _loadContacts(); 
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteContact(int id) async {
    await DatabaseHelper.instance.deleteContact(id);
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          
          Switch(
            value: widget.isDark,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('No contacts yet'))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showContactDialog(contact: contact),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteContact(contact.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}