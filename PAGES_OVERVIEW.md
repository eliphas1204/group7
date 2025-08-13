# RongekaNotes App: Page-by-Page Technical Overview

This document provides a clear, presentable explanation of each main page in the RongekaNotes Flutter app.

---

## Splash Page (`splash_page.dart`)
**Purpose:** Displays a creative splash screen for 2 seconds, then navigates to the Home page.

**Key Features:**
- Uses a `StatefulWidget` to allow timed navigation.
- Utilizes `Future.delayed` for the splash delay.
- Employs a `Stack` and `Positioned` widgets to layer icons, creating a fun, memorable visual.

**Sample Code:**
```dart
Future.delayed(Duration(seconds: 2), () {
  Navigator.pushReplacementNamed(context, "/home");
});
```

---

## Main App Structure (`main.dart`)
**Purpose:** Sets up the app’s navigation, theme, and drawer menu.

**Key Features:**
- The `MaterialApp` widget defines the app’s title, theme, and named routes.
- The `Drawer` widget provides navigation links to all main pages.
- The `showAboutDialog` function displays app information and features.

**Sample Code:**
```dart
MaterialApp(
  title: 'RongekaNotes',
  theme: ThemeData.dark(),
  initialRoute: '/splash',
  routes: {
    '/splash': (context) => SplashPage(),
    '/home': (context) => HomePage(),
    // ...other routes
  },
)
```

---

## Home Page (`home_page.dart`)
**Purpose:** Lists all notes/tasks with their categories and due dates in a visually appealing format.

**Key Features:**
- Uses `ListView.builder` and `Card` for a modern, scrollable list.
- Loads notes from local storage using `shared_preferences`.
- Provides edit and delete actions for each note.

**Sample Code:**
```dart
ListView.builder(
  itemCount: notes.length,
  itemBuilder: (context, index) {
    final note = notes[index];
    return Card(
      child: ListTile(
        title: Text(note.title),
        subtitle: Text('${note.category} • Due: ${note.dueDate}'),
      ),
    );
  },
)
```

---

## Add/Edit Note Page (`add_edit_note_page.dart`)
**Purpose:** Allows users to add or edit a note, including title, content, category, and due date.

**Key Features:**
- Uses `TextEditingController` for text fields.
- Includes a `DropdownButton` for category selection.
- Integrates `showDatePicker` for due date selection.
- Saves notes to local storage.

**Sample Code:**
```dart
DropdownButton<String>(
  value: selectedCategory,
  items: categories.map((cat) => DropdownMenuItem(
    value: cat,
    child: Text(cat),
  )).toList(),
  onChanged: (value) {
    setState(() {
      selectedCategory = value!;
    });
  },
)
```

---

## View Note Page (`view_note_page.dart`)
**Purpose:** Displays the full details of a selected note.

**Key Features:**
- Receives note data via route arguments.
- Presents all note fields in a readable format.

**Sample Code:**
```dart
Text(note.content)
```

---

## Categories Pages (`categories_list_page.dart`, `category_detail_page.dart`)
**Purpose:** Lists all categories and shows notes within a selected category.

**Key Features:**
- Uses `ListView` for category display.
- Filters notes by category.

**Sample Code:**
```dart
final notesInCategory = notes.where((note) => note.category == selectedCategory).toList();
```

---

## Search Page (`search_page.dart`)
**Purpose:** Enables searching notes by title, content, or category.

**Key Features:**
- Uses a `TextField` for search input.
- Filters notes in real time as the user types.

**Sample Code:**
```dart
onChanged: (query) {
  setState(() {
    searchResults = notes.where((note) =>
      note.title.toLowerCase().contains(query.toLowerCase()) ||
      note.content.toLowerCase().contains(query.toLowerCase()) ||
      note.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  });
}
```

---

## Favorites Page (`favorites_page.dart`)
**Purpose:** Displays notes marked as favorites.

**Key Features:**
- Filters notes by a `favorite` property.

**Sample Code:**
```dart
final favoriteNotes = notes.where((note) => note.isFavorite).toList();
```

---

## Settings Page (`settings_page.dart`)
**Purpose:** Allows users to change app settings, such as theme.

**Key Features:**
- Uses `SwitchListTile` for toggles.
- Saves settings using `shared_preferences`.

**Sample Code:**
```dart
SwitchListTile(
  title: Text('Dark Theme'),
  value: isDarkTheme,
  onChanged: (value) {
    setState(() {
      isDarkTheme = value;
      // Save to shared_preferences
    });
  },
)
```

---

## Dart/Flutter Syntax Highlights
- `StatefulWidget` vs `StatelessWidget`: Use `StatefulWidget` when the UI can change.
- `setState()`: Triggers a UI update.
- `Navigator`: Handles navigation between pages.
- `Future` and `async/await`: For delayed or asynchronous actions.
- `shared_preferences`: For simple local storage.

---

This document is suitable for presentations or technical documentation to help teams and stakeholders understand the structure and logic of the RongekaNotes Flutter app.
