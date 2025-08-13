import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = true;
  bool showNotifications = true;
  bool autoSave = true;
  String defaultCategory = 'General';
  int notesPerPage = 20;

  final List<String> categoryOptions = [
    'General',
    'Work',
    'Personal',
    'Ideas',
    'Shopping',
    'Journal',
    'Study',
    'Projects',
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // Load saved settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      showNotifications = prefs.getBool('showNotifications') ?? true;
      autoSave = prefs.getBool('autoSave') ?? true;
      defaultCategory = prefs.getString('defaultCategory') ?? 'General';
      notesPerPage = prefs.getInt('notesPerPage') ?? 20;
    });
  }

  // Save settings
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setBool('showNotifications', showNotifications);
    await prefs.setBool('autoSave', autoSave);
    await prefs.setString('defaultCategory', defaultCategory);
    await prefs.setInt('notesPerPage', notesPerPage);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Settings saved successfully!')));
  }

  // Export notes data
  Future<void> _exportNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);

    // Create export data
    final exportData = {
      'exportDate': DateTime.now().toIso8601String(),
      'totalNotes': notes.length,
      'notes': notes,
    };

    // In a real app, you would save this to a file or share it
    // For now, we'll just show the data in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Export Date: ${exportData['exportDate']}'),
              Text('Total Notes: ${exportData['totalNotes']}'),
              SizedBox(height: 16),
              Text(
                'Note: In a production app, this would export to a file or cloud service.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Import notes data
  Future<void> _importNotes() async {
    // In a real app, you would read from a file
    // For now, we'll show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import Notes'),
        content: Text(
          'Note: In a production app, this would allow you to import notes from a file or cloud service.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Clear all data
  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'Are you sure you want to delete ALL notes and settings? This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset local state
      setState(() {
        isDarkMode = true;
        showNotifications = true;
        autoSave = true;
        defaultCategory = 'General';
        notesPerPage = 20;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All data cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Show app information
  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'RongekaNotes',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.note_alt_rounded,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        Text('A smart note management app.'),
        SizedBox(height: 8),
        Text('Organize and manage your notes efficiently!'),
        SizedBox(height: 16),
        Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('• Create, edit, and delete notes'),
        Text('• Organize notes by categories'),
        Text('• Mark notes as favorites'),
        Text('• Search through notes'),
        Text('• Dark theme support'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSectionHeader('App Settings', Icons.settings),
            SizedBox(height: 16),

            // Dark Mode Toggle
            SwitchListTile(
              title: Text('Dark Mode'),
              subtitle: Text('Use dark theme for the app'),
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
              secondary: Icon(Icons.dark_mode),
            ),

            // Notifications Toggle
            SwitchListTile(
              title: Text('Show Notifications'),
              subtitle: Text('Enable push notifications for reminders'),
              value: showNotifications,
              onChanged: (value) {
                setState(() {
                  showNotifications = value;
                });
              },
              secondary: Icon(Icons.notifications),
            ),

            // Auto Save Toggle
            SwitchListTile(
              title: Text('Auto Save'),
              subtitle: Text('Automatically save notes as you type'),
              value: autoSave,
              onChanged: (value) {
                setState(() {
                  autoSave = value;
                });
              },
              secondary: Icon(Icons.save),
            ),

            SizedBox(height: 24),

            // Note Settings Section
            _buildSectionHeader('Note Settings', Icons.note),
            SizedBox(height: 16),

            // Default Category
            ListTile(
              title: Text('Default Category'),
              subtitle: Text('Category for new notes: $defaultCategory'),
              leading: Icon(Icons.category),
              trailing: DropdownButton<String>(
                value: defaultCategory,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      defaultCategory = newValue;
                    });
                  }
                },
                items: categoryOptions.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            // Notes Per Page
            ListTile(
              title: Text('Notes Per Page'),
              subtitle: Text('Number of notes to show: $notesPerPage'),
              leading: Icon(Icons.list),
              trailing: DropdownButton<int>(
                value: notesPerPage,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      notesPerPage = newValue;
                    });
                  }
                },
                items: [10, 20, 50, 100].map<DropdownMenuItem<int>>((
                  int value,
                ) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 24),

            // Data Management Section
            _buildSectionHeader('Data Management', Icons.storage),
            SizedBox(height: 16),

            // Export Notes
            ListTile(
              title: Text('Export Notes'),
              subtitle: Text('Export all notes to a file'),
              leading: Icon(Icons.upload),
              onTap: _exportNotes,
            ),

            // Import Notes
            ListTile(
              title: Text('Import Notes'),
              subtitle: Text('Import notes from a file'),
              leading: Icon(Icons.download),
              onTap: _importNotes,
            ),

            // Clear All Data
            ListTile(
              title: Text('Clear All Data'),
              subtitle: Text('Delete all notes and settings'),
              leading: Icon(Icons.delete_forever, color: Colors.red),
              onTap: _clearAllData,
            ),

            SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About', Icons.info),
            SizedBox(height: 16),

            // App Info
            ListTile(
              title: Text('App Information'),
              subtitle: Text('Version 1.0.0'),
              leading: Icon(Icons.info),
              onTap: _showAppInfo,
            ),

            // Developer Info
            ListTile(
              title: Text('Developer'),
              subtitle: Text('Built with Flutter'),
              leading: Icon(Icons.developer_mode),
            ),

            SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: Icon(Icons.save),
                label: Text('Save All Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    );
  }
}
