# User Session & Multi-User Management Guide

## Current Architecture
Your app currently operates as a **single-user application** with all data stored locally using SharedPreferences.

## Multi-User Requirements

### Features Requiring Multi-User Support:
1. **Split Expenses (Splitwise)** - Requires multiple users to split bills
2. **Group Budgets** - Track who used how much from shared budget
3. **Recurring Expenses** - May be shared among users
4. **Debt Settlement** - Track who owes whom

---

## Proposed Multi-User Architecture

### Option 1: Local Multi-User (No Backend)
**Best for:** Family/roommates sharing a single device

#### Implementation:
```dart
// Add to User model
class User {
  final String id;
  final String name;
  final String email;
  final bool isActive; // Currently logged in user
  
  // ...existing code...
}

// Create UserSession service
class UserSessionService {
  static const String _currentUserKey = 'current_user_id';
  static const String _usersKey = 'all_users';
  
  // Get current logged-in user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey);
    
    if (userId == null) return null;
    
    final users = await StorageService.loadUsers();
    return users.firstWhere((u) => u.id == userId);
  }
  
  // Switch user session
  static Future<void> switchUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }
  
  // Register new user
  static Future<void> registerUser(User user) async {
    final users = await StorageService.loadUsers();
    users.add(user);
    await StorageService.saveUsers(users);
  }
}
```

**Data Separation Strategy:**
- **Personal Expenses:** Filtered by `userId`
- **Shared Expenses:** Visible to all users in `amountPerPerson` map
- **Group Budgets:** Track usage per user with `Map<String, double> usedByUser`

**Pros:**
- ✅ No internet required
- ✅ Works offline
- ✅ Simple implementation

**Cons:**
- ❌ Limited to single device
- ❌ No data sync across devices
- ❌ Users must share same device

---

### Option 2: Cloud-Based Multi-User (Recommended)
**Best for:** Real splitwise functionality, remote users

#### Architecture:
```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   User A    │         │   User B    │         │   User C    │
│  (Phone)    │         │  (Tablet)   │         │  (Desktop)  │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       └───────────────────────┼───────────────────────┘
                               │
                        ┌──────▼──────┐
                        │   Firebase  │
                        │  Firestore  │
                        └─────────────┘
```

#### Implementation Steps:

**1. Add Firebase to your project:**
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
```

**2. User Authentication Service:**
```dart
// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  // Register with email/password
  Future<User?> register(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user in Firestore
      final user = User(
        id: credential.user!.uid,
        name: name,
        email: email,
      );
      
      await FirestoreService.createUser(user);
      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }
  
  // Login
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return await FirestoreService.getUser(credential.user!.uid);
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
  
  // Get current user
  User? get currentUser => _auth.currentUser != null 
    ? User(id: _auth.currentUser!.uid, name: '', email: _auth.currentUser!.email!)
    : null;
}
```

**3. Firestore Data Structure:**
```
firestore
├── users/
│   ├── {userId}/
│   │   ├── name: "John Doe"
│   │   ├── email: "john@example.com"
│   │   └── createdAt: timestamp
│   
├── expenses/
│   ├── {expenseId}/
│   │   ├── title: "Groceries"
│   │   ├── amount: 100
│   │   ├── category: "Food"
│   │   ├── date: timestamp
│   │   ├── userId: "user123" (owner)
│   │   └── type: "personal" | "shared"
│   
├── sharedExpenses/
│   ├── {sharedExpenseId}/
│   │   ├── title: "Rent"
│   │   ├── totalAmount: 1000
│   │   ├── paidBy: "user123"
│   │   ├── participants: ["user123", "user456", "user789"]
│   │   ├── amountPerPerson: {
│   │   │     "user123": 333.33,
│   │   │     "user456": 333.33,
│   │   │     "user789": 333.33
│   │   │   }
│   │   ├── date: timestamp
│   │   └── settled: false
│   
├── groups/
│   ├── {groupId}/
│   │   ├── name: "Roommates"
│   │   ├── members: ["user123", "user456", "user789"]
│   │   ├── createdBy: "user123"
│   │   └── createdAt: timestamp
│   
└── budgets/
    ├── {budgetId}/
        ├── category: "Food"
        ├── totalAmount: 500
        ├── period: "monthly"
        ├── groupId: "group123" (optional)
        ├── usedByUser: {
        │     "user123": 150,
        │     "user456": 100
        │   }
        └── createdBy: "user123"
