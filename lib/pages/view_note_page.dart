import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ViewNotePage extends StatefulWidget {
  final Map<String, dynamic> note; // Note data to display

  const ViewNotePage({Key? key, required this.note}) : super(key: key);

  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  Map<String, dynamic> get note => widget.note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Note'),
        actions: [
          // Favorite toggle button
          IconButton(
            icon: Icon(
              note['isFavorite'] == true 
                ? Icons.favorite 
                : Icons.favorite_border,
              color: note['isFavorite'] == true ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(),
          ),
          // Edit button
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editNote(),
          ),
          // Share button
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareNote(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note title
            Text(
              note['title'] ?? 'Untitled',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            
            // Note metadata row
            Row(
              children: [
                // Category chip
                if (note['category'] != null && note['category'].isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.blue.shade700),
                        SizedBox(width: 4),
                        Text(
                          note['category'],
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24),
            
            // Note content
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                note['content'] ?? 'No content',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Creation date
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 8),
                Text(
                  'Created: ${_formatDate(note['createdAt'])}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);
    
    // Find and update the note
    for (int i = 0; i < notes.length; i++) {
      if (notes[i]['title'] == note['title'] && 
          notes[i]['createdAt'] == note['createdAt']) {
        notes[i]['isFavorite'] = !(notes[i]['isFavorite'] ?? false);
        break;
      }
    }
    
    await prefs.setString('notes', jsonEncode(notes));
    
    // Update the local note data
    note['isFavorite'] = !(note['isFavorite'] ?? false);
    
    // Rebuild the widget
    setState(() {});
  }

  // Navigate to edit page
  void _editNote() {
    Navigator.pushNamed(
      context, 
      '/add_edit_note',
      arguments: note, // Pass note data for editing
    );
  }

  // Share note functionality (placeholder)
  void _shareNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Format date for display
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
