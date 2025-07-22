import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/models/label_model.dart';
import 'package:my_money/features/labels/providers/label_providers.dart';

class LabelSelector extends ConsumerStatefulWidget {
  const LabelSelector({
    required this.labelType,
    required this.selectedLabelIds,
    required this.onLabelsChanged,
    super.key,
    this.maxSelection,
  });

  final LabelType labelType;
  final List<String> selectedLabelIds;
  final Function(List<LabelModel>) onLabelsChanged;
  final int? maxSelection;

  @override
  ConsumerState<LabelSelector> createState() => _LabelSelectorState();
}

class _LabelSelectorState extends ConsumerState<LabelSelector> {
  List<LabelModel> _selectedLabels = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedLabels();
  }

  Future<void> _loadSelectedLabels() async {
    if (widget.selectedLabelIds.isNotEmpty) {
      try {
        final labels = await ref.read(labelsByIdsProvider(widget.selectedLabelIds).future);
        setState(() {
          _selectedLabels = labels;
        });
      } catch (e) {
        // Handle error silently or show a snackbar
        debugPrint('Error loading selected labels: $e');
      }
    }
  }

  void _toggleLabel(LabelModel label) {
    setState(() {
      final isSelected = _selectedLabels.any((l) => l.id == label.id);
      
      if (isSelected) {
        _selectedLabels.removeWhere((l) => l.id == label.id);
      } else {
        // Check max selection limit
        if (widget.maxSelection != null && _selectedLabels.length >= widget.maxSelection!) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You can select up to ${widget.maxSelection} labels'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        _selectedLabels.add(label);
      }
    });
    
    widget.onLabelsChanged(_selectedLabels);
  }

  void _showCreateLabelDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _CreateLabelDialog(
        labelType: widget.labelType,
        onLabelCreated: (label) {
          // Refresh the labels list and auto-select the new label
          ref.invalidate(labelsStreamProvider(widget.labelType));
          _toggleLabel(label);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelsAsync = ref.watch(labelsStreamProvider(widget.labelType));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Labels',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: _showCreateLabelDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            labelsAsync.when(
              data: (labels) {
                if (labels.isEmpty) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.label_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No ${widget.labelType.value} labels found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showCreateLabelDialog,
                        child: const Text('Create your first label'),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    // Selected labels
                    if (_selectedLabels.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _selectedLabels.map((label) => Chip(
                          avatar: CircleAvatar(
                            backgroundColor: label.colorValue,
                            child: Icon(
                              label.iconData,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          label: Text(label.name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _toggleLabel(label),
                        )).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                    ],

                    // Available labels
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: labels.map((label) {
                        final isSelected = _selectedLabels.any((l) => l.id == label.id);
                        
                        return FilterChip(
                          avatar: CircleAvatar(
                            backgroundColor: label.colorValue,
                            child: Icon(
                              label.iconData,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          label: Text(label.name),
                          selected: isSelected,
                          onSelected: (_) => _toggleLabel(label),
                          selectedColor: label.colorValue.withOpacity(0.2),
                          checkmarkColor: label.colorValue,
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading labels',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(labelsStreamProvider(widget.labelType));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateLabelDialog extends ConsumerStatefulWidget {
  const _CreateLabelDialog({
    required this.labelType,
    required this.onLabelCreated,
  });

  final LabelType labelType;
  final Function(LabelModel) onLabelCreated;

  @override
  ConsumerState<_CreateLabelDialog> createState() => _CreateLabelDialogState();
}

class _CreateLabelDialogState extends ConsumerState<_CreateLabelDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  LabelColor _selectedColor = LabelColor.blue;
  String? _selectedIcon;

  final List<String> _availableIcons = [
    'work', 'home', 'food', 'transport', 'entertainment', 'health',
    'education', 'shopping', 'travel', 'investment', 'savings', 'gift',
    'bills', 'insurance', 'taxes'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Label name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(labelNotifierProvider.notifier).createLabel(
            name: _nameController.text.trim(),
            type: widget.labelType,
            color: _selectedColor,
            icon: _selectedIcon,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          );

      final labelState = ref.read(labelNotifierProvider);
      if (labelState.hasValue && labelState.value != null) {
        widget.onLabelCreated(labelState.value!);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating label: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelState = ref.watch(labelNotifierProvider);
    final isLoading = labelState is AsyncLoading;

    return AlertDialog(
      title: Text('Create ${widget.labelType.value.toUpperCase()} Label'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Label Name',
                hintText: 'Enter label name',
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 16),
            
            // Color selection
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: LabelColor.values.map((color) => GestureDetector(
                onTap: isLoading ? null : () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(color.colorValue),
                    shape: BoxShape.circle,
                    border: _selectedColor == color
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Icon selection
            Text(
              'Icon (Optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableIcons.map((iconName) {
                final isSelected = _selectedIcon == iconName;
                return GestureDetector(
                  onTap: isLoading ? null : () {
                    setState(() {
                      _selectedIcon = isSelected ? null : iconName;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Theme.of(context).primaryColor)
                          : null,
                    ),
                    child: Icon(
                      _getIconData(iconName),
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _handleCreate,
          child: isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'investment':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      case 'gift':
        return Icons.card_giftcard;
      case 'bills':
        return Icons.receipt;
      case 'insurance':
        return Icons.security;
      case 'taxes':
        return Icons.account_balance;
      default:
        return Icons.label;
    }
  }
}
