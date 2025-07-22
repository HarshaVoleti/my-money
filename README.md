# My Money - Personal Finance Tracker

A comprehensive Flutter-based personal finance management application with Firebase backend integration. Track your income, expenses, investments, and manage your complete financial portfolio with real-time synchronization and beautiful analytics.

## 🚀 Features

### 💰 Financial Management
- **Income & Expense Tracking** - Record transactions with categories, tags, and receipt attachments
- **Multiple Bank Account Support** - Manage checking, savings, credit cards, and digital wallets
- **Smart Transaction Categories** - Organized labeling system for income and expense categorization
- **Receipt Management** - Attach and manage bill images for better record keeping
- **Real-time Balance Updates** - Live balance calculations across all accounts

### 📈 Investment Portfolio
- **Stock Trading** - Track buy/sell transactions with real-time portfolio valuation
- **Mutual Funds** - Monitor SIP investments and fund performance
- **Portfolio Analytics** - Comprehensive investment performance tracking
- **Profit/Loss Analysis** - Detailed gains and losses with visual charts

### 🤝 Lending & Borrowing
- **Personal Loans** - Track money lent to or borrowed from individuals
- **EMI Management** - Monitor loan EMIs with payment schedules
- **Interest Calculations** - Automatic interest computation for loans
- **Payment Reminders** - Notifications for upcoming EMI payments

### 📊 Dashboard & Analytics
- **Comprehensive Overview** - Single view of all financial accounts and balances
- **Interactive Charts** - Visual representation of spending patterns and income trends
- **Monthly/Yearly Reports** - Detailed financial summaries and insights
- **Goal Tracking** - Set and monitor savings and investment goals

### 🔧 Technical Features
- **🔐 Secure Authentication** - Firebase Auth with email/password and phone verification
- **☁️ Cloud Synchronization** - Real-time data sync across devices using Firestore
- **📱 Cross-platform** - Native performance on iOS and Android
- **🌙 Adaptive Themes** - Light/dark mode with system preference support
- **📊 Interactive Charts** - Financial insights powered by fl_chart
- **🔄 Offline Support** - Works offline with data sync when connected
- **⚡ Fast Performance** - Optimized with Riverpod state management

## 🏗️ Architecture

This app follows **Clean Architecture** principles with **Feature-based modularization** for maintainability and scalability.

```
lib/
├── core/                    # Core functionality and shared utilities
│   ├── constants/          # App-wide constants and configurations
│   ├── enums/              # Application-wide enums (LabelType, etc.)
│   ├── models/             # Shared data models (User, Label, BankAccount)
│   ├── providers/          # Global providers and services
│   ├── services/           # Firebase services and external APIs
│   ├── theme/              # App theming and Material 3 styling
│   └── utils/              # Helper utilities and extensions
│
├── features/               # Feature-based modules (Clean Architecture)
│   ├── auth/              # Authentication module
│   │   ├── models/        # Auth-specific models
│   │   ├── providers/     # Auth state management
│   │   ├── screens/       # Login, signup, forgot password screens
│   │   └── widgets/       # Auth-specific widgets
│   │
│   ├── home/              # Dashboard and navigation
│   │   ├── providers/     # Dashboard data aggregation
│   │   ├── screens/       # Main dashboard screen
│   │   └── widgets/       # Dashboard cards and components
│   │
│   ├── bank_accounts/     # Bank account management
│   │   ├── models/        # Account models and enums
│   │   ├── providers/     # Account CRUD operations
│   │   ├── screens/       # Add/edit account screens
│   │   └── widgets/       # Account cards and selectors
│   │
│   ├── transactions/      # Transaction management
│   │   ├── models/        # Transaction models
│   │   ├── providers/     # Transaction state management
│   │   ├── screens/       # Add/edit transaction screens
│   │   └── widgets/       # Transaction forms and lists
│   │
│   ├── investments/       # Investment portfolio
│   │   ├── models/        # Investment and trade models
│   │   ├── providers/     # Portfolio calculations
│   │   ├── screens/       # Investment management screens
│   │   └── widgets/       # Portfolio charts and cards
│   │
│   └── borrow_lend/       # Lending and borrowing
│       ├── models/        # Loan and EMI models
│       ├── providers/     # Loan calculations
│       ├── screens/       # Loan management screens
│       └── widgets/       # Payment schedules and calculators
│
└── shared/                # Shared UI components
    └── widgets/           # Reusable widgets (CustomButton, CustomTextField)
```

