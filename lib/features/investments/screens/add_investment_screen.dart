import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/models/investment_model.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/features/investments/providers/investment_riverpod_providers.dart';
import 'package:my_money/shared/widgets/custom_text_field.dart';
import 'package:my_money/shared/widgets/custom_button.dart';

class AddInvestmentScreen extends ConsumerStatefulWidget {
  const AddInvestmentScreen({super.key, this.investment});

  final InvestmentModel? investment;

  @override
  ConsumerState<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _platformController = TextEditingController();

  InvestmentType _selectedType = InvestmentType.stocks;
  InvestmentStatus _selectedStatus = InvestmentStatus.active;
  DateTime _purchaseDate = DateTime.now();

  bool get _isEditing => widget.investment != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final investment = widget.investment!;
    _nameController.text = investment.name;
    _symbolController.text = investment.symbol ?? '';
    _quantityController.text = investment.quantity.toString();
    _purchasePriceController.text = investment.purchasePrice.toString();
    _currentPriceController.text = investment.currentPrice.toString();
    _platformController.text = investment.platform;
    _selectedType = investment.type;
    _selectedStatus = investment.status;
    _purchaseDate = investment.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currentPriceController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Investment' : 'Add Investment'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Investment Type Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Investment Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<InvestmentType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: InvestmentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
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
                        labelText: 'Investment Name',
                        hintText: 'e.g., Apple Inc., Reliance Mutual Fund',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter investment name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _symbolController,
                        labelText: 'Symbol (Optional)',
                        hintText: 'e.g., AAPL, RELIANCE',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _platformController,
                        labelText: 'Platform/Broker',
                        hintText: 'e.g., Zerodha, Groww, SBI',
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
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _quantityController,
                              labelText: 'Quantity/Units',
                              hintText: '100',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter quantity';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Please enter valid quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _purchasePriceController,
                              labelText: 'Purchase Price',
                              hintText: '150.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter purchase price';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Please enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _currentPriceController,
                        labelText: 'Current Price',
                        hintText: '175.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter current price';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Please enter valid price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      // Purchase Date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Purchase Date'),
                        subtitle: Text(
                          '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _purchaseDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _purchaseDate = date;
                            });
                          }
                        },
                      ),
                      const Divider(),
                      // Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status'),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<InvestmentStatus>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: InvestmentStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_getStatusName(status)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: _isEditing ? 'Update Investment' : 'Create Investment',
                onPressed: _saveInvestment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusName(InvestmentStatus status) {
    switch (status) {
      case InvestmentStatus.active:
        return 'Active';
      case InvestmentStatus.sold:
        return 'Sold';
      case InvestmentStatus.watchlist:
        return 'Watchlist';
      case InvestmentStatus.suspended:
        return 'Suspended';
    }
  }

  void _saveInvestment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final investmentProvider = ref.read(investmentProviderProvider);

    try {
      if (_isEditing) {
        // Update existing investment
        final updatedInvestment = widget.investment!.copyWith(
          name: _nameController.text.trim(),
          symbol: _symbolController.text.trim().isEmpty ? null : _symbolController.text.trim(),
          type: _selectedType,
          quantity: double.parse(_quantityController.text),
          purchasePrice: double.parse(_purchasePriceController.text),
          currentPrice: double.parse(_currentPriceController.text),
          platform: _platformController.text.trim(),
          status: _selectedStatus,
          purchaseDate: _purchaseDate,
          updatedAt: DateTime.now(),
        );
        
        await investmentProvider.updateInvestment(updatedInvestment);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Investment updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Create new investment
        await investmentProvider.addInvestment(
          name: _nameController.text.trim(),
          symbol: _symbolController.text.trim().isEmpty ? null : _symbolController.text.trim(),
          type: _selectedType,
          purchasePrice: double.parse(_purchasePriceController.text),
          quantity: double.parse(_quantityController.text),
          currentPrice: double.parse(_currentPriceController.text),
          purchaseDate: _purchaseDate,
          platform: _platformController.text.trim(),
          sector: null, // Could add sector field later
          tags: [], // Could add tags field later
          color: LabelColor.blue, // Could add color picker later
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Investment created successfully!')),
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
