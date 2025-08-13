import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddEditNotePage extends StatefulWidget {
  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

// State class for Add/Edit Note page
class _AddEditNotePageState extends State<AddEditNotePage> {
  // Controllers for text fields
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final categoryController = TextEditingController(); // Controller for category
  bool isEditing = false; // Flag to determine if we're editing
  Map<String, dynamic>? originalNote; // Original note data for editing

  @override
  void initState() {
    super.initState();
    // Check if we're editing an existing note
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _loadNoteForEditing(args);
      } else {
        _loadDefaultCategory();
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  // Load note data for editing
  void _loadNoteForEditing(Map<String, dynamic> note) {
    setState(() {
      isEditing = true;
      originalNote = note;
      titleController.text = note['title'] ?? '';
      bodyController.text = note['content'] ?? '';
      categoryController.text = note['category'] ?? '';
    });
  }

  // Load default category from settings
  Future<void> _loadDefaultCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultCategory = prefs.getString('defaultCategory') ?? 'General';
    setState(() {
      categoryController.text = defaultCategory;
    });
  }

  // Save note to local storage (shared_preferences)
  Future<void> saveNote() async {
    // Validate input
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title for your note'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);

    if (isEditing && originalNote != null) {
      // Update existing note
      for (int i = 0; i < notes.length; i++) {
        if (notes[i]['title'] == originalNote!['title'] && 
            notes[i]['createdAt'] == originalNote!['createdAt']) {
          notes[i] = {
            'title': titleController.text.trim(),
            'content': bodyController.text.trim(),
            'category': categoryController.text.trim(),
            'createdAt': originalNote!['createdAt'], // Keep original creation date
            'isFavorite': originalNote!['isFavorite'] ?? false, // Keep favorite status
          };
          break;
        }
      }
    } else {
      // Create new note
      final note = {
        'title': titleController.text.trim(),
        'content': bodyController.text.trim(),
        'category': categoryController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'isFavorite': false,
      };
      notes.add(note);
    }

    await prefs.setString('notes', jsonEncode(notes));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Note updated successfully!' : 'Note created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add New Note'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteNote,
              tooltip: 'Delete Note',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.title),
              ),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            
            // Content input
            TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Enter note content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            
            // Category input
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Enter category name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Note preview
            if (titleController.text.isNotEmpty || bodyController.text.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (titleController.text.isNotEmpty)
                      Text(
                        titleController.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    if (bodyController.text.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        bodyController.text,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                    if (categoryController.text.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          Text(
                            'Category: ${categoryController.text}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      // Save button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: saveNote,
        icon: Icon(isEditing ? Icons.save : Icons.add),
        label: Text(isEditing ? 'Update' : 'Save'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Delete note functionality
  Future<void> _deleteNote() async {
    if (originalNote == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete "${originalNote!['title']}"?'),
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
      final prefs = await SharedPreferences.getInstance();
      final notesString = prefs.getString('notes') ?? '[]';
      final List notes = jsonDecode(notesString);
      
      // Remove the note
      notes.removeWhere((n) => 
        n['title'] == originalNote!['title'] && 
        n['createdAt'] == originalNote!['createdAt']
      );
      
      await prefs.setString('notes', jsonEncode(notes));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note deleted successfully!'),
          backgroundColor: Colors.red,
        ),
      );
      
      Navigator.pop(context);
    }
  }
}
