# TrackWise - Personal Expense Tracker 💰

A complete Flutter mobile application for tracking daily expenses with a clean, modern UI and smooth animations.

## 📱 About the App

**TrackWise** is an offline expense tracking application built entirely with Flutter core libraries. It demonstrates key mobile development concepts including state management, gestures, animations, and navigation.

### ✨ Features

- **Dashboard Overview**: View total expenses with an animated summary card
- **Add Expenses**: Easy-to-use form with validation and category selection
- **Delete Expenses**: Swipe-to-delete gesture with undo functionality
- **Expense Details**: Tap any expense to view detailed information
- **Category Organization**: Five categories (Food, Travel, Bills, Shopping, Other) with color-coded icons
- **Smooth Animations**: Animated transitions, button press feedback, and list updates
- **Empty State**: Friendly UI when no expenses exist

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point with theme configuration
├── models/
│   └── expense.dart              # Expense data model (OOP)
├── screens/
│   ├── home_screen.dart          # Main dashboard with expense list
│   └── add_expense_screen.dart   # Form to add new expenses
└── widgets/
    ├── expense_card.dart         # Reusable expense display card
    └── total_summary_card.dart   # Animated total summary widget
```

## 🎨 UI/UX Highlights

- **Modern Design**: Soft color palette with purple accent (#6C63FF)
- **Material 3**: Latest Material Design guidelines
- **Rounded Corners**: Cards and buttons with 12px border radius
- **Responsive Layout**: Proper padding and spacing throughout
- **Visual Feedback**: Animations and snackbars for user actions

## 🧠 Technical Implementation

### State Management
- Uses `StatefulWidget` and `setState()` (Chapter 9)
- In-memory expense list management
- No external state management packages

### Gestures (Chapter 8)
- `Dismissible` widget for swipe-to-delete
- `InkWell` and `GestureDetector` for tap interactions
- Confirmation dialog before deletion

### Animations (Chapter 10)
- `AnimatedDefaultTextStyle` for total amount updates
- `FadeTransition` and `SlideTransition` for list items
- `ScaleTransition` for button press feedback
- `AnimationController` with curves for smooth effects

### Navigation (Chapter 9)
- `Navigator.push()` and `Navigator.pop()` for screen transitions
- Data passing between screens
- Result handling from navigation

### Data Model (Dart OOP)
```dart
class Expense {
  final String title;
  final double amount;
  final String category;
  final DateTime date;
}
```

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

### Widgets
- Scaffold, AppBar, FloatingActionButton
- ListView, Card, Container
- TextFormField, DropdownButton
- Dialog, SnackBar

### Layouts
- Column, Row, Expanded
- Padding, SizedBox, Center
- Stack positioning

### Forms & Validation
- Form with GlobalKey
- TextEditingController
- Input validators
- Numeric keyboard

### Material Design
- Theme configuration
- Color schemes
- Elevation and shadows
- Icon usage

## 🎓 Academic Value

This project is ideal for a university Mobile App Development course as it demonstrates:

1. **Clean Code**: Well-organized, commented, and readable
2. **Best Practices**: Proper widget hierarchy and separation of concerns
3. **No Over-Engineering**: Simple, maintainable architecture
4. **Core Concepts**: Covers widgets, state, gestures, navigation, and animations
5. **Offline First**: No backend or external dependencies required

## 📝 Sample Data

The app includes two sample expenses on first launch:
- Grocery Shopping ($45.50) - Food
- Electricity Bill ($120.00) - Bills

## 🎯 Future Enhancements (Optional)

- Category-based filtering
- Date range filtering
- Export to CSV
- Charts and statistics
- Local storage persistence
- Dark mode support

## 📄 License

This project is created for educational purposes.

---

**TrackWise** - Track your spending wisely! 🎯
