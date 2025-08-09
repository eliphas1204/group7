import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Notes')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Search')),
            SizedBox(height: 20),
            Expanded(child: Center(child: Text('Search Results'))),
          ],
        ),
      ),
    );
  }
}