```

**4. Firestore Service:**
```dart
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // === USERS ===
  static Future<void> createUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }
  
  static Future<User?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? User.fromJson(doc.data()!) : null;
  }
  
  // === SHARED EXPENSES ===
  static Future<void> createSharedExpense(SharedExpense expense) async {
    await _db.collection('sharedExpenses').doc(expense.id).set(expense.toJson());
  }
  
  // Get shared expenses for a user
  static Stream<List<SharedExpense>> getUserSharedExpenses(String userId) {
    return _db
      .collection('sharedExpenses')
      .where('participants', arrayContains: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => SharedExpense.fromJson(doc.data()))
        .toList());
  }
  
  // === GROUPS ===
  static Future<void> createGroup(Group group) async {
    await _db.collection('groups').doc(group.id).set(group.toJson());
  }
  
  static Stream<List<Group>> getUserGroups(String userId) {
    return _db
      .collection('groups')
      .where('members', arrayContains: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => Group.fromJson(doc.data()))
        .toList());
  }
  
  // === BUDGETS ===
  static Future<void> updateBudgetUsage(
    String budgetId, 
    String userId, 
    double amount
  ) async {
    await _db.collection('budgets').doc(budgetId).update({
      'usedByUser.$userId': FieldValue.increment(amount),
    });
  }
}
```

**5. Group Model:**
```dart
// lib/models/group.dart
class Group {
  final String id;
  final String name;
  final List<String> members; // User IDs
  final String createdBy;
  final DateTime createdAt;
  
  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.createdBy,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'members': members,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
  };
  
  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'],
    name: json['name'],
    members: List<String>.from(json['members']),
    createdBy: json['createdBy'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
```

---

## User Flow Examples

### 1. Adding a Shared Expense
```dart
// User A adds shared expense
final expense = SharedExpense(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  title: 'Dinner',
  totalAmount: 90,
  paidBy: currentUser.id,
  participants: ['userA', 'userB', 'userC'],
  amountPerPerson: {
    'userA': 30,
    'userB': 30,
    'userC': 30,
  },
  date: DateTime.now(),
);

await FirestoreService.createSharedExpense(expense);
// Now userB and userC will see this expense automatically via Stream
```

### 2. Group Budget Tracking
```dart
// User A spends from group budget
final budget = await FirestoreService.getBudget('budget123');

// Add expense
await FirestoreService.updateBudgetUsage(
  budget.id,
  currentUser.id,
  50.0, // amount spent
);

// Check who used how much
final usage = budget.usedByUser; // {'userA': 150, 'userB': 100}
```

### 3. Settling Debts
```dart
// Calculate who owes whom
final debts = calculateDebts(sharedExpenses, users);

// User A settles debt with User B
await FirestoreService.settleDebt(
  debtorId: 'userA',
  creditorId: 'userB',
  amount: 50.0,
);
```

---

## Migration Strategy

### Phase 1: Add User Management (Week 1)
- ✅ Storage already working
- Add Firebase setup
- Create login/register screens
- Add user authentication

### Phase 2: Cloud Sync (Week 2)
- Migrate SharedPreferences data to Firestore
- Keep local cache for offline support
- Implement real-time sync

### Phase 3: Multi-User Features (Week 3)
- Groups functionality
- Shared budgets
- Enhanced split expense features

---

## Offline Support

Keep local cache with sync:
```dart
class HybridStorageService {
  // Save locally AND to cloud
  static Future<void> saveExpense(Expense expense) async {
    // Local first (instant)
    await StorageService.saveExpenses([expense]);
    
    // Cloud sync (background)
    try {
      await FirestoreService.createExpense(expense);
    } catch (e) {
      // Queue for later sync
      await _queueForSync(expense);
    }
  }
}
```

---

## Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Shared expenses visible to participants
    match /sharedExpenses/{expenseId} {
      allow read: if request.auth.uid in resource.data.participants;
      allow write: if request.auth.uid in request.resource.data.participants;
    }
    
    // Group members can access group data
    match /groups/{groupId} {
      allow read: if request.auth.uid in resource.data.members;
      allow write: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

---

## Recommended Approach

**For your current state:** Start with **Option 2 (Cloud-Based)** because:
1. ✅ Splitwise requires multiple users across devices
2. ✅ Real-time debt updates
3. ✅ Users can access from anywhere
4. ✅ Data backup included
5. ✅ Scalable for future features

**Implementation Priority:**
1. Setup Firebase (1 day)
2. Add authentication screens (2 days)
3. Migrate storage to Firestore (2 days)
4. Add group management (2 days)
5. Test multi-user scenarios (1 day)

Total: ~1 week for basic multi-user functionality

---

## Next Steps

1. **Run:** `flutter pub add firebase_core firebase_auth cloud_firestore`
2. **Setup Firebase Console:** https://console.firebase.google.com
3. **Create login/register screens**
4. **Migrate storage service to use Firestore**

Would you like me to generate the Firebase setup code and authentication screens?