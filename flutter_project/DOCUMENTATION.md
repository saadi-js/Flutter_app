# TrackWise - Code Documentation

## 📁 File Breakdown

### 1. **main.dart** (Entry Point)
- Initializes the Flutter app
- Configures Material theme with custom colors (#6C63FF)
- Sets up navigation to HomeScreen
- Defines global button and input styles

### 2. **models/expense.dart** (Data Model)
```dart
class Expense {
  String title;        // Expense description
  double amount;       // Cost
  String category;     // Food, Travel, Bills, Shopping, Other
  DateTime date;       // When expense occurred
}
```

### 3. **screens/home_screen.dart** (Main Dashboard)
**State Variables:**
- `List<Expense> _expenses` - Stores all expenses
- `AnimationController _animationController` - For list animations

**Key Methods:**
- `_totalExpenses` - Calculates sum of all expenses
- `_addExpense()` - Adds expense and shows snackbar
- `_deleteExpense()` - Removes expense with undo option
- `_navigateToAddExpense()` - Opens add expense screen
- `_showExpenseDetails()` - Displays expense dialog

**UI Components:**
- TotalSummaryCard (animated total)
- Scrollable expense list with Dismissible
- FloatingActionButton for adding expenses
- Empty state when no expenses exist

### 4. **screens/add_expense_screen.dart** (Add Expense Form)
**Form Controls:**
- `_titleController` - TextEditingController for title input
- `_amountController` - TextEditingController for amount
- `_selectedCategory` - Dropdown selection

**Validation Rules:**
- Title: Required, minimum 3 characters
- Amount: Required, must be > 0, decimal allowed
- Category: Required (dropdown)

**Features:**
- Animated button press feedback
- Numeric keyboard for amount
- Category icons and colors
- Returns Expense object on save

### 5. **widgets/expense_card.dart** (Reusable Expense Card)
**Props:**
- `Expense expense` - Expense data to display
- `VoidCallback onTap` - Tap handler

**Features:**
- Color-coded category icons
- Formatted amount and date
- InkWell ripple effect
- Used inside Dismissible for swipe-to-delete

### 6. **widgets/total_summary_card.dart** (Summary Widget)
**Props:**
- `double totalAmount` - Total to display

**Features:**
- Gradient background
- AnimatedDefaultTextStyle for amount changes
- Wallet icon
- Shadow effect

---

## 🎨 Color Palette

| Element | Color | Hex |
|---------|-------|-----|
| Primary | Purple | #6C63FF |
| Food | Orange | Colors.orange |
| Travel | Blue | Colors.blue |
| Bills | Red | Colors.red |
| Shopping | Purple | Colors.purple |
| Other | Grey | Colors.grey |

---

## 🔧 Key Techniques Demonstrated

### State Management (Chapter 9)
```dart
setState(() {
  _expenses.insert(0, expense);
});
```

### Gestures (Chapter 8)
```dart
Dismissible(
  direction: DismissDirection.endToStart,
  onDismissed: (direction) => _deleteExpense(index),
)
```

### Animations (Chapter 10)
```dart
AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 300),
)
```

### Navigation (Chapter 9)
```dart
final result = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AddExpenseScreen()),
);
```

---

## 📊 Data Flow

```
User Taps "Add Expense"
    ↓
Navigate to AddExpenseScreen
    ↓
User fills form and taps "Save"
    ↓
Validation runs
    ↓
Expense object created
    ↓
Navigator.pop(expense)
    ↓
HomeScreen receives expense
    ↓
setState() adds to _expenses list
    ↓
UI rebuilds with new expense
    ↓
Animation plays
```

---

## 🧪 Testing

Run the test:
```bash
flutter test
```

The test verifies:
- App launches without errors
- TrackWise title appears
- Add Expense button is present

---

## 🚀 Running the App

**Desktop (Windows):**
```bash
flutter run -d windows
```

**Web:**
```bash
flutter run -d chrome
```

**Mobile (Android/iOS):**
```bash
flutter run
```

**Hot Reload:**
- Press `r` in terminal (or save file in IDE)

**Hot Restart:**
- Press `R` in terminal

---

## 💡 Tips for Presentation

1. **Demonstrate Widgets**: Show Scaffold, AppBar, ListView, Card
2. **Explain State**: Point to `setState()` usage
3. **Show Gestures**: Swipe to delete an expense
4. **Highlight Animations**: Watch the total update smoothly
5. **Navigation**: Add an expense and see it appear
6. **Clean Code**: Mention separation into models/screens/widgets

---

## 🎯 Academic Evaluation Points

✅ Proper use of StatefulWidget and StatelessWidget  
✅ Custom data model with OOP principles  
✅ Reusable widget components  
✅ Form validation and user input handling  
✅ Gesture recognition (swipe, tap)  
✅ Smooth animations with AnimationController  
✅ Navigation with data passing  
✅ Material Design implementation  
✅ Clean code structure and comments  
✅ No external packages (pure Flutter)  

---

**End of Documentation**