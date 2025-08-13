import 'package:rongekanotes/pages/category_list.dart';
import 'package:rongekanotes/pages/category_detail_page.dart';
import 'package:rongekanotes/pages/favorite_page.dart';
import 'package:rongekanotes/pages/home_page.dart';
import 'package:rongekanotes/pages/search_page.dart';
import 'package:rongekanotes/pages/settings_page.dart';
import 'package:rongekanotes/pages/splash_page.dart';
import 'package:rongekanotes/pages/view_note_page.dart';
import 'package:rongekanotes/pages/add_edit.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(NotesApp());
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // App header
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_alt_rounded, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'RongekaNotes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Smart Note Management',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Navigation items
          ListTile(
            leading: Icon(Icons.home, color: Colors.blue.shade700),
            title: Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            leading: Icon(Icons.category, color: Colors.green.shade700),
            title: Text('Categories'),
            onTap: () => Navigator.pushNamed(context, '/categories'),
          ),
          ListTile(
            leading: Icon(Icons.favorite, color: Colors.red.shade700),
            title: Text('Favorites'),
            onTap: () => Navigator.pushNamed(context, '/favorites'),
          ),
          ListTile(
            leading: Icon(Icons.search, color: Colors.orange.shade700),
            title: Text('Search'),
            onTap: () => Navigator.pushNamed(context, '/search'),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey.shade700),
            title: Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),

          Divider(),

          // About section
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue.shade500),
            title: Text('About'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  // Show about dialog
  void _showAboutDialog(BuildContext context) {
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
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RongekaNotes - Smart Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/home': (context) => HomePage(),
        '/add_edit_note': (context) => AddEditNotePage(),
        '/view_note': (context) => ViewNotePage(
          note:
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>? ??
              {},
        ),
        '/categories': (context) => CategoriesPage(),
        '/category_detail': (context) => CategoryDetailPage(),
        '/search': (context) => SearchPage(),
        '/favorites': (context) => FavoritePage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
