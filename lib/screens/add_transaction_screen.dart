import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart'; 
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedCategory = 'Groceries';
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  void _submitTransaction() {
    if (!_formKey.currentState!.validate()) return;

    // Get the actual logged-in user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (!authProvider.isAuthenticated || authProvider.userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to add transactions")),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(), 
      userId: authProvider.userEmail!,
      type: _selectedType,
      category: _selectedCategory,
      amount: double.parse(_amountController.text),
      date: _selectedDate, 
      description: _descriptionController.text.trim(),
    );

    Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction added successfully!")),
    );

    Navigator.pop(context);
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
      appBar: AppBar(title: const Text("Add Transaction")),
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
                onPressed: _submitTransaction,
                child: const Text("Add Transaction"),
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