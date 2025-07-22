# Architecture Guide

## Overview
My Money follows Clean Architecture principles with feature-based modular organization, promoting separation of concerns, testability, and maintainability.

## Architecture Layers

### 1. Presentation Layer
- **Location**: `lib/features/*/screens/`, `lib/shared/widgets/`
- **Responsibility**: UI components, user interaction, state consumption
- **Components**: ConsumerWidgets, StatefulWidgets, custom widgets

### 2. Business Logic Layer
- **Location**: `lib/features/*/providers/`
- **Responsibility**: State management, business rules, data transformation
- **Components**: StateNotifier, AsyncNotifier, computed providers

### 3. Data Layer
- **Location**: `lib/core/services/`, `lib/core/models/`
- **Responsibility**: Data fetching, caching, external API communication
- **Components**: Firebase services, data models, repositories

## State Management with Riverpod

### Provider Types Used

#### AsyncNotifier
```dart
// For async initialization and state management
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    return await _checkAuthState();
  }
}
```

#### StateNotifier
```dart
// For complex state with business logic
class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier(this._firestoreService) : super([]);
  
  Future<void> addTransaction(TransactionModel transaction) async {
    // Business logic here
  }
}
```

#### Family Providers
```dart
// For parameterized providers
final transactionsByDateProvider = Provider.family<List<TransactionModel>, DateRange>(
  (ref, dateRange) => ref.watch(transactionProvider).where(/*filter logic*/),
);
```

### Error Handling Pattern
```dart
// Using AsyncValue for robust error handling
AsyncValue<List<Transaction>> transactions = ref.watch(transactionProvider);

return transactions.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
  data: (data) => TransactionList(data),
);
```

## Data Models

### Base Model Structure
```dart
abstract class BaseModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson();
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json);
}
```

### Firestore Integration
- All models implement `toJson()` and `fromJson()` for Firestore serialization
- Timestamp handling with proper DateTime conversion
- Null safety with proper type casting
- Document reference management

## Service Layer Architecture

### Authentication Service
- Firebase Auth integration
- Token management
- User session handling
- Error standardization

### Firestore Service
- CRUD operations for all collections
- Real-time listeners
- Batch operations
- Query optimization

### Notification Service
- Local notifications for reminders
- FCM integration for remote notifications
- Background notification handling

## Feature Module Structure

```
feature_name/
├── models/          # Feature-specific models
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Feature-specific widgets
└── services/        # Feature-specific services (if needed)
```

## Dependency Injection

Using Riverpod's provider system:

```dart
// Service providers (core/providers/service_providers.dart)
final authServiceProvider = Provider((ref) => AuthService());
final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Feature providers depend on service providers
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  () => AuthNotifier(),
);
```

## Navigation Architecture

- Named routes for better organization
- Route guards for authentication
- Deep linking support
- Bottom navigation with proper state management

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Business logic in providers
- Utility functions

### Widget Tests
- Individual widget behavior
- User interaction flows
- State changes

### Integration Tests
- Full feature workflows
- Firebase integration
- End-to-end user journeys

## Performance Considerations

### State Management
- Minimal rebuilds with precise provider watching
- Lazy loading of expensive operations
- Proper provider disposal

### Firebase Optimization
- Indexed queries for better performance
- Pagination for large datasets
- Offline caching strategies

### UI Performance
- ListView.builder for large lists
- Image caching and optimization
- Lazy loading of screens

## Security Patterns

### Authentication
- JWT token validation
- Session management
- Secure storage of sensitive data

### Data Access
- Role-based access control
- Firestore security rules
- Input validation and sanitization

## Error Handling Strategy

### Global Error Handling
```dart
// Centralized error handling
class AppErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Log error, show user-friendly message
  }
}
```

### User-Facing Errors
- Descriptive error messages
- Retry mechanisms
- Graceful degradation

## Code Organization Best Practices

1. **Single Responsibility**: Each class has one reason to change
2. **Dependency Inversion**: Depend on abstractions, not concretions
3. **Feature Modules**: Group related functionality together
4. **Consistent Naming**: Follow Dart/Flutter conventions
5. **Documentation**: Document complex business logic
6. **Type Safety**: Leverage Dart's type system fully
