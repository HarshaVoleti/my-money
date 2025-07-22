class AppConstants {
  // App Information
  static const String appName = 'My Money';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String investmentsCollection = 'investments';
  static const String borrowLendCollection = 'borrow_lend';
  static const String emissCollection = 'emis';

  // Transaction Types
  static const String income = 'income';
  static const String expense = 'expense';

  // Investment Status
  static const String active = 'active';
  static const String sold = 'sold';

  // Borrow/Lend Status
  static const String pending = 'pending';
  static const String completed = 'completed';
  static const String overdue = 'overdue';

  // EMI Status
  static const String emiPending = 'pending';
  static const String emiPaid = 'paid';
  static const String emiOverdue = 'overdue';

  // Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Shopping',
    'Transportation',
    'Bills & Utilities',
    'Entertainment',
    'Health & Medical',
    'Education',
    'Travel',
    'Groceries',
    'Rent',
    'Insurance',
    'Personal Care',
    'Others',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift',
    'Bonus',
    'Others',
  ];

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Debit Card',
    'Credit Card',
    'UPI',
    'Net Banking',
    'Wallet',
    'Others',
  ];

  // EMI Types
  static const List<String> emiTypes = [
    'Home Loan',
    'Car Loan',
    'Personal Loan',
    'Credit Card EMI',
    'Education Loan',
    'Others',
  ];

  // Recurring Frequencies
  static const List<String> recurringFrequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
  ];
}
