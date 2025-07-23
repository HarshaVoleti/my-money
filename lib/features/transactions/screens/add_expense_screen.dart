import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'dart:io';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/label_model.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/core/models/transaction_model.dart';
import 'package:my_money/features/transactions/widgets/label_selector.dart';
import 'package:my_money/features/transactions/widgets/bank_account_selector.dart';
import 'package:my_money/features/transactions/widgets/bill_image_picker.dart';
import 'package:my_money/features/transactions/providers/transaction_provider.dart';
import 'package:my_money/features/labels/providers/label_providers.dart';
import 'package:my_money/shared/widgets/custom_button.dart';
import 'package:my_money/shared/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction; // For editing existing expense
  
  const AddExpenseScreen({
    super.key,
    this.transaction,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedLabelIds = [];
  List<String> _tags = [];
  final _tagController = TextEditingController();
  BankAccountModel? _selectedBankAccount;
  List<File> _billImages = [];
  String _selectedPaymentMethod = 'Cash';
  
  bool _isLoading = false;

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
    'Wallet',
    'Cheque',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForEditing();
  }

  void _initializeForEditing() {
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _selectedDate = transaction.date;
      _selectedLabelIds = List.from(transaction.labelIds);
      _tags = List.from(transaction.tags);
      _selectedPaymentMethod = transaction.paymentMethod;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _onLabelsSelected(List<LabelModel> labels) {
    setState(() {
      _selectedLabelIds = labels.map((label) => label.id).toList();
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _onBankAccountSelected(BankAccountModel? account) {
    setState(() {
      _selectedBankAccount = account;
    });
  }

  void _onBillImagesSelected(List<File> images) {
    setState(() {
      _billImages = images;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String get _primaryCategory {
    if (_selectedLabelIds.isNotEmpty) {
      // Get the first selected label as primary category
      final expenseLabels = ref.read(expenseLabelsProvider);
      return expenseLabels.when(
        data: (labels) {
          final selectedLabel = labels.firstWhere(
            (label) => label.id == _selectedLabelIds.first,
            orElse: () => labels.first,
          );
          return selectedLabel.name;
        },
        loading: () => 'Expense',
        error: (_, __) => 'Expense',
      );
    }
    return 'Expense';
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLabelIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one expense category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
      
      final transaction = TransactionModel(
        id: widget.transaction?.id ?? const Uuid().v4(),
        userId: widget.transaction?.userId ?? '', // Will be set by provider
        amount: double.parse(_amountController.text),
        type: TransactionType.expense,
        category: _primaryCategory,
        description: _descriptionController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        accountName: _selectedBankAccount?.name,
        labelIds: _selectedLabelIds,
        tags: _tags,
        date: _selectedDate,
        createdAt: widget.transaction?.createdAt ?? DateTime.now(),
        updatedAt: widget.transaction != null ? DateTime.now() : null,
      );

      if (widget.transaction != null) {
        // Update existing expense  
        await transactionNotifier.updateTransaction(transaction);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new expense
        await transactionNotifier.addTransaction(
          amount: double.parse(_amountController.text),
          type: TransactionType.expense,
          category: _primaryCategory,
          description: _descriptionController.text.trim(),
          paymentMethod: _selectedPaymentMethod,
          accountName: _selectedBankAccount?.name,
          tags: _tags,
          labelIds: _selectedLabelIds,
          date: _selectedDate,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseLabels = ref.watch(expenseLabelsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction != null ? 'Edit Expense' : 'Add Expense'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header section with icon
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.remove_circle_outline,
                                size: 32,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.transaction != null ? 'Edit Expense' : 'Add New Expense',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Amount Field
                      CustomTextField(
                        controller: _amountController,
                        labelText: 'Amount *',
                        hintText: 'Enter expense amount',
                        prefixIcon: Icons.currency_rupee,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Amount is required'),
                          // PatternValidator(r'^\d+\.?\d{0,2}[0m$', errorText: 'Enter a valid amount'),
                        ]).call,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      // Description Field
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description *',
                        hintText: 'Enter description (e.g., Groceries, Rent)',
                        prefixIcon: Icons.description,
                        validator: RequiredValidator(errorText: 'Description is required'),
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      // Date Selector
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _selectDate,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Transaction Date',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bank Account Selector
                      BankAccountSelector(
                        label: 'Bank Account *',
                        selectedAccountId: _selectedBankAccount?.id,
                        onAccountSelected: _onBankAccountSelected,
                        isRequired: true,
                      ),
                      const SizedBox(height: 24),
                      // Payment Method Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Payment Method *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          }
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Select payment method' : null,
                      ),
                      const SizedBox(height: 24),
                      // Label Selector Section
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.category,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Expense Categories',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              expenseLabels.when(
                                data: (labels) => LabelSelector(
                                  labelType: LabelType.expense,
                                  selectedLabelIds: _selectedLabelIds,
                                  onLabelsChanged: _onLabelsSelected,
                                ),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, stack) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: SelectableText('Error loading categories: $error')),
                                    IconButton(
                                      icon: const Icon(Icons.refresh),
                                      tooltip: 'Retry',
                                      onPressed: () => ref.refresh(expenseLabelsProvider),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tags Section
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.local_offer,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tags',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _tagController,
                                      decoration: const InputDecoration(
                                        labelText: 'Add tag',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.add),
                                      ),
                                      onSubmitted: (_) => _addTag(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _addTag,
                                    icon: const Icon(Icons.add_circle),
                                  ),
                                ],
                              ),
                              if (_tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _tags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      onDeleted: () => _removeTag(tag),
                                      deleteIcon: const Icon(Icons.close, size: 16),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bill Image Picker Section
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.receipt,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Attachments',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add photos of bills, receipts, or documents (optional)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              BillImagePicker(
                                onImagesChanged: _onBillImagesSelected,
                                initialImages: _billImages,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CustomButton(
                          text: _isLoading 
                              ? 'Saving...'
                              : (widget.transaction != null ? 'Update Expense' : 'Add Expense'),
                          onPressed: _isLoading ? null : _saveExpense,
                          backgroundColor: Colors.red[600],
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ),
        ),
      ),
    );
  }
}
