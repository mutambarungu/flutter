import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _selectedType = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.date;
  }

  void _updateTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final updatedTransaction = Transaction(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      type: _selectedType,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    Provider.of<TransactionProvider>(context, listen: false).updateTransaction(updatedTransaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction updated successfully!")),
    );

    Navigator.pop(context);
  }

  void _confirmUpdate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text("Are you sure you want to update this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateTransaction();
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransaction(widget.transaction.id);

              Navigator.pop(ctx);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Transaction deleted!")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: ['income', 'expense'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.capitalize()));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value ?? _selectedType),
                decoration: const InputDecoration(labelText: "Transaction Type"),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Amount is required";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Groceries', 'Utilities', 'Entertainment', 'Salary', 'Other'].map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value ?? _selectedCategory),
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 2,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Text("Date: ${DateFormat.yMMMd().format(_selectedDate)}",
                      style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text("Choose Date"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _confirmUpdate,
                child: const Text("Update Transaction"),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: _deleteTransaction,
                child: const Text("Delete Transaction", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}
