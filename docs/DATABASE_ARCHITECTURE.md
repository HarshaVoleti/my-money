# Database Architecture Guide

## 📋 Overview

This document provides a comprehensive guide to the MyMoney app's database architecture, data models, and Firebase Firestore implementation. It's designed to help new interns understand the database structure and how to work with it effectively.

## 🔥 Firebase Firestore Structure

### Database Type: NoSQL Document Database
- **Platform**: Firebase Cloud Firestore
- **Structure**: Collections → Documents → Fields
- **Queries**: Real-time listeners and one-time fetches
- **Security**: Firebase Security Rules (not covered in this document)

## 📁 Collections Overview

The MyMoney app uses **5 main collections** in Firestore:

```
my_money_db/
├── users/                    # User profiles and authentication data
├── transactions/             # All financial transactions (income/expense)
├── investments/              # Stock market investments and portfolio data
├── borrow_lend/             # Borrowing and lending records
└── emis/                    # EMI and recurring payment tracking
```

---

## 🏗️ Detailed Collection Schemas

### 1. Users Collection (`users`)

**Purpose**: Store user profile information and authentication data.

**Document ID**: Firebase Auth UID

**Schema**:
```javascript
{
  id: string,              // Firebase Auth UID (same as document ID)
  email: string,           // User's email address
  name: string,            // User's display name
  phoneNumber?: string,    // Optional phone number
  createdAt: timestamp,    // Account creation date
  updatedAt?: timestamp    // Last profile update (optional)
}
```

**Example Document**:
```javascript
// Document ID: "abc123def456ghi789"
{
  "id": "abc123def456ghi789",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "phoneNumber": "+1234567890",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-20T14:45:00.000Z"
}
```

**Indexes**: Automatically indexed by document ID (userId)

---

### 2. Transactions Collection (`transactions`)

**Purpose**: Track all financial transactions including income and expenses.

**Document ID**: Auto-generated UUID

**Schema**:
```javascript
{
  id: string,              // UUID for the transaction
  userId: string,          // Reference to users collection
  amount: number,          // Transaction amount (positive number)
  type: string,            // "income" or "expense"
  category: string,        // Transaction category
  description: string,     // Transaction description
  paymentMethod: string,   // Payment method used
  accountName?: string,    // Bank/wallet name (optional)
  tags: string[],          // Array of tags for categorization
  date: timestamp,         // Transaction date
  createdAt: timestamp,    // Record creation timestamp
  updatedAt?: timestamp    // Last update timestamp (optional)
}
```

**Categories (Examples)**:
- **Income**: "salary", "business", "investment_return", "gift", "other"
- **Expense**: "food", "transport", "utilities", "entertainment", "shopping", "healthcare", "education", "other"

**Payment Methods**: "cash", "credit_card", "debit_card", "upi", "bank_transfer", "wallet", "other"

**Example Document**:
```javascript
// Document ID: "trans_abc123def456"
{
  "id": "trans_abc123def456",
  "userId": "abc123def456ghi789",
  "amount": 2500.50,
  "type": "expense",
  "category": "food",
  "description": "Grocery shopping at SuperMart",
  "paymentMethod": "credit_card",
  "accountName": "HDFC Bank",
  "tags": ["groceries", "monthly", "essential"],
  "date": "2024-01-15T18:30:00.000Z",
  "createdAt": "2024-01-15T18:35:00.000Z",
  "updatedAt": null
}
```

