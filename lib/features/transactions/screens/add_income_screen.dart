import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'dart:io';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/label_model.dart';
import 'package:my_money/core/models/bank_account_model.dart';
import 'package:my_money/features/transactions/widgets/label_selector.dart';
import 'package:my_money/features/transactions/widgets/bank_account_selector.dart';
import 'package:my_money/features/transactions/widgets/bill_image_picker.dart';
import 'package:my_money/shared/widgets/custom_button.dart';
import 'package:my_money/shared/widgets/custom_text_field.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedLabelIds = [];
  List<String> _tags = [];
  final _tagController = TextEditingController();
  BankAccountModel? _selectedBankAccount;
  List<File> _billImages = [];

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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // TODO: Add transaction creation logic here
      // For now, just show success message with the selected data
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final description = _descriptionController.text.trim();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Income added: ₹$amount to ${_selectedBankAccount!.name}\n'
            'Description: $description\n'
            'Labels: ${_selectedLabelIds.length}\n'
            'Images: ${_billImages.length}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding income: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32, // Account for padding
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add New Income',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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
                  hintText: 'Enter income amount',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Amount is required'),
                    PatternValidator(r'^\d+\.?\d{0,2}$', errorText: 'Enter a valid amount'),
                  ]),
                  textInputAction: TextInputAction.next,
                ),
                    
                const SizedBox(height: 20),
                    
                // Description Field
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description *',
                  hintText: 'Enter description (e.g., Salary, Freelance)',
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
                  onAccountSelected: (account) {
                    setState(() {
                      _selectedBankAccount = account;
                    });
                  },
                  isRequired: true,
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
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.label,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Income Categories',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LabelSelector(
                          labelType: LabelType.income,
                          selectedLabelIds: _selectedLabelIds,
                          onLabelsChanged: _onLabelsSelected,
                        ),
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
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.orange,
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
                          onImagesChanged: (images) {
                            setState(() {
                              _billImages = images;
                            });
                          },
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
                    text: 'Add Income',
                    onPressed: _handleSubmit,
                  ),
                ),
                    
                const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
