import 'package:rongekanotes/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage
class _HomePageState extends State<HomePage> {
  List allNotes = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // Load all notes from local storage
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);

    setState(() {
      allNotes = notes;
      _extractCategories(notes);
    });
  }

  // Extract unique categories from notes
  void _extractCategories(List notes) {
    Set<String> uniqueCategories = {'All'};
    for (var note in notes) {
      if (note['category'] != null && note['category'].isNotEmpty) {
        uniqueCategories.add(note['category']);
      }
    }
    categories = uniqueCategories.toList()..sort();
  }

  // Get filtered notes based on search and category
  List get filteredNotes {
    return allNotes.where((note) {
      final matchesSearch =
          searchQuery.isEmpty ||
          note['title'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          note['content'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          note['category'].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      final matchesCategory =
          selectedCategory == 'All' || note['category'] == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Toggle favorite status
  Future<void> _toggleFavorite(int index) async {
    final note = allNotes[index];

    // Update local state
    setState(() {
      note['isFavorite'] = !(note['isFavorite'] ?? false);
    });

    // Update storage
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);

    // Find and update the note
    for (int i = 0; i < notes.length; i++) {
      if (notes[i]['title'] == note['title'] &&
          notes[i]['createdAt'] == note['createdAt']) {
        notes[i]['isFavorite'] = note['isFavorite'];
        break;
      }
    }

    await prefs.setString('notes', jsonEncode(notes));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          note['isFavorite']
              ? 'Added to favorites!'
              : 'Removed from favorites!',
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Navigate to view note page
  void _viewNote(Map<String, dynamic> note) {
    Navigator.pushNamed(context, '/view_note', arguments: note).then((_) {
      // Reload notes when returning from view page
      loadNotes();
    });
  }

  // Navigate to edit note page
  void _editNote(Map<String, dynamic> note) {
    Navigator.pushNamed(context, '/add_edit_note', arguments: note).then((_) {
      // Reload notes when returning from edit page
      loadNotes();
    });
  }

  // Delete note
  Future<void> _deleteNote(int index) async {
    final note = allNotes[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Remove from local list
      setState(() {
        allNotes.removeAt(index);
      });

      // Update storage
      final prefs = await SharedPreferences.getInstance();
      final notesString = prefs.getString('notes') ?? '[]';
      final List notes = jsonDecode(notesString);

      // Find and remove the note from all notes
      notes.removeWhere(
        (n) =>
            n['title'] == note['title'] && n['createdAt'] == note['createdAt'],
      );

      await prefs.setString('notes', jsonEncode(notes));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note deleted successfully!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RongekaNotes - Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadNotes,
            tooltip: 'Refresh Notes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Notes',
                    hintText: 'Search by title, content, or category...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12),

                // Category filter
                Row(
                  children: [
                    Text(
                      'Category: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          }
                        },
                        items: categories.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notes count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.note, color: Colors.blue.shade700, size: 20),
                SizedBox(width: 8),
                Text(
                  '${filteredNotes.length} note${filteredNotes.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (selectedCategory != 'All') ...[
                  SizedBox(width: 8),
                  Text(
                    'in "$selectedCategory"',
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Notes list
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isNotEmpty || selectedCategory != 'All'
                              ? Icons.search_off
                              : Icons.note_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty || selectedCategory != 'All'
                              ? 'No notes found'
                              : 'No notes yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          searchQuery.isNotEmpty || selectedCategory != 'All'
                              ? 'Try adjusting your search or category filter'
                              : 'Create your first note using the + button below',
                          style: TextStyle(color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                        if (searchQuery.isEmpty &&
                            selectedCategory == 'All') ...[
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/add_edit_note',
                              );
                              loadNotes();
                            },
                            icon: Icon(Icons.add),
                            label: Text('Create Note'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, idx) {
                      final note = filteredNotes[idx];

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: note['isFavorite'] == true
                                ? Colors.red.shade200
                                : Colors.blue.shade200,
                            child: Icon(
                              note['isFavorite'] == true
                                  ? Icons.favorite
                                  : Icons.note,
                              color: note['isFavorite'] == true
                                  ? Colors.red
                                  : Colors.white,
                            ),
                          ),
                          title: Text(
                            note['title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                note['content'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  // Category chip
                                  if (note['category'] != null &&
                                      note['category'].isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.category,
                                            size: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            note['category'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Spacer(),
                                  // Creation date
                                  Text(
                                    _formatDate(note['createdAt']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          // Actions
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Favorite toggle
                              IconButton(
                                icon: Icon(
                                  note['isFavorite'] == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: note['isFavorite'] == true
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () =>
                                    _toggleFavorite(allNotes.indexOf(note)),
                                tooltip: note['isFavorite'] == true
                                    ? 'Remove from favorites'
                                    : 'Add to favorites',
                              ),
                              // View note
                              IconButton(
                                icon: Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _viewNote(note),
                                tooltip: 'View note',
                              ),
                              // Edit note
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editNote(note),
                                tooltip: 'Edit note',
                              ),
                              // Delete note
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteNote(allNotes.indexOf(note)),
                                tooltip: 'Delete note',
                              ),
                            ],
                          ),
                          onTap: () => _viewNote(note),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Add note button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add_edit_note');
          loadNotes();
        },
        icon: Icon(Icons.add),
        label: Text('Add Note'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
    );
  }

  // Format date for display
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
