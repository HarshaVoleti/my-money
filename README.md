# My Money - Personal Finance Tracker

A comprehensive Flutter-based personal finance management application with Firebase backend integration.

## 🚀 Features

### Core Financial Modules
- **💰 Bank & Wallet Transactions** - Track income, expenses, and transfers
- **📈 Trading & Investments** - Monitor stocks, mutual funds, and portfolio performance
- **🤝 Borrowings & Lendings** - Manage loans, EMIs, and peer-to-peer transactions
- **💳 EMIs & Recurring Payments** - Track and predict recurring financial commitments

### Technical Features
- **🔐 Firebase Authentication** - Email/password and phone number authentication
- **☁️ Cloud Firestore** - Real-time data synchronization
- **📱 Push Notifications** - EMI reminders and transaction alerts
- **🌙 Adaptive Themes** - Light/dark mode with system preference support
- **📊 Interactive Charts** - Financial insights with fl_chart
- **🏗️ Clean Architecture** - Modular, scalable, and maintainable code structure
- **⚡ Riverpod State Management** - Modern, type-safe state management

## 🏗️ Architecture

```
lib/
├── core/                 # Core functionality and utilities
│   ├── constants/       # App constants and configuration
│   ├── models/          # Data models with Firestore integration
│   ├── providers/       # Global service providers
│   ├── services/        # Firebase services (Auth, Firestore, Notifications)
│   ├── theme/           # App theming and styling
│   └── utils/           # Helper utilities and calculators
├── features/            # Feature-based modules
│   ├── auth/           # Authentication (login, signup, forgot password)
│   ├── transactions/   # Transaction management
│   ├── investments/    # Investment portfolio tracking
│   ├── borrow_lend/    # Lending and borrowing management
│   ├── emi/            # EMI and recurring payment tracking
│   └── home/           # Dashboard and main navigation
└── shared/             # Shared widgets and components
    └── widgets/        # Reusable UI components
```

## 🛠️ Tech Stack

### Frontend
- **Flutter** (Latest version)
- **Riverpod** - State management with AsyncNotifier and StateNotifier
- **Material 3** - Modern Material Design components

### Backend & Services
- **Firebase Authentication** - User management and security
- **Cloud Firestore** - Real-time NoSQL database
- **Firebase Cloud Messaging** - Push notifications

### Analytics & Charts
- **fl_chart** - Interactive financial charts and graphs

### Development & Quality
- **very_good_analysis** - Comprehensive linting rules
- **dart fix** - Automatic code fixes and improvements
- **Build Runner** - Code generation for Riverpod

## 📱 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase project with Authentication and Firestore enabled
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/my_money.git
   cd my_money
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Email/Password and Phone)
   - Enable Cloud Firestore
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place configuration files in respective platform directories

4. **Run the app**
   ```bash
   flutter run
   ```

## 📚 Documentation

- [Code Analysis Summary](docs/CODE_ANALYSIS_SUMMARY.md) - Linting configuration and code quality metrics
- [Architecture Guide](docs/ARCHITECTURE.md) - Detailed architecture and design patterns
- [API Documentation](docs/API.md) - Firebase service methods and data models
- [Development Guidelines](docs/DEVELOPMENT.md) - Coding standards and best practices

## 🔧 Development

### Code Quality
```bash
# Run analysis
flutter analyze

# Apply automatic fixes
dart fix --apply

# Format code
dart format lib/

# Check for outdated packages
flutter pub outdated
```

### State Management
The app uses **Riverpod** with modern patterns:
- `AsyncNotifier` for async operations
- `StateNotifier` for complex state management
- Family providers for parameterized state
- Proper error handling with `AsyncValue`

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the established architecture patterns
- Write comprehensive tests for new features
- Ensure all linting rules pass (`flutter analyze`)
- Update documentation for significant changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Riverpod community for state management guidance
- Contributors and testers

---

**Built with ❤️ using Flutter**
# my-money
