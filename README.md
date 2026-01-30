# TrackWise - Personal Expense Tracker 💰

A comprehensive Flutter application for tracking expenses with advanced features including budget management, recurring expenses, shared expenses (Splitwise), and analytics. Built with a clean, modern UI and smooth animations.

## 📱 About the App

**TrackWise** is a full-featured expense tracking application built with Flutter, supporting Web, Windows, Android, and iOS platforms. It uses SharedPreferences for persistent local storage and demonstrates key mobile development concepts including state management, gestures, animations, and navigation.

### ✨ Features

- **Dashboard Overview**: View total expenses with an animated summary card and recent expense list
- **Add/Edit Expenses**: Full CRUD operations with validation and category selection
- **Search & Filter**: Easily find expenses with search functionality
- **Analytics Dashboard**: Visual charts and statistics for expense tracking
- **Budget Management**: Set and track budgets for different categories
- **Recurring Expenses**: Manage subscriptions and regular payments
- **Splitwise Integration**: Track shared expenses with friends and balance settlements
- **Calendar View**: View expenses organized by date
- **User Management**: Add and manage multiple users for shared expense tracking
- **Category Organization**: Multiple categories (Food, Travel, Bills, Shopping, Other) with color-coded icons
- **Persistent Storage**: All data saved locally using SharedPreferences
- **Multi-Platform**: Runs on Web, Windows, Android, and iOS
- **Smooth Animations**: Animated transitions, button press feedback, and list updates

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point with theme configuration
├── models/
│   ├── expense.dart                   # Expense data model
│   ├── recurring_expense.dart         # Recurring expense model
│   ├── shared_expense.dart            # Shared expense model
│   ├── budget.dart                    # Budget model
│   └── user.dart                      # User model for shared expenses
├── screens/
│   ├── main_navigation_screen.dart    # Bottom navigation with 5 tabs
│   ├── home_screen.dart               # Main dashboard with expense list
│   ├── add_expense_screen.dart        # Form to add new expenses
│   ├── edit_expense_screen.dart       # Form to edit existing expenses
│   ├── analytics_screen.dart          # Charts and statistics
│   ├── budget_screen.dart             # Budget management
│   ├── recurring_screen.dart          # Recurring expense management
│   ├── splitwise_screen.dart          # Shared expenses overview
│   ├── split_expense_screen.dart      # Add/edit shared expenses
│   ├── balances_screen.dart           # User balance settlements
│   ├── users_screen.dart              # User management
│   └── calendar_screen.dart           # Calendar view of expenses
├── services/
│   └── storage_service.dart           # SharedPreferences storage layer
└── widgets/
    └── (Reusable UI components)
```

## 🎨 UI/UX Highlights

- **Modern Design**: Soft color palette with purple accent (#6C63FF)
- **Material 3**: Latest Material Design guidelines
- **Rounded Corners**: Cards and buttons with 12px border radius
- **Responsive Layout**: Proper padding and spacing throughout
- **Visual Feedback**: Animations and snackbars for user actions

## 🧠 Technical Implementation

### State Management
- Uses `StatefulWidget` and `setState()`
- In-memory data management with persistent storage
- Data loaded from SharedPreferences on app start
- No external state management packages

### Storage Layer
- **SharedPreferences** for cross-platform local storage
- Supports Web, Desktop, and Mobile platforms
- JSON serialization for complex data models
- Persistent data across app restarts

### Data Models
```dart
class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  // JSON serialization
}

class RecurringExpense {
  final String id;
  final String title;
  final double amount;
  final String frequency; // daily, weekly, monthly
  final DateTime startDate;
}

class Budget {
  final String id;
  final String category;
  final double limit;
  final DateTime month;
}

class SharedExpense {
  final String id;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime date;
}

class User {
  final String id;
  final String name;
  final String email;
}
```

### Gestures
- `Dismissible` widget for swipe-to-delete
- `InkWell` and `GestureDetector` for tap interactions
- Pull-to-refresh functionality
- Confirmation dialogs before deletion

### Animations
- `AnimatedDefaultTextStyle` for text updates
- `FadeTransition` and `SlideTransition` for screen transitions
- `ScaleTransition` for button press feedback
- `AnimationController` with curves for smooth effects

### Navigation
- Bottom Navigation Bar with 5 tabs (Home, Analytics, Budget, Recurring, Splitwise)
- `Navigator.push()` and `Navigator.pop()` for screen transitions
- Data passing between screens
- Result handling from navigation

## 🚀 Running the App

1. Ensure Flutter is installed:
   ```bash
   flutter --version
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. For specific platform:
   ```bash
   flutter run -d chrome        # Web
   flutter run -d windows       # Windows
   flutter run -d emulator-id   # Android/iOS
   ```

## 📚 Key Concepts Demonstrated

## 📚 Key Concepts Demonstrated

### Core Flutter Widgets
- Scaffold, AppBar, FloatingActionButton, BottomNavigationBar
- ListView, GridView, Card, Container
- TextFormField, DropdownButton, DatePicker
- Dialog, SnackBar, AlertDialog
- TabBar, TabBarView

### Layouts
- Column, Row, Expanded, Flexible
- Padding, SizedBox, Center
- Stack and Positioned widgets
- Responsive design patterns

### Forms & Validation
- Form with GlobalKey
- TextEditingController
- Input validators
- Numeric keyboard
- Date and time selection

### Material Design
- Theme configuration with Material 3
- Color schemes
- Elevation and shadows
- Icon usage and customization
- Consistent UI patterns

### Data Persistence
- SharedPreferences integration
- JSON encoding/decoding
- Async/await patterns
- Error handling

## 🎯 Application Screens

1. **Home Screen** - Main dashboard with expense list and search
2. **Analytics Screen** - Visual charts and spending statistics
3. **Budget Screen** - Budget creation and tracking
4. **Recurring Screen** - Manage recurring expenses and subscriptions
5. **Splitwise Screen** - Shared expenses and group spending
6. **Add/Edit Expense** - CRUD operations for expenses
7. **Split Expense** - Add shared expenses with multiple users
8. **Balances** - View and settle balances between users
9. **Users** - Manage users for shared expenses
10. **Calendar** - Calendar view of expenses by date

## 🎓 Academic Value

This project is ideal for learning Flutter development as it demonstrates:

1. **Clean Code**: Well-organized, commented, and readable
2. **Best Practices**: Proper widget hierarchy and separation of concerns
3. **Scalable Architecture**: Multiple screens, models, and services
4. **Core Concepts**: Covers widgets, state, gestures, navigation, animations, and storage
5. **Real-World Features**: Budget tracking, recurring expenses, and shared expense management
6. **Cross-Platform**: Works on Web, Desktop, and Mobile with a single codebase

## 📝 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## 🎯 Future Enhancements

- Export data to CSV/PDF
- Cloud backup and sync
- Dark mode support
- Multiple currency support
- Receipt image attachments
- Advanced analytics with more chart types
- Push notifications for recurring expenses
- Multi-language support

## 📄 License

This project is created for educational purposes.

---

**TrackWise** - Track your spending wisely! 🎯