### Key Architecture Patterns
- **Repository Pattern** - Data access abstraction
- **Provider Pattern** - State management with Riverpod
- **Clean Architecture** - Separation of concerns
- **Feature-based Structure** - Modular organization
- **MVVM Pattern** - Model-View-ViewModel separation

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter** (Latest stable) - Google's UI toolkit for cross-platform development
- **Dart** (>=3.0.0) - Modern, type-safe programming language
- **Material 3** - Latest Material Design system with dynamic theming

### State Management
- **Riverpod** - Modern, compile-safe, and testable state management
- **AsyncNotifier** - For handling async operations with proper loading states
- **StateNotifier** - For complex state management scenarios
- **Family Providers** - Parameterized providers for dynamic data

### Backend & Database
- **Firebase Authentication** - Secure user authentication with multiple providers
- **Cloud Firestore** - NoSQL document database with real-time synchronization
- **Firebase Cloud Messaging** - Push notifications for reminders and alerts
- **Firebase Storage** - File storage for receipt images and documents

### UI & Visualization
- **fl_chart** - Beautiful, interactive charts for financial analytics
- **Material Icons** - Extensive icon library for consistent UI
- **Custom Widgets** - Reusable components for consistent design language

### Development Tools
- **very_good_analysis** - Comprehensive Dart/Flutter linting rules
- **build_runner** - Code generation for providers and models
- **dart_code_metrics** - Code quality analysis and metrics
- **flutter_launcher_icons** - App icon generation for multiple platforms

### Form Handling & Validation
- **form_field_validator** - Comprehensive form validation
- **image_picker** - Camera and gallery integration for receipts
- **file_picker** - Document attachment functionality

## 📱 Getting Started

