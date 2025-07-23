import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:my_money/shared/widgets/custom_button.dart';
import 'package:my_money/shared/widgets/custom_text_field.dart';

class AddBankAccountScreen extends ConsumerStatefulWidget {
  const AddBankAccountScreen({super.key, this.account});

  final BankAccountModel? account;

  @override
  ConsumerState<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends ConsumerState<AddBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _balanceController = TextEditingController();
  // Credit card fields
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _creditLimitController = TextEditingController();
  DateTime? _billingDate;

  AccountType _selectedType = AccountType.bank;
  LabelColor _selectedColor = LabelColor.blue;
  bool _isDefault = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final account = widget.account!;
    _nameController.text = account.name;
    _bankNameController.text = account.bankName;
    _accountNumberController.text = account.accountNumber;
    _ifscCodeController.text = account.ifscCode ?? '';
    _branchNameController.text = account.branchName ?? '';
    _descriptionController.text = account.description ?? '';
    _balanceController.text = account.balance.toString();
    _selectedType = account.type;
    _selectedColor = account.color;
    _isDefault = account.isDefault;
    // Credit card fields
    _cardNumberController.text = account.cardNumber ?? '';
    _expiryController.text = account.expiryDate ?? '';
    _cvvController.text = account.cvv ?? '';
    _creditLimitController.text = account.creditLimit?.toString() ?? '';
    _billingDate = account.billingDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _branchNameController.dispose();
    _descriptionController.dispose();
    _balanceController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _creditLimitController.dispose();
    // No need to dispose _billingDate (DateTime)
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final balance = double.tryParse(_balanceController.text) ?? 0.0;
      final creditLimit = double.tryParse(_creditLimitController.text);

      if (_isEditing) {
        final updatedAccount = widget.account!.copyWith(
          name: _nameController.text.trim(),
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          type: _selectedType,
          color: _selectedColor,
          ifscCode: _ifscCodeController.text.trim().isNotEmpty 
              ? _ifscCodeController.text.trim() : null,
          branchName: _branchNameController.text.trim().isNotEmpty 
              ? _branchNameController.text.trim() : null,
          description: _descriptionController.text.trim().isNotEmpty 
              ? _descriptionController.text.trim() : null,
          balance: balance,
          isDefault: _isDefault,
          updatedAt: DateTime.now(),
          cardNumber: _selectedType == AccountType.creditCard ? _cardNumberController.text.trim() : null,
          expiryDate: _selectedType == AccountType.creditCard ? _expiryController.text.trim() : null,
          cvv: _selectedType == AccountType.creditCard ? _cvvController.text.trim() : null,
          creditLimit: _selectedType == AccountType.creditCard ? creditLimit : null,
            billingDate: _selectedType == AccountType.creditCard ? _billingDate : null,
        );

        await ref.read(bankAccountNotifierProvider.notifier).updateBankAccount(updatedAccount);
      } else {
        await ref.read(bankAccountNotifierProvider.notifier).createBankAccount(
          name: _nameController.text.trim(),
          bankName: _bankNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          type: _selectedType,
          color: _selectedColor,
          ifscCode: _ifscCodeController.text.trim().isNotEmpty 
              ? _ifscCodeController.text.trim() : null,
          branchName: _branchNameController.text.trim().isNotEmpty 
              ? _branchNameController.text.trim() : null,
          description: _descriptionController.text.trim().isNotEmpty 
              ? _descriptionController.text.trim() : null,
          balance: balance,
          isDefault: _isDefault,
          cardNumber: _selectedType == AccountType.creditCard ? _cardNumberController.text.trim() : null,
          expiryDate: _selectedType == AccountType.creditCard ? _expiryController.text.trim() : null,
          cvv: _selectedType == AccountType.creditCard ? _cvvController.text.trim() : null,
          creditLimit: _selectedType == AccountType.creditCard ? creditLimit : null,
            billingDate: _selectedType == AccountType.creditCard ? _billingDate : null,
        );
      }

