# 🚀 New Developer Guide - Features, Modules & Components

## 📋 Table of Contents
1. [Project Overview](#-project-overview)
2. [Development Environment Setup](#-development-environment-setup)
3. [Project Structure Deep Dive](#-project-structure-deep-dive)
4. [Creating New Features](#-creating-new-features)
5. [Working with Modules](#-working-with-modules)
6. [Building Common Widgets](#-building-common-widgets)
7. [State Management Guidelines](#-state-management-guidelines)
8. [Database Operations](#-database-operations)
9. [Testing Guidelines](#-testing-guidelines)
10. [Code Standards & Best Practices](#-code-standards--best-practices)

---

## 🎯 Project Overview

MyMoney is a comprehensive personal finance management application built with **Flutter** and **Firebase**. The app follows **Clean Architecture** principles with **feature-based modular organization**.

### Tech Stack
- **Frontend**: Flutter (Latest), Material 3 Design
- **State Management**: Riverpod (AsyncNotifier & StateNotifier patterns)
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Charts**: FL Chart for data visualization
- **Architecture**: Clean Architecture with feature modules

---

## 🛠️ Development Environment Setup

### Prerequisites
```bash
# Required versions
Flutter SDK: >=3.4.0
Dart SDK: >=3.0.0
```

### Setup Steps
1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd my_money
   flutter pub get
   ```

2. **Firebase Configuration**
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)
   - Place in respective platform directories

3. **VS Code Extensions** (Recommended)
   - Flutter
   - Dart
   - Firebase Explorer
   - Error Lens
   - Riverpod Snippets

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 🏗️ Project Structure Deep Dive

```
lib/
├── core/                    # 🔧 Core functionality (shared across features)
│   ├── constants/          # App constants and configuration
│   │   └── app_constants.dart
│   ├── exceptions/         # Custom exception classes
│   │   └── app_exceptions.dart
│   ├── models/             # Data models with Firestore integration
│   │   ├── user_model.dart
│   │   ├── transaction_model.dart
│   │   ├── investment_model.dart
│   │   ├── borrow_lend_model.dart
│   │   └── emi_model.dart
│   ├── providers/          # Global service providers
│   │   └── service_providers.dart
│   ├── services/           # Firebase services
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   └── notification_service.dart
│   ├── theme/              # App theming and styling
│   │   └── app_theme.dart
│   └── utils/              # Helper utilities and calculators
│       └── investment_calculator.dart
├── features/               # 🎯 Feature-based modules
│   ├── auth/              # Authentication feature
│   │   ├── providers/     # Auth state management
│   │   ├── screens/       # Login, signup, forgot password screens
│   │   └── widgets/       # Auth-specific widgets
│   ├── transactions/      # Transaction management
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── investments/       # Investment portfolio tracking
│   ├── borrow_lend/       # Lending and borrowing management
│   ├── emi/               # EMI and recurring payments
│   └── home/              # Dashboard and navigation
└── shared/                # 🔗 Shared widgets and components
    └── widgets/
        ├── custom_text_field.dart
        ├── custom_button.dart
        └── loading_widget.dart
```

---

## ✨ Creating New Features

### Step-by-Step Feature Creation Process

#### 1. Create Feature Directory Structure
```bash
# Example: Creating a "budget" feature
mkdir -p lib/features/budget/{providers,screens,widgets}
touch lib/features/budget/providers/budget_provider.dart
touch lib/features/budget/screens/budget_screen.dart
touch lib/features/budget/widgets/budget_card.dart
```

#### 2. Create Data Model (if needed)
```dart
// lib/core/models/budget_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.budgetAmount,
    required this.spentAmount,
    required this.period, // monthly, weekly, yearly
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
    id: map['id'] as String? ?? '',
    userId: map['userId'] as String? ?? '',
    category: map['category'] as String? ?? '',
    budgetAmount: (map['budgetAmount'] as num?)?.toDouble() ?? 0.0,
    spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0.0,
    period: map['period'] as String? ?? '',
    startDate: DateTime.parse(map['startDate'] as String),
    endDate: DateTime.parse(map['endDate'] as String),
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: map['updatedAt'] != null 
        ? DateTime.parse(map['updatedAt'] as String) 
        : null,
  );

  factory BudgetModel.fromDocument(DocumentSnapshot doc) => 
      BudgetModel.fromMap(doc.data()! as Map<String, dynamic>);

  final String id;
  final String userId;
  final String category;
  final double budgetAmount;
  final double spentAmount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Calculated properties
  double get remainingAmount => budgetAmount - spentAmount;
  double get spentPercentage => budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;
  bool get isOverBudget => spentAmount > budgetAmount;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'category': category,
    'budgetAmount': budgetAmount,
    'spentAmount': spentAmount,
    'period': period,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  BudgetModel copyWith({
    String? id,
    String? userId,
    String? category,
    double? budgetAmount,
    double? spentAmount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BudgetModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    category: category ?? this.category,
    budgetAmount: budgetAmount ?? this.budgetAmount,
    spentAmount: spentAmount ?? this.spentAmount,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```

#### 3. Add Database Service Methods
```dart
// Add to lib/core/services/firestore_service.dart

// BUDGET CRUD OPERATIONS

// Add budget
Future<void> addBudget(BudgetModel budget) async {
  try {
    await _firestore
        .collection(AppConstants.budgetsCollection)
        .doc(budget.id)
        .set(budget.toMap());
  } on Exception catch (e) {
    throw FirestoreException('Error adding budget: $e');
  }
}

// Update budget
Future<void> updateBudget(BudgetModel budget) async {
  try {
    await _firestore
        .collection(AppConstants.budgetsCollection)
        .doc(budget.id)
        .update(budget.copyWith(updatedAt: DateTime.now()).toMap());
  } on Exception catch (e) {
    throw FirestoreException('Error updating budget: $e');
  }
}

// Delete budget
Future<void> deleteBudget(String budgetId) async {
  try {
    await _firestore
        .collection(AppConstants.budgetsCollection)
        .doc(budgetId)
        .delete();
  } on Exception catch (e) {
    throw FirestoreException('Error deleting budget: $e');
  }
}

// Get user budgets stream
Stream<List<BudgetModel>> getUserBudgets(String userId) => _firestore
    .collection(AppConstants.budgetsCollection)
    .where('userId', isEqualTo: userId)
    .orderBy('category')
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map(BudgetModel.fromDocument)
        .toList());
```

#### 4. Create State Provider
```dart
// lib/features/budget/providers/budget_provider.dart
import 'package:flutter/foundation.dart';
import 'package:my_money/core/models/budget_model.dart';
import 'package:my_money/core/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({
    required FirestoreService firestoreService,
    required String userId,
  })  : _firestoreService = firestoreService,
        _userId = userId {
    if (_userId.isNotEmpty) {
      _listenToBudgets();
    }
  }

  final FirestoreService _firestoreService;
  final String _userId;

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<BudgetModel> get activeBudgets => _budgets.where((budget) => 
      DateTime.now().isBefore(budget.endDate)).toList();
  
  List<BudgetModel> get overBudgets => _budgets.where((budget) => 
      budget.isOverBudget).toList();

  // Statistics
  double get totalBudgetAmount => _budgets.fold(0, (sum, budget) => 
      sum + budget.budgetAmount);
  
  double get totalSpentAmount => _budgets.fold(0, (sum, budget) => 
      sum + budget.spentAmount);

  void _listenToBudgets() {
    _firestoreService.getUserBudgets(_userId).listen(
      (budgets) {
        _budgets = budgets;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (dynamic error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addBudget({
    required String category,
    required double budgetAmount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final budget = BudgetModel(
        id: const Uuid().v4(),
        userId: _userId,
        category: category,
        budgetAmount: budgetAmount,
        spentAmount: 0.0,
        period: period,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addBudget(budget);
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.updateBudget(budget);
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestoreService.deleteBudget(budgetId);
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### 5. Create Feature Screens
```dart
// lib/features/budget/screens/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context, ref),
          ),
        ],
      ),
      body: const BudgetList(),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    // Implementation for add budget dialog
  }
}

class BudgetList extends ConsumerWidget {
  const BudgetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Budget list implementation
    return const Center(
      child: Text('Budget List Implementation'),
    );
  }
}
```

#### 6. Update Constants
```dart
// Add to lib/core/constants/app_constants.dart
static const String budgetsCollection = 'budgets';
```

---

## 🧩 Working with Modules

### Module Structure Guidelines

#### 1. Self-Contained Modules
Each feature should be self-contained with minimal dependencies on other features:

```
feature/
├── providers/     # State management specific to this feature
├── screens/       # All screens for this feature  
├── widgets/       # Feature-specific widgets
└── services/      # Optional: feature-specific services
```

#### 2. Cross-Module Communication
Use providers for cross-module communication:

```dart
// Global providers for cross-module data access
final userProvider = StateProvider<UserModel?>((ref) => null);
final selectedDateRangeProvider = StateProvider<DateRange>((ref) => 
    DateRange(start: DateTime.now(), end: DateTime.now()));

// Feature modules can watch these providers
class TransactionProvider extends StateNotifier<TransactionState> {
  TransactionProvider(this.ref) : super(TransactionState.initial()) {
    // Watch user changes
    ref.listen(userProvider, (previous, next) {
      if (next != null) {
        _loadTransactions(next.id);
      }
    });
  }

  final Ref ref;
  // ... implementation
}
```

#### 3. Module Registration Pattern
```dart
// lib/core/providers/feature_providers.dart
// Register all feature providers here for easy access

final authFeatureProviders = [
  authNotifierProvider,
  authStateProvider,
];

final transactionFeatureProviders = [
  transactionNotifierProvider,
  transactionsByDateProvider,
  monthlyTransactionSummaryProvider,
];

final budgetFeatureProviders = [
  budgetNotifierProvider,
  budgetAnalyticsProvider,
];
```

---

## 🎨 Building Common Widgets

### Widget Creation Guidelines

#### 1. Create Reusable Components
```dart
// lib/shared/widgets/custom_card.dart
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.elevation = 4.0,
    this.borderRadius = 12.0,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double elevation;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

// Usage example:
CustomCard(
  child: Column(
    children: [
      Text('Title'),
      Text('Content'),
    ],
  ),
)
```

#### 2. Form Input Components
```dart
// lib/shared/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

#### 3. Loading and Error Widgets
```dart
// lib/shared/widgets/async_value_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.loading,
    this.error,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget? loading;
  final Widget Function(Object, StackTrace)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => error?.call(err, stack) ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $err',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      data: data,
    );
  }
}

// Usage:
AsyncValueWidget<List<Transaction>>(
  value: ref.watch(transactionsProvider),
  data: (transactions) => TransactionList(transactions: transactions),
  loading: const LoadingWidget(),
  error: (error, stack) => ErrorWidget(error: error),
)
```

### Widget Organization Tips

#### 1. Widget Categories
```
shared/widgets/
├── inputs/               # Form inputs and controls
│   ├── custom_text_field.dart
│   ├── custom_dropdown.dart
│   └── date_picker_field.dart
├── layouts/              # Layout components
│   ├── custom_card.dart
│   ├── section_header.dart
│   └── responsive_grid.dart
├── feedback/             # Loading, error, success widgets
│   ├── loading_widget.dart
│   ├── error_widget.dart
│   └── empty_state.dart
└── navigation/           # Navigation components
    ├── custom_app_bar.dart
    └── bottom_nav_bar.dart
```

#### 2. Widget Naming Convention
- **Descriptive**: `CustomTextField` not `TextField2`
- **Purpose-based**: `LoadingWidget` not `SpinnerWidget`
- **Consistent**: All custom widgets start with `Custom` prefix

---

## 🔄 State Management Guidelines

### Riverpod Patterns Used in MyMoney

#### 1. AsyncNotifier Pattern (Recommended for complex state)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserModel?> build() async {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    
    if (currentUser != null) {
      return await authService.getUserDocument(currentUser.uid);
    }
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result?.user != null) {
        final userModel = await authService.getUserDocument(result!.user!.uid);
        state = AsyncValue.data(userModel);
      }
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AsyncValue.data(null);
    } on AuthException catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

#### 2. StateNotifier Pattern (For reactive state)
```dart
class TransactionState {
  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  TransactionState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier(this._firestoreService, this._userId) 
      : super(const TransactionState()) {
    _init();
  }

  final FirestoreService _firestoreService;
  final String _userId;

  void _init() {
    _firestoreService.getUserTransactions(_userId).listen(
      (transactions) {
        state = state.copyWith(
          transactions: transactions,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      state = state.copyWith(isLoading: true);
      await _firestoreService.addTransaction(transaction);
      // State will be updated automatically via stream
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

#### 3. Provider Families (For parameterized providers)
```dart
final transactionsByDateProvider = Provider.family<
    List<TransactionModel>, 
    ({DateTime start, DateTime end})
>((ref, dateRange) {
  final allTransactions = ref.watch(transactionNotifierProvider).transactions;
  return allTransactions.where((transaction) {
    return transaction.date.isAfter(dateRange.start) &&
           transaction.date.isBefore(dateRange.end);
  }).toList();
});

// Usage:
final todayTransactions = ref.watch(transactionsByDateProvider((
  start: DateTime.now().subtract(const Duration(days: 1)),
  end: DateTime.now(),
)));
```

---

## 💾 Database Operations

### CRUD Operations Pattern

#### 1. Service Layer Methods
Every database operation should go through the service layer:

```dart
// lib/core/services/firestore_service.dart

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE
  Future<void> addDocument<T>(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data);
    } on Exception catch (e) {
      throw FirestoreException('Error adding document: $e');
    }
  }

  // READ
  Stream<List<T>> getDocuments<T>(
    String collection,
    T Function(DocumentSnapshot) fromDocument,
    {Map<String, dynamic>? where,
     String? orderBy,
     bool descending = false}
  ) {
    Query query = _firestore.collection(collection);
    
    if (where != null) {
      where.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(fromDocument).toList(),
    );
  }

  // UPDATE
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .update({...data, 'updatedAt': DateTime.now().toIso8601String()});
    } on Exception catch (e) {
      throw FirestoreException('Error updating document: $e');
    }
  }

  // DELETE
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } on Exception catch (e) {
      throw FirestoreException('Error deleting document: $e');
    }
  }
}
```

#### 2. Provider Integration
```dart
class FeatureProvider extends StateNotifier<FeatureState> {
  FeatureProvider(this._service, this._userId) : super(FeatureState.initial()) {
    _initializeData();
  }

  final FirestoreService _service;
  final String _userId;

  void _initializeData() {
    _service.getDocuments<FeatureModel>(
      'feature_collection',
      FeatureModel.fromDocument,
      where: {'userId': _userId},
      orderBy: 'createdAt',
      descending: true,
    ).listen((data) {
      state = state.copyWith(items: data, isLoading: false);
    }, onError: (error) {
      state = state.copyWith(error: error.toString(), isLoading: false);
    });
  }

  Future<void> addItem(FeatureModel item) async {
    try {
      state = state.copyWith(isLoading: true);
      await _service.addDocument(
        'feature_collection',
        item.id,
        item.toMap(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
```

---

## 🧪 Testing Guidelines

### Test Structure
```
test/
├── unit/                 # Unit tests for business logic
│   ├── models/          # Test data models
│   ├── providers/       # Test state providers
│   └── services/        # Test services
├── widget/              # Widget tests for UI components
│   ├── shared/          # Test shared widgets
│   └── features/        # Test feature widgets
└── integration/         # Integration tests
    └── app_test.dart    # Full app integration tests
```

### Example Unit Test
```dart
// test/unit/providers/transaction_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockFirestoreService extends Mock implements FirestoreService {}

void main() {
  group('TransactionProvider', () {
    late MockFirestoreService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockFirestoreService();
      container = ProviderContainer(
        overrides: [
          firestoreServiceProvider.overrideWithValue(mockService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should add transaction successfully', () async {
      // Arrange
      final transaction = TransactionModel(
        id: 'test-id',
        userId: 'user-id',
        amount: 100.0,
        type: 'expense',
        // ... other fields
      );

      when(() => mockService.addTransaction(transaction))
          .thenAnswer((_) async {});

      // Act
      final provider = container.read(transactionNotifierProvider.notifier);
      await provider.addTransaction(transaction);

      // Assert
      verify(() => mockService.addTransaction(transaction)).called(1);
    });
  });
}
```

### Example Widget Test
```dart
// test/widget/shared/custom_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_money/shared/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    testWidgets('should display label and hint text', (tester) async {
      // Arrange
      final controller = TextEditingController();
      const label = 'Test Label';
      const hint = 'Test Hint';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              label: label,
              hint: hint,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.decoration?.hintText, equals(hint));
    });

    testWidgets('should call validator when text changes', (tester) async {
      // Arrange
      final controller = TextEditingController();
      bool validatorCalled = false;
      
      String? validator(String? value) {
        validatorCalled = true;
        return value?.isEmpty == true ? 'Required' : null;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                controller: controller,
                label: 'Test',
                validator: validator,
              ),
            ),
          ),
        ),
      );

      // Trigger validation
      await tester.enterText(find.byType(TextFormField), '');
      final form = tester.widget<Form>(find.byType(Form));
      final formState = form.key as GlobalKey<FormState>;
      formState.currentState?.validate();

      // Assert
      expect(validatorCalled, isTrue);
    });
  });
}
```

---

## 📏 Code Standards & Best Practices

### File Naming Conventions
```
// Models
user_model.dart
transaction_model.dart

// Services  
auth_service.dart
firestore_service.dart

// Providers
auth_provider.dart
transaction_provider.dart

// Screens
home_screen.dart
login_screen.dart

// Widgets
custom_button.dart
loading_widget.dart
```

### Code Organization in Files
```dart
// 1. Imports - grouped and sorted
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

// 2. Class definition
class AuthProvider extends StateNotifier<AuthState> {
  // 3. Constructor
  AuthProvider(this._authService) : super(AuthState.initial());

  // 4. Private fields
  final AuthService _authService;

  // 5. Public getters
  bool get isAuthenticated => state.user != null;

  // 6. Public methods
  Future<void> signIn(String email, String password) async {
    // Implementation
  }

  // 7. Private methods
  void _handleAuthError(Exception e) {
    // Implementation
  }
}
```

### Error Handling Standards
```dart
// Always use specific exception types
try {
  await _service.performOperation();
} on AuthException catch (e) {
  // Handle auth-specific errors
  _handleAuthError(e);
} on NetworkException catch (e) {
  // Handle network errors
  _handleNetworkError(e);
} on Exception catch (e) {
  // Handle generic errors
  _handleGenericError(e);
}

// Always provide meaningful error messages
throw AuthException('Invalid credentials provided. Please check your email and password.');
```

### Documentation Standards
```dart
/// Service responsible for managing user authentication and profile data.
/// 
/// This service integrates with Firebase Authentication and provides
/// methods for sign-in, sign-up, password reset, and user profile management.
/// 
/// Example usage:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// await authService.signInWithEmailAndPassword(
///   email: 'user@example.com',
///   password: 'securePassword123',
/// );
/// ```
class AuthService {
  /// Signs in a user with email and password.
  /// 
  /// Throws [AuthException] if the credentials are invalid or if there's
  /// a network error. Returns a [UserCredential] on successful sign-in.
  /// 
  /// Parameters:
  /// * [email]: The user's email address
  /// * [password]: The user's password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### Performance Best Practices

#### 1. Widget Optimization
```dart
// ✅ Use const constructors when possible
const CustomButton(
  text: 'Submit',
  onPressed: _handleSubmit,
)

// ✅ Split large widgets into smaller components
class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => TransactionItem(
        transaction: transactions[index],
      ),
    );
  }
}

// ✅ Use keys for dynamic lists
ListView.builder(
  itemBuilder: (context, index) => TransactionItem(
    key: ValueKey(transactions[index].id),
    transaction: transactions[index],
  ),
)
```

#### 2. Provider Optimization
```dart
// ✅ Use family providers for parameterized data
final transactionsByDateProvider = Provider.family<List<Transaction>, DateRange>(
  (ref, dateRange) => ref.watch(transactionProvider).where((t) =>
    t.date.isAfter(dateRange.start) && t.date.isBefore(dateRange.end)
  ).toList(),
);

// ✅ Use select to watch only specific parts of state
final isLoading = ref.watch(
  transactionProvider.select((state) => state.isLoading),
);
```

### Git Commit Standards
```bash
# Format: type(scope): description

# Types: feat, fix, docs, style, refactor, test, chore
feat(auth): add password reset functionality
fix(transactions): resolve date filtering bug
docs(readme): update installation instructions
style(widgets): format custom button component
refactor(models): simplify transaction model structure
test(providers): add unit tests for auth provider
chore(deps): update Flutter to latest version
```

---

## 🚀 Quick Start Checklist for New Features

### Before Starting Development:
- [ ] Understand the feature requirements
- [ ] Design the data model (if needed)
- [ ] Plan the provider architecture
- [ ] Identify reusable widgets

### During Development:
- [ ] Create feature directory structure
- [ ] Implement data model with proper types
- [ ] Add database service methods
- [ ] Create state provider with error handling
- [ ] Build screens with loading/error states
- [ ] Write reusable widgets
- [ ] Add proper documentation

### Before Code Review:
- [ ] Write unit tests for business logic
- [ ] Write widget tests for UI components
- [ ] Run `flutter analyze` and fix all issues
- [ ] Test on both Android and iOS
- [ ] Update documentation if needed

### Code Review Checklist:
- [ ] Follows naming conventions
- [ ] Proper error handling
- [ ] Performance optimizations
- [ ] Accessibility considerations
- [ ] Code documentation
- [ ] Test coverage

This comprehensive guide should help new interns get up to speed quickly and maintain consistency across the MyMoney application development.
