# RongekaNotes - Smart Notes App

A comprehensive Flutter-based notes application with full CRUD functionality, categorization, favorites, and search capabilities.

## 🚀 Features

### Core Functionality
- **Create, Edit, Delete Notes**: Full CRUD operations for notes
- **Note Categorization**: Organize notes by custom categories
- **Favorite Notes**: Mark and manage favorite notes
- **Search & Filter**: Search notes by title, content, or category
- **Local Storage**: Persistent data storage using SharedPreferences

### Pages Implemented
1. **Splash Page** - Beautiful welcome screen with app branding
2. **Home Page** - Main notes grid with search, filtering, and actions
3. **Add/Edit Note** - Create new notes or edit existing ones
4. **View Note** - Detailed note view with actions
5. **Categories List** - Manage and view all categories
6. **Category Detail** - View notes within specific categories
7. **Search Notes** - Advanced search functionality
8. **Favorite Notes** - View and manage favorite notes
9. **Settings** - App configuration and data management

### User Experience Features
- **Dark Theme**: Modern dark UI design
- **Responsive Design**: Works on all screen sizes
- **Intuitive Navigation**: Easy-to-use drawer navigation
- **Real-time Updates**: Instant UI updates when data changes
- **Confirmation Dialogs**: Safe delete operations with confirmations
- **Toast Notifications**: User feedback for all actions

## 🛠️ Technical Implementation

### Architecture
- **State Management**: StatefulWidget with setState for local state
- **Data Persistence**: SharedPreferences for local storage
- **Navigation**: Named routes with argument passing
- **UI Components**: Material Design 3 components

### Key Components
- **Data Models**: JSON-based note structure
- **Storage Layer**: SharedPreferences abstraction
- **Navigation System**: Centralized routing
- **Search Engine**: Real-time filtering and search
- **Category Management**: Dynamic category extraction and management

### Code Quality
- **Proper Comments**: Comprehensive code documentation
- **Error Handling**: Graceful error handling throughout
- **Performance**: Efficient data loading and filtering
- **Maintainability**: Clean, organized code structure

## 📱 Screenshots

The app includes:
- Beautiful splash screen with animated icons
- Modern home page with search and filtering
- Intuitive note creation and editing
- Comprehensive category management
- Advanced search capabilities
- Settings page with app configuration
- Favorite notes management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Usage
1. **Create Notes**: Use the + button to create new notes
2. **Organize**: Assign categories to your notes
3. **Search**: Use the search bar to find specific notes
4. **Favorites**: Mark important notes as favorites
5. **Categories**: Manage your note categories
6. **Settings**: Customize the app to your preferences

## 🔧 Configuration

### Settings Available
- **Dark Mode**: Toggle between light and dark themes
- **Notifications**: Enable/disable push notifications
- **Auto Save**: Automatic note saving
- **Default Category**: Set default category for new notes
- **Notes Per Page**: Configure pagination settings

### Data Management
- **Export Notes**: Export all notes (placeholder for file export)
- **Import Notes**: Import notes from files (placeholder)
- **Clear All Data**: Reset the app completely

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── pages/
│   ├── splash_page.dart     # Welcome screen
│   ├── home_page.dart       # Main notes view
│   ├── add_edit.dart        # Note creation/editing
│   ├── view_note_page.dart  # Note detail view
│   ├── category_list.dart   # Categories management
│   ├── category_detail_page.dart # Category notes view
│   ├── search_page.dart     # Search functionality
│   ├── favorite_page.dart   # Favorite notes view
│   └── settings_page.dart   # App settings
```

## 🎯 Future Enhancements

- **Cloud Sync**: Google Drive, iCloud integration
- **File Attachments**: Images, documents, voice notes
- **Collaboration**: Share notes with others
- **Advanced Search**: Full-text search with filters
- **Themes**: Multiple color schemes
- **Backup**: Automated backup and restore
- **Widgets**: Home screen widgets
- **Notifications**: Reminders and alerts

## 🤝 Contributing

This is a demo project showcasing Flutter development best practices. Feel free to use this as a reference for your own projects.

## 📄 License

This project is for educational and demonstration purposes.

---

**Built with ❤️ using Flutter**

*RongekaNotes - Organize and manage your notes efficiently!*
