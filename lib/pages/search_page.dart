import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List allNotes = [];
  List filteredNotes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Load all notes from local storage
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);
    setState(() {
      allNotes = notes;
      filteredNotes = notes;
    });
  }

  // Filter notes by search query
  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredNotes = allNotes.where((note) {
        final title = (note['title'] ?? '').toLowerCase();
        final content = (note['content'] ?? '').toLowerCase();
        final category = (note['category'] ?? '').toLowerCase();
        return title.contains(query) ||
            content.contains(query) ||
            category.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Notes')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredNotes.isEmpty
                  ? Center(child: Text('No results'))
                  : ListView.builder(
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, idx) {
                        final note = filteredNotes[idx];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: Icon(Icons.note, color: Colors.blue),
                            title: Text(note['title'] ?? ''),
                            subtitle: Text(
                              'Category: ${note['category'] ?? 'None'}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
