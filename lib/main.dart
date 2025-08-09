import 'package:demo3/pages/category%20_list.dart';
import 'package:demo3/pages/category_detail_page.dart';
import 'package:demo3/pages/favorite_page.dart';
import 'package:demo3/pages/home_page.dart';
import 'package:demo3/pages/search_page.dart';
import 'package:demo3/pages/settings_page.dart';
import 'package:demo3/pages/splash_page.dart';
import 'package:demo3/pages/view_note_page.dart';
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
          DrawerHeader(child: Text('Menu')),
          ListTile(
            title: Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            title: Text('Categories'),
            onTap: () => Navigator.pushNamed(context, '/categories'),
          ),
          ListTile(
            title: Text('Favorites'),
            onTap: () => Navigator.pushNamed(context, '/favorites'),
          ),
          ListTile(
            title: Text('Search'),
            onTap: () => Navigator.pushNamed(context, '/search'),
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          ListTile(
            title: Text('About'),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
    );
  }
}

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/home': (context) => HomePage(),

        '/view_note': (context) => ViewNotePage(),
        '/categories': (context) => CategoriesPage(),
        '/category_detail': (context) => CategoryDetailPage(),
        '/search': (context) => SearchPage(),
        '/favorites': (context) => FavoritePage(),
        '/settings': (context) => SettingsPage(),
      },
    );
  }
}