### Prerequisites
- **Flutter SDK** (>=3.24.0)
- **Dart SDK** (>=3.0.0) 
- **Firebase Account** - Create at [Firebase Console](https://console.firebase.google.com)
- **Development IDE** - Android Studio, VS Code, or IntelliJ IDEA with Flutter plugins
- **Platform SDKs**:
  - Android: Android SDK (API level 21+)
  - iOS: Xcode 12.0+ (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/HarshaVoleti/my-money.git
   cd my_money
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required files**
   ```bash
   dart run build_runner build
   ```

4. **Firebase Configuration**
   
   **Step 4a: Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project or use existing one
   - Enable the following services:
     - Authentication (Email/Password & Phone Number)
     - Cloud Firestore (with proper security rules)
     - Cloud Storage (for receipt images)
     - Cloud Messaging (for notifications)

   **Step 4b: Add Firebase to your Flutter app**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your app
   flutterfire configure
   ```

   **Step 4c: Manual Configuration (Alternative)**
   - Download `google-services.json` for Android → place in `android/app/`
   - Download `GoogleService-Info.plist` for iOS → place in `ios/Runner/`

5. **Set up Firestore Security Rules**
   ```javascript
   // Firestore Security Rules (firebase/firestore.rules)
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

6. **Run the application**
   ```bash
   # Check for any issues
   flutter doctor
   
   # Run on debug mode
   flutter run
   
   # Run on specific device
   flutter run -d <device-id>
   
   # Build release APK
   flutter build apk --release
   ```

### Folder Structure Setup
The app will automatically create necessary collections in Firestore:
- `users/{userId}` - User profile and preferences
- `users/{userId}/bankAccounts` - Bank account information
- `users/{userId}/transactions` - All financial transactions
- `users/{userId}/investments` - Investment portfolio data
- `users/{userId}/labels` - Custom transaction categories
- `users/{userId}/borrowLend` - Lending and borrowing records

### Environment Configuration
Create a `.env` file in the project root (optional):
```bash
# API Keys (if needed)
STOCK_API_KEY=your_stock_api_key
NEWS_API_KEY=your_news_api_key

# App Configuration
APP_NAME=My Money
DEBUG_MODE=true
```

## 📚 Usage Guide

### 🏠 Dashboard Overview
The home screen provides a comprehensive view of your financial health:
- **Total Balance**: Combined balance across all bank accounts
- **Recent Transactions**: Quick view of latest income and expenses
- **Investment Portfolio**: Current portfolio value and performance
- **Quick Actions**: Fast access to add transactions, view accounts, or check investments

### 💳 Managing Bank Accounts
1. **Add New Account**: Tap "Add Account" from dashboard or accounts screen
2. **Account Types**: Support for bank accounts, credit cards, digital wallets, and cash
3. **Balance Tracking**: Automatic balance calculation based on transactions
4. **Default Account**: Set primary account for quick transaction entry

### 💰 Recording Transactions
1. **Add Income**: 
   - Select bank account
   - Enter amount and description
   - Choose income category (salary, freelance, business, etc.)
   - Attach receipt images if needed
   - Add custom tags for better organization

2. **Add Expenses**:
   - Similar to income but with expense categories
   - Categories include food, transport, bills, entertainment, etc.
   - Track recurring expenses with payment reminders

### 📈 Investment Tracking
1. **Add Investment**: Record stock purchases, mutual fund SIPs
2. **Portfolio View**: Real-time portfolio valuation and performance
3. **Profit/Loss**: Automatic calculation of gains and losses
4. **Investment Categories**: Stocks, mutual funds, bonds, cryptocurrency, etc.

### 🤝 Lending & Borrowing
1. **Record Loans**: Track money lent to or borrowed from individuals
2. **EMI Management**: Set up EMI schedules with automatic reminders
3. **Interest Calculation**: Configure interest rates and payment terms
4. **Payment Tracking**: Mark payments as complete and track outstanding amounts

### 📊 Reports & Analytics
- **Monthly Reports**: Detailed breakdown of income vs expenses
- **Category Analysis**: See where your money is going
- **Investment Performance**: Track portfolio growth over time
- **Goal Progress**: Monitor savings and investment goals

## 🔧 Development

### Code Quality & Standards
```bash
# Run comprehensive analysis
flutter analyze

# Apply automatic code fixes
dart fix --apply

# Format code according to Dart style guide
dart format lib/ test/

# Generate code (for Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Check for outdated dependencies
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade
```

### Testing Strategy
```bash
# Run all tests
flutter test

# Run tests with coverage report
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage HTML report
genhtml coverage/lcov.info -o coverage/html
```

### State Management with Riverpod
The app follows modern Riverpod patterns:

```dart
// Example: AsyncNotifier for data fetching
@riverpod
class BankAccounts extends _$BankAccounts {
  @override
  Future<List<BankAccountModel>> build() async {
    return await ref.watch(bankAccountRepositoryProvider).getAllAccounts();
  }
  
  Future<void> addAccount(BankAccountModel account) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(bankAccountRepositoryProvider).createAccount(account);
      return await ref.read(bankAccountRepositoryProvider).getAllAccounts();
    });
  }
}

// Family providers for parameterized data
@riverpod
Future<TransactionModel?> transaction(TransactionRef ref, String id) {
  return ref.watch(transactionRepositoryProvider).getTransaction(id);
}
```

### Firebase Service Implementation
```dart
// Example service structure
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<List<T>> getCollectionStream<T>(
    String collection,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
```

### Custom Widget Development
Follow these patterns for consistency:
```dart
// Reusable form components
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.prefixIcon,
    // ... other properties
  });
  
  // Implementation with Material 3 theming
}
```

### Performance Optimization
- **Lazy Loading**: Use `ListView.builder` for large lists
- **Image Optimization**: Compress images before upload
- **State Management**: Minimize unnecessary rebuilds with proper provider usage
- **Caching**: Implement local caching for frequently accessed data

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Getting Started
1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a feature branch** from `main`
4. **Make your changes** following our coding standards
5. **Test thoroughly** - add tests for new features
6. **Submit a pull request** with a clear description

### Development Workflow
```bash
# Create feature branch
git checkout -b feature/amazing-new-feature

# Make changes and commit
git add .
git commit -m "feat: add amazing new feature

- Implement feature X
- Add tests for feature X
- Update documentation"

# Push changes
git push origin feature/amazing-new-feature
```

### Coding Standards
- **Follow Dart/Flutter conventions** - Use `dart format` and `flutter analyze`
- **Write meaningful commit messages** - Follow conventional commits
- **Add comprehensive tests** - Unit tests for business logic, widget tests for UI
- **Document public APIs** - Add clear documentation comments
- **Update README** - For new features or significant changes

### Pull Request Guidelines
- **Clear title and description** - Explain what and why
- **Reference issues** - Link to related issues if applicable
- **Add screenshots** - For UI changes, include before/after images
- **Test instructions** - Provide steps to test your changes
- **Keep it focused** - One feature/fix per PR

### Code Review Process
1. **Automated checks** - CI/CD pipeline runs tests and analysis
2. **Peer review** - At least one maintainer reviews the code
3. **Testing** - Manual testing on different devices/platforms
4. **Approval** - Merge after approval and passing all checks

### Issues and Bugs
- **Search existing issues** before creating new ones
- **Use issue templates** for bug reports and feature requests
- **Provide detailed information** - Steps to reproduce, expected behavior
- **Add labels** appropriately (bug, enhancement, documentation, etc.)

## � Roadmap

### Phase 1: Core Features ✅
- [x] Authentication (Email/Password, Phone)
- [x] Bank account management
- [x] Basic transaction recording (Income/Expenses)
- [x] Dashboard with balance overview
- [x] Transaction categorization with labels

### Phase 2: Investment Tracking ✅
- [x] Stock investment recording
- [x] Mutual fund tracking
- [x] Portfolio performance calculation
- [x] Investment analytics and charts

### Phase 3: Advanced Features 🚧
- [ ] **Bill Reminders & Recurring Payments**
  - [ ] Set up recurring transaction templates
  - [ ] Push notifications for bill due dates
  - [ ] Auto-categorization of recurring expenses

- [ ] **Enhanced Analytics**
  - [ ] Advanced charts and visualizations
  - [ ] Spending pattern analysis
  - [ ] Budget planning and tracking
  - [ ] Financial goal setting and monitoring

### Phase 4: Smart Features �
- [ ] **AI-Powered Insights**
  - [ ] Smart transaction categorization
  - [ ] Spending behavior analysis
  - [ ] Personalized financial advice
  - [ ] Fraud detection alerts

- [ ] **Data Import/Export**
  - [ ] Bank statement import (CSV/PDF)
  - [ ] Integration with banking APIs
  - [ ] Data export for tax filing
  - [ ] Backup and restore functionality

### Phase 5: Social & Collaboration 🔮
- [ ] **Shared Expenses**
  - [ ] Group expense tracking
  - [ ] Bill splitting with friends
  - [ ] Shared family budgets
  - [ ] Expense settlement tracking

- [ ] **Multi-platform Sync**
  - [ ] Web application
  - [ ] Desktop applications
  - [ ] API for third-party integrations
  - [ ] Real-time collaboration features

## � License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** - For creating an amazing cross-platform framework
- **Firebase Team** - For providing excellent backend services
- **Riverpod Community** - For modern state management solutions
- **Material Design Team** - For beautiful and intuitive design guidelines
- **fl_chart Contributors** - For powerful charting capabilities
- **Open Source Community** - For inspiration and continuous learning

## 🔗 Links

- **Repository**: [https://github.com/HarshaVoleti/my-money](https://github.com/HarshaVoleti/my-money)
- **Issues**: [Report bugs or request features](https://github.com/HarshaVoleti/my-money/issues)
- **Discussions**: [Community discussions](https://github.com/HarshaVoleti/my-money/discussions)
- **Wiki**: [Detailed documentation](https://github.com/HarshaVoleti/my-money/wiki)

## � Support

- **GitHub Issues** - For bugs and feature requests
- **GitHub Discussions** - For questions and general discussions
- **Email** - harshavoleti@gmail.com (for urgent issues)

---

<div align="center">

**Built with ❤️ using Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

</div>
