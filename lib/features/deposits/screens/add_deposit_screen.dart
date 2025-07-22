import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/deposit_model.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/features/deposits/providers/deposit_providers.dart';
import 'package:my_money/shared/widgets/custom_text_field.dart';
import 'package:my_money/shared/widgets/custom_button.dart';

class AddDepositScreen extends ConsumerStatefulWidget {
  const AddDepositScreen({super.key, this.deposit});

  final DepositModel? deposit;

  @override
  ConsumerState<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends ConsumerState<AddDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _bankController = TextEditingController();

  DepositType _selectedType = DepositType.fixedDeposit;
  DateTime _startDate = DateTime.now();
  bool _isAutoRenew = false;

  bool get _isEditing => widget.deposit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final deposit = widget.deposit!;
    _nameController.text = deposit.name;
    _descriptionController.text = deposit.description;
    _principalController.text = deposit.principalAmount.toString();
    _rateController.text = deposit.interestRate.toString();
    _tenureController.text = deposit.tenureMonths?.toString() ?? '';
    _bankController.text = deposit.bankName;
    _selectedType = deposit.type;
    _startDate = deposit.startDate;
    _isAutoRenew = deposit.autoRenewal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Deposit' : 'Add Deposit'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Deposit Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deposit Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DepositType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: DepositType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getDepositTypeName(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Deposit Name',
                        hintText: 'e.g., SBI FD 2025',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter deposit name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _bankController,
                        labelText: 'Bank/Institution',
                        hintText: 'e.g., State Bank of India',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        hintText: 'Brief description of the deposit',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Financial Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _principalController,
                        labelText: 'Principal Amount',
                        hintText: '50000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter principal amount';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _rateController,
                        labelText: 'Interest Rate (%)',
                        hintText: '7.5',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter interest rate';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter valid interest rate';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _tenureController,
                        labelText: 'Tenure (Months)',
                        hintText: '12',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter tenure';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Please enter valid tenure';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Options',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      // Start Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Start Date'),
                        subtitle: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                      ),
                      const Divider(),
                      // Auto Renew
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Auto Renew'),
                        subtitle: const Text('Automatically renew on maturity'),
                        value: _isAutoRenew,
                        onChanged: (value) {
                          setState(() {
                            _isAutoRenew = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes section removed since description is used instead
              
              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: _isEditing ? 'Update Deposit' : 'Create Deposit',
                onPressed: _saveDeposit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDepositTypeName(DepositType type) {
    switch (type) {
      case DepositType.fixedDeposit:
        return 'Fixed Deposit';
      case DepositType.recurringDeposit:
        return 'Recurring Deposit';
      case DepositType.ppf:
        return 'Public Provident Fund (PPF)';
      case DepositType.nsc:
        return 'National Savings Certificate (NSC)';
      case DepositType.savingsAccount:
        return 'Savings Account';
      case DepositType.currentAccount:
        return 'Current Account';
      case DepositType.other:
        return 'Other';
    }
  }

  DateTime _calculateMaturityDate() {
    if (_tenureController.text.isEmpty) return _startDate.add(const Duration(days: 365));
    
    final months = int.tryParse(_tenureController.text) ?? 12;
    return DateTime(
      _startDate.year,
      _startDate.month + months,
      _startDate.day,
    );
  }

  void _saveDeposit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final depositNotifier = ref.read(depositNotifierProvider.notifier);

    try {
      if (_isEditing) {
        // Update existing deposit
        final updatedDeposit = widget.deposit!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          principalAmount: double.parse(_principalController.text),
          interestRate: double.parse(_rateController.text),
          tenureMonths: int.tryParse(_tenureController.text),
          bankName: _bankController.text.trim(),
          type: _selectedType,
          startDate: _startDate,
          maturityDate: _calculateMaturityDate(),
          autoRenewal: _isAutoRenew,
        );
        
        await depositNotifier.updateDeposit(updatedDeposit);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deposit updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new deposit
        await depositNotifier.createDeposit(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          type: _selectedType,
          principalAmount: double.parse(_principalController.text),
          interestRate: double.parse(_rateController.text),
          startDate: _startDate,
          maturityDate: _calculateMaturityDate(),
          bankName: _bankController.text.trim(),
          tenureMonths: int.tryParse(_tenureController.text),
          autoRenewal: _isAutoRenew,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deposit created successfully!')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}
