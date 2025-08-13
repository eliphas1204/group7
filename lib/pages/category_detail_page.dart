import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryDetailPage extends StatefulWidget {
  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List categoryNotes = [];
  String categoryName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Get category name from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        categoryName = args;
        loadCategoryNotes();
      }
    });
  }

  // Load notes for the specific category
  Future<void> loadCategoryNotes() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List allNotes = jsonDecode(notesString);
    
    setState(() {
      categoryNotes = allNotes.where((note) => 
        note['category'] == categoryName
      ).toList();
      isLoading = false;
    });
  }

  // Delete note from category
  Future<void> _deleteNote(int index) async {
    final note = categoryNotes[index];
    
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
        categoryNotes.removeAt(index);
      });
      
      // Update storage
      final prefs = await SharedPreferences.getInstance();
      final notesString = prefs.getString('notes') ?? '[]';
      final List allNotes = jsonDecode(notesString);
      
      // Find and remove the note from all notes
      allNotes.removeWhere((n) => 
        n['title'] == note['title'] && 
        n['createdAt'] == note['createdAt']
      );
      
      await prefs.setString('notes', jsonEncode(allNotes));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note deleted!')),
      );
    }
  }

  // Toggle favorite status
  Future<void> _toggleFavorite(int index) async {
    final note = categoryNotes[index];
    
    // Update local state
    setState(() {
      note['isFavorite'] = !(note['isFavorite'] ?? false);
    });
    
    // Update storage
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List allNotes = jsonDecode(notesString);
    
    // Find and update the note
    for (int i = 0; i < allNotes.length; i++) {
      if (allNotes[i]['title'] == note['title'] && 
          allNotes[i]['createdAt'] == note['createdAt']) {
        allNotes[i]['isFavorite'] = note['isFavorite'];
        break;
      }
    }
    
    await prefs.setString('notes', jsonEncode(allNotes));
  }

  // Navigate to view note page
  void _viewNote(Map<String, dynamic> note) {
    Navigator.pushNamed(
      context,
      '/view_note',
      arguments: note,
    ).then((_) {
      // Reload notes when returning from view page
      loadCategoryNotes();
    });
  }

  // Navigate to edit note page
  void _editNote(Map<String, dynamic> note) {
    Navigator.pushNamed(
      context,
      '/add_edit_note',
      arguments: note,
    ).then((_) {
      // Reload notes when returning from edit page
      loadCategoryNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category: $categoryName'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadCategoryNotes,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : categoryNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notes in "$categoryName"',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first note to this category',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/add_edit_note');
                          loadCategoryNotes();
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Note'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Category info header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Text(
                                  '${categoryNotes.length} note${categoryNotes.length == 1 ? '' : 's'}',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/add_edit_note');
                              loadCategoryNotes();
                            },
                            icon: Icon(Icons.add),
                            label: Text('Add Note'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Notes list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: categoryNotes.length,
                        itemBuilder: (context, index) {
                          final note = categoryNotes[index];
                          
                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade200,
                                child: Icon(
                                  note['isFavorite'] == true 
                                    ? Icons.favorite 
                                    : Icons.note,
                                  color: note['isFavorite'] == true 
                                    ? Colors.red 
                                    : Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                note['title'] ?? 'Untitled',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Spacer(),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Favorite toggle
                                  IconButton(
                                    icon: Icon(
                                      note['isFavorite'] == true 
                                        ? Icons.favorite 
                                        : Icons.favorite_border,
                                      color: note['isFavorite'] == true ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () => _toggleFavorite(index),
                                  ),
                                  // View note
                                  IconButton(
                                    icon: Icon(Icons.visibility, color: Colors.blue),
                                    onPressed: () => _viewNote(note),
                                  ),
                                  // Edit note
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _editNote(note),
                                  ),
                                  // Delete note
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteNote(index),
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