**Firestore Indexes**:
- `userId` (for querying user's transactions)
- `userId + date` (for date-range queries)
- `userId + type` (for income/expense filtering)
- `userId + category` (for category-wise analysis)

---

### 3. Investments Collection (`investments`)

**Purpose**: Track stock market investments, mutual funds, and portfolio performance.

**Document ID**: Auto-generated UUID

**Schema**:
```javascript
{
  id: string,              // UUID for the investment
  userId: string,          // Reference to users collection
  stockName: string,       // Full name of the stock/fund
  stockSymbol: string,     // Stock ticker symbol
  purchasePrice: number,   // Price per unit at purchase
  quantity: number,        // Number of shares/units
  currentPrice: number,    // Current market price per unit
  purchaseDate: timestamp, // Date of purchase
  platform: string,       // Trading platform used
  sector: string,          // Industry sector
  status: string,          // "active" or "sold"
  soldDate?: timestamp,    // Date when sold (if status is "sold")
  soldPrice?: number,      // Price per unit when sold
  createdAt: timestamp,    // Record creation timestamp
  updatedAt?: timestamp    // Last update timestamp
}
```

**Status Values**:
- `"active"`: Currently held investment
- `"sold"`: Investment that has been sold

**Sectors (Examples)**: "technology", "finance", "healthcare", "energy", "consumer", "automotive", "real_estate", "other"

**Platforms (Examples)**: "zerodha", "groww", "upstox", "angel_one", "icicidirect", "other"

**Example Document**:
```javascript
// Document ID: "inv_def456ghi789"
{
  "id": "inv_def456ghi789",
  "userId": "abc123def456ghi789",
  "stockName": "Infosys Limited",
  "stockSymbol": "INFY",
  "purchasePrice": 1450.75,
  "quantity": 10,
  "currentPrice": 1523.40,
  "purchaseDate": "2024-01-10T09:15:00.000Z",
  "platform": "zerodha",
  "sector": "technology",
  "status": "active",
  "soldDate": null,
  "soldPrice": null,
  "createdAt": "2024-01-10T09:20:00.000Z",
  "updatedAt": "2024-01-15T10:00:00.000Z"
}
```

**Firestore Indexes**:
- `userId` (for user's portfolio)
- `userId + status` (for active/sold filtering)
- `userId + sector` (for sector-wise analysis)
- `userId + platform` (for platform-wise analysis)

---

### 4. Borrow-Lend Collection (`borrow_lend`)

**Purpose**: Manage money borrowed from others or lent to others.

**Document ID**: Auto-generated UUID

**Schema**:
```javascript
{
  id: string,              // UUID for the record
  userId: string,          // Reference to users collection
  amount: number,          // Total amount involved
  type: string,            // "borrowed" or "lent"
  personName: string,      // Name of the person
  personContact?: string,  // Contact information (optional)
  description: string,     // Description/reason for the transaction
  date: timestamp,         // Date when money was borrowed/lent
  dueDate?: timestamp,     // Expected return date (optional)
  status: string,          // "pending", "completed", "overdue"
  returnedAmount?: number, // Amount returned so far (optional)
  returnedDate?: timestamp, // Date when returned (optional)
  reminderDates: string[], // Array of reminder dates
  createdAt: timestamp,    // Record creation timestamp
  updatedAt?: timestamp    // Last update timestamp
}
```

**Type Values**:
- `"borrowed"`: Money borrowed from someone
- `"lent"`: Money lent to someone

**Status Values**:
- `"pending"`: Money not yet returned
- `"completed"`: Fully returned
- `"overdue"`: Past due date and not returned

**Example Document**:
```javascript
// Document ID: "bl_ghi789jkl012"
{
  "id": "bl_ghi789jkl012",
  "userId": "abc123def456ghi789",
  "amount": 50000.00,
  "type": "lent",
  "personName": "Jane Smith",
  "personContact": "+9876543210",
  "description": "Emergency medical expenses",
  "date": "2024-01-12T14:00:00.000Z",
  "dueDate": "2024-02-12T00:00:00.000Z",
  "status": "pending",
  "returnedAmount": 20000.00,
  "returnedDate": null,
  "reminderDates": ["2024-02-05", "2024-02-10"],
  "createdAt": "2024-01-12T14:05:00.000Z",
  "updatedAt": "2024-01-20T10:30:00.000Z"
}
```

**Firestore Indexes**:
- `userId` (for user's records)
- `userId + type` (for borrowed/lent filtering)
- `userId + status` (for pending/completed filtering)
- `userId + dueDate` (for overdue detection)

---

### 5. EMIs Collection (`emis`)

**Purpose**: Track EMI (Equated Monthly Installment) and recurring payments.

**Document ID**: Auto-generated UUID

**Schema**:
```javascript
{
  id: string,                    // UUID for the EMI
  userId: string,                // Reference to users collection
  title: string,                 // EMI title/name
  type: string,                  // "loan", "credit_card", "subscription", etc.
  amount: number,                // Monthly EMI amount
  startDate: timestamp,          // EMI start date
  endDate: timestamp,            // EMI end date
  frequency: string,             // "monthly", "quarterly", "yearly"
  dayOfMonth: number,            // Day of month when EMI is due (1-31)
  totalLoanAmount: number,       // Total loan amount (for loans)
  interestRate: number,          // Interest rate percentage
  status: string,                // "active", "completed", "paused"
  payments: EmiPayment[],        // Array of payment records
  reminderEnabled: boolean,      // Whether reminders are enabled
  reminderDaysBefore: number,    // Days before due date to remind
  createdAt: timestamp,          // Record creation timestamp
  updatedAt?: timestamp          // Last update timestamp
}
```

**EmiPayment Sub-document Schema**:
```javascript
{
  id: string,              // UUID for the payment
  dueDate: timestamp,      // Due date for this payment
  amount: number,          // Payment amount
  status: string,          // "pending", "paid", "overdue"
  paidDate?: timestamp,    // Date when paid (if status is "paid")
  paidAmount?: number,     // Actual amount paid (if different from due)
  lateFee?: number,        // Late fee if any
  createdAt: timestamp     // Payment record creation
}
```

**EMI Types**: "home_loan", "car_loan", "personal_loan", "credit_card", "education_loan", "subscription", "insurance", "other"

**Frequency Values**: "monthly", "quarterly", "half_yearly", "yearly"

**Status Values**:
- `"active"`: Currently running EMI
- `"completed"`: All payments done
- `"paused"`: Temporarily paused

**Example Document**:
```javascript
// Document ID: "emi_jkl012mno345"
{
  "id": "emi_jkl012mno345",
  "userId": "abc123def456ghi789",
  "title": "Home Loan - HDFC Bank",
  "type": "home_loan",
  "amount": 25000.00,
  "startDate": "2024-01-01T00:00:00.000Z",
  "endDate": "2034-12-31T00:00:00.000Z",
  "frequency": "monthly",
  "dayOfMonth": 5,
  "totalLoanAmount": 2500000.00,
  "interestRate": 8.5,
  "status": "active",
  "payments": [
    {
      "id": "pay_001",
      "dueDate": "2024-01-05T00:00:00.000Z",
      "amount": 25000.00,
      "status": "paid",
      "paidDate": "2024-01-05T10:30:00.000Z",
      "paidAmount": 25000.00,
      "lateFee": 0,
      "createdAt": "2024-01-01T00:00:00.000Z"
    },
    {
      "id": "pay_002",
      "dueDate": "2024-02-05T00:00:00.000Z",
      "amount": 25000.00,
      "status": "pending",
      "paidDate": null,
      "paidAmount": null,
      "lateFee": null,
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "reminderEnabled": true,
  "reminderDaysBefore": 3,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-15T12:00:00.000Z"
}
```

**Firestore Indexes**:
- `userId` (for user's EMIs)
- `userId + status` (for active/completed filtering)
- `userId + type` (for EMI type filtering)
- `userId + dayOfMonth` (for due date reminders)

---

## 🔗 Data Relationships

### Relational Structure
```
Users (1) ────→ (Many) Transactions
Users (1) ────→ (Many) Investments  
Users (1) ────→ (Many) Borrow_Lend
Users (1) ────→ (Many) EMIs
```

### Foreign Key Relationships
- All collections (except `users`) have `userId` field that references the `users` collection
- No direct document references are used; relationships are maintained through `userId` strings
- This approach allows for better querying performance and flexibility

### Data Consistency
- **Eventual Consistency**: Firestore provides eventual consistency
- **Atomic Operations**: Use Firestore transactions for multi-document updates
- **Validation**: Client-side validation + Firebase Security Rules (server-side)

---

## ⚡ Performance Considerations

### Indexing Strategy
1. **Composite Indexes**: Created for common query patterns
   - `userId + date` for date-range queries
   - `userId + status` for status filtering
   - `userId + type` for type-based filtering

2. **Single-field Indexes**: Automatically created by Firestore for all fields

### Query Optimization
1. **Limit Results**: Always use `.limit()` for list queries
2. **Pagination**: Implement cursor-based pagination for large datasets
3. **Real-time vs One-time**: Use streams for real-time data, one-time fetches for static data

### Data Size Management
1. **Document Limits**: Max 1MB per document
2. **Array Limits**: Max 20,000 items per array field
3. **Sub-collections**: Consider for large related datasets

---

## 🔒 Security Best Practices

### Data Validation
1. **Client-side**: Type-safe Dart models with validation
2. **Server-side**: Firebase Security Rules for authentication and authorization

### Privacy Considerations
1. **User Isolation**: Each user can only access their own data
2. **Sensitive Data**: Financial amounts and personal information are protected
3. **Audit Trail**: `createdAt` and `updatedAt` timestamps for tracking changes

---

## 📊 Common Query Patterns

### Transactions
```dart
// Get user's transactions for current month
Query transactionsQuery = FirebaseFirestore.instance
    .collection('transactions')
    .where('userId', isEqualTo: userId)
    .where('date', isGreaterThanOrEqualTo: startOfMonth)
    .where('date', isLessThanOrEqualTo: endOfMonth)
    .orderBy('date', descending: true);

// Get expense transactions by category
Query expenseQuery = FirebaseFirestore.instance
    .collection('transactions')
    .where('userId', isEqualTo: userId)
    .where('type', isEqualTo: 'expense')
    .where('category', isEqualTo: 'food')
    .orderBy('date', descending: true);
```

### Investments
```dart
// Get active investments
Query activeInvestments = FirebaseFirestore.instance
    .collection('investments')
    .where('userId', isEqualTo: userId)
    .where('status', isEqualTo: 'active')
    .orderBy('purchaseDate', descending: true);

// Get investments by sector
Query sectorInvestments = FirebaseFirestore.instance
    .collection('investments')
    .where('userId', isEqualTo: userId)
    .where('sector', isEqualTo: 'technology')
    .orderBy('purchaseDate', descending: true);
```

### EMIs
```dart
// Get overdue EMIs
Query overdueEmis = FirebaseFirestore.instance
    .collection('emis')
    .where('userId', isEqualTo: userId)
    .where('status', isEqualTo: 'active')
    .where('payments', arrayContainsAny: [{'status': 'overdue'}]);

// Get EMIs due this month
Query monthlyEmis = FirebaseFirestore.instance
    .collection('emis')
    .where('userId', isEqualTo: userId)
    .where('dayOfMonth', isLessThanOrEqualTo: 31)
    .orderBy('dayOfMonth');
```

---

## 🔄 Data Migration Strategy

### Schema Updates
1. **Backward Compatibility**: Always maintain backward compatibility
2. **Gradual Migration**: Update documents incrementally
3. **Version Fields**: Consider adding version fields for major schema changes

### Migration Process
1. **Test Environment**: Test migrations in development first
2. **Backup**: Always backup data before major migrations
3. **Rollback Plan**: Have a rollback strategy ready

This comprehensive database architecture guide should help new interns understand the data structure and start working effectively with the MyMoney application's database layer.