      final bankAccountState = ref.read(bankAccountNotifierProvider);
      if (bankAccountState.hasValue || bankAccountState.hasError) {
        if (mounted) {
          if (bankAccountState.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${bankAccountState.error}'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing 
                    ? 'Bank account updated successfully!' 
                    : 'Bank account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankAccountState = ref.watch(bankAccountNotifierProvider);
    final isLoading = bankAccountState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Bank Account' : 'Add Bank Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Account Name',
                hintText: 'Enter account name (e.g., Primary Account)',
                prefixIcon: Icons.account_balance,
                validator: RequiredValidator(errorText: 'Account name is required'),
                textInputAction: TextInputAction.next,
                readOnly: isLoading,
              ),

              const SizedBox(height: 16),

              // Bank Name
              CustomTextField(
                controller: _bankNameController,
                labelText: 'Bank/Institution Name',
                hintText: 'Enter bank or institution name',
                prefixIcon: Icons.business,
                validator: RequiredValidator(errorText: 'Bank name is required'),
                textInputAction: TextInputAction.next,
                readOnly: isLoading,
              ),

              const SizedBox(height: 16),

              // Account Number
              CustomTextField(
                controller: _accountNumberController,
                labelText: 'Account Number',
                hintText: 'Enter account number',
                prefixIcon: Icons.numbers,
                validator: RequiredValidator(errorText: 'Account number is required'),
                textInputAction: TextInputAction.next,
                readOnly: isLoading,
              ),

              const SizedBox(height: 16),

              // Account Type
              Text(
                'Account Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AccountType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: AccountType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_getAccountTypeIcon(type)),
                      const SizedBox(width: 8),
                      Text(_getAccountTypeName(type)),
                    ],
                  ),
                )).toList(),
                onChanged: isLoading ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),


              // IFSC Code (optional for bank accounts)
              if (_selectedType == AccountType.bank)
                Column(
                  children: [
                    CustomTextField(
                      controller: _ifscCodeController,
                      labelText: 'IFSC Code (Optional)',
                      hintText: 'Enter IFSC code',
                      prefixIcon: Icons.code,
                      textInputAction: TextInputAction.next,
                      readOnly: isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Branch Name (optional for bank accounts)
              if (_selectedType == AccountType.bank)
                Column(
                  children: [
                    CustomTextField(
                      controller: _branchNameController,
                      labelText: 'Branch Name (Optional)',
                      hintText: 'Enter branch name',
                      prefixIcon: Icons.location_on,
                      textInputAction: TextInputAction.next,
                      readOnly: isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Credit Card Fields
              if (_selectedType == AccountType.creditCard || _selectedType == AccountType.debitCard)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _cardNumberController,
                      labelText: 'Card Number',
                      hintText: 'Enter card number',
                      prefixIcon: Icons.credit_card,
                      validator: RequiredValidator(errorText: 'Card number is required'),
                      textInputAction: TextInputAction.next,
                      readOnly: isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _expiryController,
                            labelText: 'Expiry (MM/YY)',
                            hintText: 'MM/YY',
                            prefixIcon: Icons.calendar_today,
                            validator: RequiredValidator(errorText: 'Expiry is required'),
                            textInputAction: TextInputAction.next,
                            readOnly: isLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _cvvController,
                            labelText: 'CVV',
                            hintText: 'CVV',
                            prefixIcon: Icons.lock,
                            validator: RequiredValidator(errorText: 'CVV is required'),
                            textInputAction: TextInputAction.next,
                            readOnly: isLoading,
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedType == AccountType.creditCard)
                      CustomTextField(
                        controller: _creditLimitController,
                        labelText: 'Credit Limit',
                        hintText: 'Enter credit limit',
                        prefixIcon: Icons.trending_up,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: RequiredValidator(errorText: 'Credit limit is required'),
                        textInputAction: TextInputAction.next,
                        readOnly: isLoading,
                      ),
                    if (_selectedType == AccountType.creditCard)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Text('Billing Date', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: isLoading
                                ? null
                                : () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _billingDate ?? now,
                                      firstDate: DateTime(now.year - 1),
                                      lastDate: DateTime(now.year + 5),
                                      helpText: 'Select Billing Date',
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _billingDate = picked;
                                      });
                                    }
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event, color: Colors.grey[700]),
                                  const SizedBox(width: 10),
                                  Text(
                                    _billingDate != null
                                        ? '${_billingDate!.day.toString().padLeft(2, '0')}/${_billingDate!.month.toString().padLeft(2, '0')}/${_billingDate!.year}'
                                        : 'Select billing date',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Initial Balance
              CustomTextField(
                controller: _balanceController,
                labelText: 'Current Balance',
                hintText: 'Enter current balance',
                prefixIcon: Icons.account_balance_wallet,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Balance is required'),
                  PatternValidator(r'^-?\d+\.?\d{0,2}$', errorText: 'Enter a valid amount'),
                ]),
                textInputAction: TextInputAction.next,
                readOnly: isLoading,
              ),

              const SizedBox(height: 16),

              // Color Selection
              Text(
                'Account Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: LabelColor.values.map((color) => GestureDetector(
                  onTap: isLoading ? null : () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(color.colorValue),
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                )).toList(),
              ),

              const SizedBox(height: 16),

              // Description (Optional)
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                hintText: 'Enter description or notes',
                prefixIcon: Icons.description,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                readOnly: isLoading,
              ),

              const SizedBox(height: 16),

              // Set as Default
              Card(
                child: SwitchListTile(
                  title: const Text('Set as Default Account'),
                  subtitle: const Text('Use this account as the default for new transactions'),
                  value: _isDefault,
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: isLoading 
                    ? (_isEditing ? 'Updating...' : 'Creating...') 
                    : (_isEditing ? 'Update Account' : 'Create Account'),
                onPressed: isLoading ? null : _handleSubmit,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.wallet:
        return Icons.account_balance_wallet;
      case AccountType.cash:
        return Icons.money;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.debitCard:
        return Icons.payment;
    }
  }

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.wallet:
        return 'Digital Wallet';
      case AccountType.cash:
        return 'Cash';
      case AccountType.creditCard:
        return 'Credit Card';
      case AccountType.debitCard:
        return 'Debit Card';
    }
  }
}
