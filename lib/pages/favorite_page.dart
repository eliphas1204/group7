import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritePage extends StatefulWidget {
  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List favoriteNotes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoriteNotes();
  }

  // Load all favorite notes from storage
  Future<void> loadFavoriteNotes() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List allNotes = jsonDecode(notesString);
    
    setState(() {
      favoriteNotes = allNotes.where((note) => 
        note['isFavorite'] == true
      ).toList();
      isLoading = false;
    });
  }

  // Toggle favorite status (remove from favorites)
  Future<void> _removeFromFavorites(int index) async {
    final note = favoriteNotes[index];
    
    // Update local state
    setState(() {
      note['isFavorite'] = false;
    });
    
    // Update storage
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List allNotes = jsonDecode(notesString);
    
    // Find and update the note
    for (int i = 0; i < allNotes.length; i++) {
      if (allNotes[i]['title'] == note['title'] && 
          allNotes[i]['createdAt'] == note['createdAt']) {
        allNotes[i]['isFavorite'] = false;
        break;
      }
    }
    
    await prefs.setString('notes', jsonEncode(allNotes));
    
    // Remove from local favorites list
    setState(() {
      favoriteNotes.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note removed from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _addBackToFavorites(note),
        ),
      ),
    );
  }

  // Add note back to favorites (undo functionality)
  Future<void> _addBackToFavorites(Map<String, dynamic> note) async {
    // Update local state
    setState(() {
      note['isFavorite'] = true;
      favoriteNotes.add(note);
    });
    
    // Update storage
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List allNotes = jsonDecode(notesString);
    
    // Find and update the note
    for (int i = 0; i < allNotes.length; i++) {
      if (allNotes[i]['title'] == note['title'] && 
          allNotes[i]['createdAt'] == note['createdAt']) {
        allNotes[i]['isFavorite'] = true;
        break;
      }
    }
    
    await prefs.setString('notes', jsonEncode(allNotes));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note added back to favorites')),
    );
  }

  // Delete note completely
  Future<void> _deleteNote(int index) async {
    final note = favoriteNotes[index];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note['title']}"? This action cannot be undone.'),
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
        favoriteNotes.removeAt(index);
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
        SnackBar(content: Text('Note deleted permanently')),
      );
    }
  }

  // Navigate to view note page
  void _viewNote(Map<String, dynamic> note) {
    Navigator.pushNamed(
      context,
      '/view_note',
      arguments: note,
    ).then((_) {
      // Reload favorites when returning from view page
      loadFavoriteNotes();
    });
  }

  // Navigate to edit note page
  void _editNote(Map<String, dynamic> note) {
    Navigator.pushNamed(
      context,
      '/add_edit_note',
      arguments: note,
    ).then((_) {
      // Reload favorites when returning from edit page
      loadFavoriteNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadFavoriteNotes,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteNotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No favorite notes yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mark notes as favorites to see them here',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        icon: Icon(Icons.home),
                        label: Text('Go to Notes'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header with count
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border(bottom: BorderSide(color: Colors.red.shade200)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade700,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '${favoriteNotes.length} Favorite Note${favoriteNotes.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Tap heart to remove from favorites',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Favorite notes list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: favoriteNotes.length,
                        itemBuilder: (context, index) {
                          final note = favoriteNotes[index];
                          
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade200,
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red.shade700,
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
                                        // Category chip
                                        if (note['category'] != null && note['category'].isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.category, size: 12, color: Colors.blue.shade700),
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Remove from favorites
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removeFromFavorites(index),
                                      tooltip: 'Remove from favorites',
                                    ),
                                    // View note
                                    IconButton(
                                      icon: Icon(Icons.visibility, color: Colors.blue),
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
                                      icon: Icon(Icons.delete, color: Colors.red.shade400),
                                      onPressed: () => _deleteNote(index),
                                      tooltip: 'Delete note',
                                    ),
                                  ],
                                ),
                                onTap: () => _viewNote(note),
                              ),
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
