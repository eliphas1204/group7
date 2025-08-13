import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoriesPage extends StatefulWidget {
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Map<String, dynamic>> categories = [];
  List allNotes = [];
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // Load notes and extract unique categories
  Future<void> loadData() async {
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
    Map<String, int> categoryCounts = {};
    
    for (var note in notes) {
      if (note['category'] != null && note['category'].isNotEmpty) {
        categoryCounts[note['category']] = (categoryCounts[note['category']] ?? 0) + 1;
      }
    }
    
    categories = categoryCounts.entries.map((entry) => {
      'name': entry.key,
      'count': entry.value,
      'color': _getCategoryColor(entry.key),
    }).toList();
    
    // Sort by count (descending)
    categories.sort((a, b) => b['count'].compareTo(a['count']));
  }

  // Generate consistent color for each category
  Color _getCategoryColor(String categoryName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    
    int hash = categoryName.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Add new category
  Future<void> _addCategory() async {
    if (_categoryController.text.trim().isEmpty) return;
    
    final newCategory = _categoryController.text.trim();
    
    // Check if category already exists
    if (categories.any((cat) => cat['name'].toLowerCase() == newCategory.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category already exists!')),
      );
      return;
    }
    
    // Add category to notes (optional - you can create empty categories)
    final prefs = await SharedPreferences.getInstance();
    final notesString = prefs.getString('notes') ?? '[]';
    final List notes = jsonDecode(notesString);
    
    // Add a placeholder note for the new category
    notes.add({
      'title': 'Welcome to $newCategory',
      'content': 'This is your first note in the $newCategory category. Start adding your notes here!',
      'category': newCategory,
      'createdAt': DateTime.now().toIso8601String(),
      'isFavorite': false,
    });
    
    await prefs.setString('notes', jsonEncode(notes));
    
    // Reload data
    await loadData();
    
    // Clear input
    _categoryController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category "$newCategory" created!')),
    );
  }

  // Delete category
  Future<void> _deleteCategory(String categoryName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"? All notes in this category will be moved to "Uncategorized".'),
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
      
      // Move all notes from this category to "Uncategorized"
      for (var note in notes) {
        if (note['category'] == categoryName) {
          note['category'] = 'Uncategorized';
        }
      }
      
      await prefs.setString('notes', jsonEncode(notes));
      await loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$categoryName" deleted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Add category section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'New Category Name',
                      hintText: 'Enter category name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.category),
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: Icon(Icons.add),
                  label: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Categories list
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No categories yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first category above',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: category['color'].withOpacity(0.2),
                            child: Icon(
                              Icons.category,
                              color: category['color'],
                            ),
                          ),
                          title: Text(
                            category['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${category['count']} note${category['count'] == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // View category button
                              IconButton(
                                icon: Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () => _viewCategory(category['name']),
                              ),
                              // Delete category button
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCategory(category['name']),
                              ),
                            ],
                          ),
                          onTap: () => _viewCategory(category['name']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Navigate to category detail page
  void _viewCategory(String categoryName) {
    Navigator.pushNamed(
      context,
      '/category_detail',
      arguments: categoryName,
    );
  }
}
