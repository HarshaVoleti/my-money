# Development Guidelines

## Code Standards

### Dart/Flutter Conventions
- Follow official [Dart Style Guide](https://dart.dev/guides/language/effective-dart)
- Use `lowerCamelCase` for variables, methods, and parameters
- Use `UpperCamelCase` for classes, enums, typedefs, and extensions
- Use `lowercase_with_underscores` for libraries, packages, directories, and files

### Naming Conventions

#### Files and Directories
```
// Good
user_model.dart
transaction_provider.dart
auth_service.dart

// Bad
userModel.dart
TransactionProvider.dart
AuthService.dart
```

#### Classes and Variables
```dart
// Classes - PascalCase
class TransactionModel {}
class AuthService {}

// Variables and methods - camelCase
final userName = 'john_doe';
void calculateTotalAmount() {}

// Constants - ALL_CAPS
static const String API_BASE_URL = 'https://api.example.com';
```

### Code Organization

#### File Structure
```dart
// 1. Imports - grouped and sorted
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_money/core/models/user_model.dart';
import 'package:my_money/core/services/auth_service.dart';

// 2. Constants
static const String _defaultTitle = 'My Money';

// 3. Class definition
class MyWidget extends ConsumerWidget {
  // Public fields first
  final String title;
  
  // Private fields
  final String _internalValue;
  
  // Constructor
  const MyWidget({
    super.key,
    required this.title,
  });
  
  // Public methods
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
  
  // Private methods
  void _handleTap() {}
}
```

## State Management Guidelines

### Riverpod Best Practices

#### Provider Definition
```dart
// Use meaningful names with Provider suffix
final userNotifierProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

// Family providers for parameterized data
final transactionsByDateProvider = Provider.family<List<Transaction>, DateTime>(
  (ref, date) => ref.watch(transactionProvider).where(/* filter logic */),
);
```

#### Consumer Widgets
```dart
class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    
    return transactions.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error.toString()),
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) => TransactionTile(data[index]),
      ),
    );
  }
}
```

#### Error Handling
```dart
// Always handle AsyncValue states properly
ref.watch(dataProvider).when(
  loading: () => const LoadingWidget(),
  error: (error, stackTrace) => ErrorWidget(error),
  data: (data) => DataWidget(data),
);
```

### State Updates
```dart
class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionNotifier(this._service) : super(const AsyncValue.loading());
  
  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    try {
      await _service.addTransaction(transaction);
      final updatedList = await _service.getTransactions();
      state = AsyncValue.data(updatedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

## Error Handling Standards

### Exception Types
```dart
// Custom exceptions for different error types
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  const NetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message (${statusCode ?? 'N/A'})';
}
```

### Service Layer Error Handling
```dart
class AuthService {
  Future<User> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return User.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw NetworkException('Failed to sign in: ${e.toString()}');
    }
  }
}
```

## Testing Guidelines

### Unit Tests
```dart
// Test file naming: feature_test.dart
void main() {
  group('TransactionModel', () {
    test('should create transaction from JSON', () {
      // Arrange
      final json = {
        'id': 'test-id',
        'amount': 100.0,
        'type': 'income',
      };
      
      // Act
      final transaction = TransactionModel.fromJson(json);
      
      // Assert
      expect(transaction.id, 'test-id');
      expect(transaction.amount, 100.0);
      expect(transaction.type, TransactionType.income);
    });
  });
}
```

### Widget Tests
```dart
void main() {
  testWidgets('TransactionTile displays correct information', (tester) async {
    // Arrange
    final transaction = TransactionModel(
      id: 'test-id',
      amount: 100.0,
      type: TransactionType.income,
      description: 'Test transaction',
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionTile(transaction),
      ),
    );
    
    // Assert
    expect(find.text('Test transaction'), findsOneWidget);
    expect(find.text('₹100.0'), findsOneWidget);
  });
}
```

## Documentation Standards

### Class Documentation
```dart
/// Manages user transactions and provides CRUD operations.
///
/// This service handles all transaction-related operations including
/// creating, reading, updating, and deleting transactions from Firestore.
///
/// Example usage:
/// ```dart
/// final service = TransactionService();
/// await service.addTransaction(transaction);
/// final transactions = await service.getTransactions();
/// ```
class TransactionService {
  /// Adds a new transaction to the user's account.
  ///
  /// Throws [ValidationException] if transaction data is invalid.
  /// Throws [NetworkException] if the operation fails due to network issues.
  Future<void> addTransaction(TransactionModel transaction) async {
    // Implementation
  }
}
```

### Method Documentation
```dart
/// Calculates the compound interest for an investment.
///
/// [principal] - The initial investment amount
/// [rate] - Annual interest rate as a decimal (e.g., 0.05 for 5%)
/// [time] - Investment period in years
/// [compoundingFrequency] - Number of times interest is compounded per year
///
/// Returns the total amount after compound interest calculation.
///
/// Example:
/// ```dart
/// final amount = calculateCompoundInterest(1000, 0.05, 5, 12);
/// print(amount); // Outputs: 1283.36
/// ```
double calculateCompoundInterest(
  double principal,
  double rate,
  int time,
  int compoundingFrequency,
) {
  return principal * math.pow(1 + rate / compoundingFrequency, compoundingFrequency * time);
}
```

## Performance Best Practices

### Widget Building
```dart
// Good - Build method stays pure
class TransactionList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    
    return transactions.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) => TransactionTile(data[index]),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorDisplay(error),
    );
  }
}
```

### Expensive Operations
```dart
// Use computed providers for expensive calculations
final monthlyTotalProvider = Provider((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions.fold<double>(
    0.0, 
    (sum, transaction) => sum + transaction.amount,
  );
});
```

### List Performance
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    final transaction = transactions[index];
    return TransactionTile(
      key: ValueKey(transaction.id), // Provide keys for better performance
      transaction: transaction,
    );
  },
)
```

## Git Workflow

### Commit Messages
```
feat: add transaction filtering by category
fix: resolve authentication state persistence issue
docs: update API documentation for transaction service
style: format code according to dart style guide
refactor: extract common validation logic
test: add unit tests for transaction calculations
```

### Branch Naming
- `feature/transaction-filtering`
- `bugfix/auth-state-issue`
- `hotfix/critical-crash-fix`
- `docs/api-documentation`

### Pull Request Guidelines
1. Descriptive title and detailed description
2. Link to related issues
3. Include screenshots for UI changes
4. Ensure all tests pass
5. Update documentation if needed
6. Request appropriate reviewers

## Code Review Checklist

### Functionality
- [ ] Does the code solve the intended problem?
- [ ] Are edge cases handled properly?
- [ ] Is error handling comprehensive?

### Code Quality
- [ ] Is the code readable and well-structured?
- [ ] Are naming conventions followed?
- [ ] Is there adequate documentation?
- [ ] Are there any code smells or anti-patterns?

### Testing
- [ ] Are there sufficient unit tests?
- [ ] Do widget tests cover the UI behavior?
- [ ] Are integration tests needed?

### Performance
- [ ] Are there any performance bottlenecks?
- [ ] Is state management efficient?
- [ ] Are expensive operations optimized?

### Security
- [ ] Is user input validated and sanitized?
- [ ] Are API keys and secrets properly managed?
- [ ] Is sensitive data handled securely?
