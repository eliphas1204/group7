import 'package:demo3/main.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Notes')),
      body: Center(child: Text('Home Page')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_edit_note'),
        child: Icon(Icons.add),
      ),
      drawer: AppDrawer(),
    );
  }
}
