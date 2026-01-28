# TrackWise - Complete Documentation

**Version:** 1.0  
**Last Updated:** January 28, 2026  
**Platform:** Flutter Web, Windows, Android, iOS

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Technical Architecture](#technical-architecture)
3. [Storage Implementation](#storage-implementation)
4. [File Structure & Widget Hierarchy](#file-structure--widget-hierarchy)
5. [Data Models](#data-models)
6. [Key Features](#key-features)
7. [Recent Changes & Fixes](#recent-changes--fixes)
8. [Running the Application](#running-the-application)

---

## 🎯 Project Overview

**TrackWise** is a comprehensive expense tracking application built with Flutter that supports:
- Personal expense management
- Recurring expense tracking
- Budget management
- Splitwise functionality for shared expenses
- Analytics and data visualization
- Multi-platform support (Web, Desktop, Mobile)

### Key Technologies
- **Framework:** Flutter 3.9+
- **Language:** Dart
- **Storage:** SharedPreferences (Local, cross-platform)
- **State Management:** StatefulWidget with setState
- **Navigation:** Bottom Navigation Bar with 5 tabs

---

## 🏗️ Technical Architecture

```
┌─────────────────────────────────────────┐
│         TrackWise Application           │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Presentation Layer              │ │
│  │   - Screens (12 screens)          │ │
│  │   - Widgets (Reusable components) │ │
│  └───────────────────────────────────┘ │
│                   ↕                     │
│  ┌───────────────────────────────────┐ │
│  │   Business Logic Layer            │ │
│  │   - State Management              │ │
│  │   - Data Processing               │ │
│  └───────────────────────────────────┘ │
│                   ↕                     │
│  ┌───────────────────────────────────┐ │
│  │   Data Layer                      │ │
│  │   - Storage Service               │ │
│  │   - SharedPreferences             │ │
│  └───────────────────────────────────┘ │
│                   ↕                     │
│  ┌───────────────────────────────────┐ │
│  │   Models Layer                    │ │
│  │   - Expense, User, Budget, etc.   │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

---

## 💾 Storage Implementation

### Technology: SharedPreferences

**Why SharedPreferences over Hive?**
- ✅ **Web Support:** Works reliably on Flutter Web using browser's localStorage
- ✅ **Cross-Platform:** Single API for all platforms
- ✅ **Persistent:** Data survives app restarts
- ✅ **No Initialization Issues:** No box management required
- ✅ **Simple API:** Easy to use and maintain

### Storage Keys
```dart
static const String _expensesKey = 'trackwise_expenses_v1';
static const String _recurringExpensesKey = 'trackwise_recurring_v1';
static const String _budgetsKey = 'trackwise_budgets_v1';
static const String _usersKey = 'trackwise_users_v1';
static const String _sharedExpensesKey = 'trackwise_shared_v1';
```

### Data Format
All data is stored as JSON strings:
```json
{
  "trackwise_expenses_v1": "[{\"id\":\"123\",\"title\":\"Lunch\",\"amount\":90,...}]",
  "trackwise_users_v1": "[{\"id\":\"user1\",\"name\":\"John\",...}]"
}
```

### Important for Web
**Always use a fixed port** to ensure data persistence:
```bash
flutter run -d chrome --web-port=8080
```
Different ports = different localStorage instances = data loss!

---

## 📁 File Structure & Widget Hierarchy

### **1. main.dart** (Entry Point)

**Widget Tree:**
```
MaterialApp
└── MainNavigationScreen
```

**Key Responsibilities:**
- Initialize SharedPreferences storage
- Configure app theme
- Set up Material Design
- Launch main navigation

---

### **2. screens/main_navigation_screen.dart** (Root Screen)

**Widget Hierarchy:**
```
Scaffold
├── AppBar
│   ├── Title (conditional based on tab)
│   ├── Search IconButton (Home tab only)
│   └── Actions (Filter, Sort, Bulk Delete)
├── Body (IndexedStack - shows current tab)
│   ├── [0] Home Tab (Expense List)
│   ├── [1] Analytics Tab
│   ├── [2] Calendar Tab
│   ├── [3] Budget Tab
│   └── [4] Splitwise Tab
├── FloatingActionButton (Add Expense)
└── BottomNavigationBar (5 items)
```

**State Variables:**
```dart
int _currentIndex = 0;                      // Active tab
List<Expense> _expenses = [];               // All expenses
List<RecurringExpense> _recurringExpenses;  // Recurring list
List<User> _users;                          // Users for splitwise
List<SharedExpense> _sharedExpenses;        // Shared expenses
bool _isBulkDeleteMode;                     // Bulk delete state
Set<String> _selectedExpenseIds;            // Selected IDs
String _searchQuery;                        // Search text
Set<String> _selectedCategories;            // Category filters
String _sortBy;                             // Sort option
```

---

### **3. Home Tab - Expense List**

**Widget Hierarchy:**
```
Column
├── TotalSummaryCard (Shows total amount)
│   └── Container (Gradient background)
│       ├── Icon (Wallet)
│       └── AnimatedDefaultTextStyle (Amount)
├── SearchBar (if search active)
│   └── TextField
├── Filter Chips (if filters active)
│   └── Wrap
│       └── FilterChip × N
└── ListView.builder (Expense list)
    └── ExpenseCard × N
        └── Dismissible (Swipe to delete)
            └── Card
                └── InkWell
                    └── Row
                        ├── Container (Category icon)
                        ├── Expanded (Details)
                        │   └── Column
                        │       ├── Row (Title + Edit badge)
                        │       ├── Row (Category + Date)
                        │       └── Text (Notes)
                        └── Column (Amount + Actions)
                            ├── Text (Amount)
                            └── Row (Edit/Delete buttons)
```

---

### **4. screens/analytics_screen.dart**

**Widget Hierarchy:**
```
SingleChildScrollView
└── Padding
    └── Column
        ├── Card (Summary)
        │   └── Column
        │       ├── Row (Total Expenses)
        │       ├── Row (Average/Transaction)
        │       └── Row (Total Transactions)
        ├── Card (Category Breakdown - Pie Chart)
        │   └── CustomPaint (PieChart widget)
        ├── Card (Monthly Trend - Line Chart)
        │   └── CustomPaint (LineChart widget)
        └── Card (Top Categories - Bar Chart)
            └── CustomPaint (BarChart widget)
```

**Custom Chart Widgets:**
- `PieChart` - Category distribution
- `LineChart` - Monthly spending trends
- `BarChart` - Top spending categories

---

### **5. screens/calendar_screen.dart**

**Widget Hierarchy:**
```
Column
├── Card (Month Selector)
│   └── Row
│       ├── IconButton (Previous month)
│       ├── Text (Current month/year)
│       └── IconButton (Next month)
├── Card (Calendar Grid)
│   └── GridView.builder (7×6 grid)
│       └── Container × 42
│           ├── Text (Day number)
│           ├── Container (Dot if has expense)
│           └── Text (Total amount)
└── Expanded
    └── ListView.builder (Expenses for selected day)
        └── ExpenseCard × N
```

---

### **6. screens/budget_screen.dart**

**Widget Hierarchy:**
```
Column
├── Card (Current Period Summary)
│   └── Column
│       ├── Text (Period info)
│       ├── LinearProgressIndicator
│       ├── Row (Spent / Budget)
│       └── Text (Remaining)
├── Card (Budget by Category)
│   └── ListView.builder
│       └── ListTile × N
│           ├── CircleAvatar (Category icon)
│           ├── Column (Category + progress)
│           │   ├── Text (Category name)
│           │   ├── LinearProgressIndicator
│           │   └── Text (Amount used/total)
│           └── IconButton (Edit)
└── FloatingActionButton (Add budget)
```

---

### **7. screens/splitwise_screen.dart**

**Widget Hierarchy:**
```
Column
├── Card (Balance Summary)
│   └── Column
│       ├── Text ("Your Balance")
│       ├── Text (Total amount owed/owing)
│       └── Text (Status message)
├── TabBar
│   ├── Tab ("Shared Expenses")
│   └── Tab ("Balances")
└── TabBarView
    ├── [0] Shared Expenses List
    │   └── ListView.builder
    │       └── Card × N
    │           ├── Row (Title, amount, date)
    │           ├── Row (Paid by user)
    │           └── Wrap (Participant chips)
    └── [1] Balances View
        └── ListView.builder
            └── Card × N (Per user)
                ├── CircleAvatar (User)
                ├── Column (Name + amount)
                └── ElevatedButton (Settle)


---

### **8. screens/recurring_screen.dart**

**Widget Hierarchy:**
```
ListView.builder
└── Card × N
    └── ListTile
        ├── Leading (Category icon)
        ├── Title (Expense name)
        ├── Subtitle (Amount + frequency)
        └── Trailing (IconButton - delete)
```

---

### **9. screens/add_expense_screen.dart**

**Widget Hierarchy:**
```
Scaffold
├── AppBar
│   ├── Leading (Back button)
│   └── Title ("Add Expense")
└── Body
    └── SingleChildScrollView
        └── Padding
            └── Form
                └── Column
                    ├── TextField (Title)
                    ├── TextField (Amount - numeric)
                    ├── DropdownButtonFormField (Category)
                    ├── InkWell (Date picker)
                    │   └── Row
                    │       ├── Icon (Calendar)
                    │       └── Text (Selected date)
                    ├── TextField (Notes - multiline)
                    └── ElevatedButton (Save)
```

**Validation Rules:**
- Title: Required, min 3 characters
- Amount: Required, must be > 0
- Category: Required
- Date: Auto-set to today

---

### **10. screens/edit_expense_screen.dart**

**Widget Hierarchy:**
```
Scaffold
├── AppBar
│   ├── Leading (Back button)
│   ├── Title ("Edit Expense")
│   └── Actions (Delete IconButton)
└── Body (Same as AddExpenseScreen but pre-filled)
    └── Form
        └── Column
            ├── TextField (Pre-filled title)
            ├── TextField (Pre-filled amount)
            ├── DropdownButtonFormField (Pre-selected category)
            ├── InkWell (Date picker with current date)
            ├── TextField (Pre-filled notes)
            └── ElevatedButton ("Update Expense")
```

---

### **11. screens/split_expense_screen.dart**

**Widget Hierarchy:**
```
Scaffold
├── AppBar ("Split Expense")
└── Body
    └── Form
        └── Column
            ├── TextField (Title)
            ├── TextField (Total amount)
            ├── Card ("Paid By")
            │   └── DropdownButtonFormField (User selector)
            ├── Card ("Split Between")
            │   └── Column
            │       └── CheckboxListTile × N (Users)
            ├── Card ("Split Method")
            │   └── SegmentedButton
            │       ├── "Equally"
            │       ├── "By Amount"
            │       └── "By Percentage"
            ├── Card (Split breakdown - conditional)
            │   └── ListView (Shows split details)
            └── ElevatedButton ("Save Split")
```

---

### **12. screens/users_screen.dart**

**Widget Hierarchy:**
```
Scaffold
├── AppBar ("Manage Users")
│   └── Actions (Add user button)
└── Body
    └── ListView.builder
        └── Card × N
            └── ListTile
                ├── Leading (CircleAvatar with initials)
                ├── Title (User name)
                ├── Subtitle (Email)
                └── Trailing (IconButton - delete)
```

---

## 📊 Data Models

### **1. Expense Model**
```dart
class Expense {
  final String id;              // Unique identifier
  final String title;           // Expense description
  final double amount;          // Cost
  final String category;        // Food, Travel, Bills, Shopping, Other
  final DateTime date;          // When expense occurred
  final String notes;           // Optional notes
  final bool wasEdited;         // Edit tracking flag
  
  // Computed properties
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedDate => 'MMM dd, yyyy';
  
  // Serialization
  Map<String, dynamic> toJson();
  factory Expense.fromJson(Map<String, dynamic> json);
}
```

### **2. RecurringExpense Model**
```dart
class RecurringExpense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String frequency;       // Daily, Weekly, Monthly, Yearly
  final DateTime startDate;
  final DateTime? endDate;
  
  Map<String, dynamic> toJson();
  factory RecurringExpense.fromJson(Map<String, dynamic> json);
}
```

### **3. Budget Model**
```dart
class Budget {
  final String category;
  final double amount;
  final String period;          // Monthly, Weekly, Yearly
  
  // No serialization needed (simple model)
}
```

### **4. User Model**
```dart
class User {
  final String id;
  final String name;
  final String email;
  
  Map<String, dynamic> toJson();
  factory User.fromJson(Map<String, dynamic> json);
}
```

### **5. SharedExpense Model**
```dart
class SharedExpense {
  final String id;
  final String title;
  final double totalAmount;
  final String paidBy;                    // User ID who paid
  final List<String> participants;        // User IDs
  final Map<String, double> amountPerPerson;
  final DateTime date;
  final bool settled;
  
  Map<String, dynamic> toJson();
  factory SharedExpense.fromJson(Map<String, dynamic> json);
}
```

---

## 🎨 Reusable Widget Components

### **1. widgets/expense_card.dart**

**Purpose:** Display individual expense with actions

**Props:**
- `Expense expense` - Expense data
- `VoidCallback onTap` - Tap handler
- `VoidCallback? onEdit` - Edit handler
- `VoidCallback? onDelete` - Delete handler

**Features:**
- Color-coded category icons
- Formatted amount and date
- Edit badge if modified
- Action buttons (edit/delete)
- InkWell ripple effect

---

### **2. widgets/total_summary_card.dart**

**Purpose:** Display total expenses with animation

**Props:**
- `double totalAmount` - Total to display

**Features:**
- Gradient purple background
- Wallet icon
- Animated text changes
- Shadow and elevation

---

### **3. widgets/charts/pie_chart.dart**

**Purpose:** Visualize category distribution

**Rendering:** Custom painter with arc drawing

**Data:** `Map<String, double>` category amounts

---

### **4. widgets/charts/line_chart.dart**

**Purpose:** Show spending trends over time

**Rendering:** Custom painter with line paths

**Data:** `List<double>` monthly amounts

---

### **5. widgets/charts/bar_chart.dart**

**Purpose:** Compare category spending

**Rendering:** Custom painter with rectangles

**Data:** `Map<String, double>` category totals

---

## 🔧 Key Features Implementation

### **1. Persistent Storage**

**Service:** `services/storage_service.dart`

```dart
class StorageService {
  // Save data
  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = expenses.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_expensesKey, jsonString);
  }
  
  // Load data
  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expensesKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Expense.fromJson(json)).toList();
  }
}
```

**Auto-save triggers:**
- After adding expense
- After editing expense
- After deleting expense
- After bulk delete
- After settling split expense

---

### **2. Search & Filter**

**Implementation in MainNavigationScreen:**

```dart
List<Expense> get _filteredExpenses {
  return _expenses.where((expense) {
    // Search by title or notes
    final matchesSearch = expense.title
      .toLowerCase()
      .contains(_searchQuery.toLowerCase());
    
    // Filter by selected categories
    final matchesCategory = _selectedCategories.isEmpty || 
      _selectedCategories.contains(expense.category);
    
    return matchesSearch && matchesCategory;
  }).toList();
}
```

**Sort options:**
- Date (newest first / oldest first)
- Amount (highest first / lowest first)

---

### **3. Swipe to Delete**

```dart
Dismissible(
  key: Key(expense.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) => _deleteExpense(index),
  child: ExpenseCard(expense: expense),
)
```

---

### **4. Bulk Delete Mode**

**UI Changes:**
- Checkboxes appear on expense cards
- AppBar shows "X selected"
- Delete all button in AppBar

**Implementation:**
```dart
if (_isBulkDeleteMode) {
  // Show checkbox
  Checkbox(
    value: _selectedExpenseIds.contains(expense.id),
    onChanged: (selected) {
      setState(() {
        if (selected!) {
          _selectedExpenseIds.add(expense.id);
        } else {
          _selectedExpenseIds.remove(expense.id);
        }
      });
    },
  )
}
```

---

### **5. Split Expense Calculation**

**Methods:**
- **Equal Split:** `totalAmount / participants.length`
- **By Amount:** User enters specific amounts
- **By Percentage:** User enters percentages (must sum to 100%)

**Debt Tracking:**
```dart
double calculateDebt(String userId, List<SharedExpense> expenses) {
  double owes = 0;
  double owed = 0;
  
  for (var expense in expenses) {
    if (expense.paidBy == userId) {
      // User paid, calculate what others owe them
      owed += expense.amountPerPerson
        .entries
        .where((e) => e.key != userId)
        .fold(0, (sum, e) => sum + e.value);
    } else {
      // User owes the payer
      owes += expense.amountPerPerson[userId] ?? 0;
    }
  }
  
  return owed - owes; // Positive = owed to user, Negative = user owes
}
```

---

### **6. Recurring Expense Processing**

**Auto-generation logic:**
```dart
void processRecurringExpenses() {
  final now = DateTime.now();
  
  for (var recurring in _recurringExpenses) {
    final daysSinceStart = now.difference(recurring.startDate).inDays;
    
    int interval = recurring.frequency == 'Daily' ? 1
                 : recurring.frequency == 'Weekly' ? 7
                 : recurring.frequency == 'Monthly' ? 30
                 : 365;
    
    if (daysSinceStart % interval == 0) {
      // Create new expense from recurring template
      _addExpense(Expense(
        title: recurring.title,
        amount: recurring.amount,
        category: recurring.category,
        date: now,
      ));
    }
  }
}
```

---

## 🐛 Recent Changes & Fixes

### **January 28, 2026 - Major Updates**

#### **1. Storage System Migration**
**Problem:** Hive storage not working on Flutter Web due to port-based storage isolation

**Solution:** Migrated from Hive to SharedPreferences
- ✅ Works on all platforms (Web, Desktop, Mobile)
- ✅ Uses browser's localStorage on web
- ✅ Data persists across sessions
- ⚠️ **Important:** Must use fixed port on web (`--web-port=8080`)

**Files Changed:**
- `lib/services/storage_service.dart` - Complete rewrite
- `pubspec.yaml` - Removed `hive_flutter`, kept `shared_preferences`

---

#### **2. UI Overflow Fix**
**Problem:** Yellow/black overflow stripes in expense cards on narrow screens

**Solution:** Wrapped category badge and date in `Flexible` widgets with ellipsis

**File Changed:** `lib/widgets/expense_card.dart` (Lines 138-165)

**Before:**
```dart
Row(
  children: [
    Container(...), // Category - fixed width
    Text(...),      // Date - fixed width
  ],
)
```

**After:**
```dart
Row(
  children: [
    Flexible(
      child: Container(...), // Can shrink
    ),
    Flexible(
      child: Text(
        ...,
        overflow: TextOverflow.ellipsis, // Truncates if needed
      ),
    ),
  ],
)
```

---

#### **3. Enhanced Logging**
Added comprehensive logging to track storage operations:
- Save confirmations with character counts
- Load status with item counts
- All available storage keys
- Verification after save operations

**Purpose:** Debug storage issues and confirm data persistence

---

## 🚀 Running the Application

### **Web (Recommended for Testing)**
```bash
# Always use fixed port for data persistence!
flutter run -d chrome --web-port=8080
```

### **Windows Desktop**
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

### **Android**
```bash
# Connect device or start emulator first
flutter run
```

### **Build for Production**

**Web:**
```bash
flutter build web --release
# Output: build/web/
```

**Windows:**
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## ⌨️ Development Commands

### **Hot Reload**
```bash
# In terminal while app is running
r
```
Preserves app state, updates code changes

### **Hot Restart**
```bash
R
```
Completely restarts app (loses state)

### **Clear Console**
```bash
c
```

### **Quit**
```bash
q
```

---

## 🎨 Color Palette & Theme

### **Primary Colors**
| Element | Color | Hex/Code |
|---------|-------|----------|
| Primary | Purple | `#6C63FF` |
| Secondary | Deep Purple | `Colors.deepPurple` |
| Success | Green | `Colors.green` |
| Error | Red | `Colors.red` |
| Warning | Orange | `Colors.orange` |

### **Category Colors**
| Category | Color | Icon |
|----------|-------|------|
| Food | Orange | `Icons.restaurant` |
| Travel | Blue | `Icons.flight` |
| Bills | Red | `Icons.receipt_long` |
| Shopping | Purple | `Icons.shopping_bag` |
| Other | Grey | `Icons.category` |

---

## 📱 Responsive Design

### **Breakpoints**
- Mobile: < 600px width
- Tablet: 600px - 1024px
- Desktop: > 1024px

### **Adaptive Layouts**
- Cards adjust padding based on screen size
- Charts resize automatically
- Bottom navigation hides labels on narrow screens
- Calendar grid uses MediaQuery for sizing

---

## 🔐 Data Privacy

**Current Implementation:**
- All data stored locally on device
- No cloud backup
- No user authentication
- No network requests

**For Multi-User (Future):**
See `USER_SESSION_MANAGEMENT.md` for Firebase integration guide

---

## 🧪 Testing

### **Run Tests**
```bash
flutter test
```

### **Test Coverage**
```bash
flutter test --coverage
```

### **Widget Tests Location**
`test/widget_test.dart`

---

## 📚 Dependencies

### **Production**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.4
```

### **Development**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## 🎯 Code Quality Standards

### **Naming Conventions**
- Classes: `PascalCase` (ExpenseCard)
- Variables: `camelCase` (_expenses)
- Private: prefix with `_` (_loadData)
- Constants: `camelCase` with `static const`

### **File Organization**
```
lib/
├── main.dart (entry point)
├── models/ (data structures)
├── screens/ (full-page widgets)
├── widgets/ (reusable components)
└── services/ (business logic)
```

### **Comments**
- Every class has doc comments
- Complex logic explained inline
- TODO markers for future improvements

---

## 🚨 Known Limitations

1. **Web Port Dependency:** Must use same port for data persistence
2. **No Cloud Sync:** Data only on local device
3. **Single User:** No authentication system yet
4. **No Export:** Cannot export data to CSV/PDF
5. **No Recurring Auto-Add:** Must manually trigger recurring expenses

---

## 🔮 Future Enhancements

- [ ] Firebase integration for multi-user support
- [ ] Export to CSV/Excel
- [ ] Import bank statements
- [ ] Push notifications for budgets
- [ ] Dark mode theme
- [ ] Multiple currencies
- [ ] Receipt photo attachments
- [ ] AI-powered expense categorization

---

## 📞 Support & Troubleshooting

### **Storage not persisting on web?**
→ Always use `--web-port=8080` flag

### **Overflow errors?**
→ Already fixed in latest version, pull latest code

### **Can't build for Android?**
→ Run `flutter doctor` and fix Android SDK setup

### **Charts not displaying?**
→ Check that expenses exist for the time period

---

**Documentation Complete ✅**  
**Last Updated:** January 28, 2026