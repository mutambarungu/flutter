import 'package:expense_tracker_pro/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortOption = 'Newest First';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    List<Transaction> transactions = List.from(
        transactionProvider.transactions); 

    // Apply Filters
    if (_selectedCategory != 'All') {
      transactions =
          transactions.where((t) => t.category == _selectedCategory).toList();
    }
    if (_startDate != null && _endDate != null) {
      transactions = transactions.where((t) {
        DateTime tDate = t.date; 
        return tDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            tDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

// Apply Sorting
    switch (_sortOption) {
      case 'Newest First':
        transactions.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest First':
        transactions.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest Amount':
        transactions.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest Amount':
        transactions.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    value: _selectedCategory,
                    items: [
                      'All',
                      'Groceries',
                      'Utilities',
                      'Entertainment',
                      'Salary',
                      'Other'
                    ]
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value.toString()),
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _selectDateRange(context),
                  child: const Text("Select Date Range"),
                ),
              ],
            ),
          ),

          // Sorting Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              value: _sortOption,
              items: [
                'Newest First',
                'Oldest First',
                'Highest Amount',
                'Lowest Amount'
              ]
                  .map((option) =>
                      DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _sortOption = value.toString()),
              decoration: const InputDecoration(labelText: "Sort By"),
            ),
          ),

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No transactions found."))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];

                      // Format Date Correctly
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(transaction.date);

                      return ListTile(
                        title: Text(transaction.category),
                        subtitle: Text(
                          "${transaction.type.capitalize()} • ${transaction.amount.toStringAsFixed(2)} \Frw •  $formattedDate",
                        ),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTransactionScreen(
                                    transaction: transaction),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Floating Action Button to Add Transactions
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Select Date Range Function
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Fetch transactions when screen loads
void _loadTransactions() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
  
  if (authProvider.isAuthenticated && authProvider.userEmail != null) {
    await transactionProvider.fetchTransactions(authProvider.userEmail!);
  } else {
    print("User not authenticated, cannot load transactions");
  }
}
}

extension StringCapitalizeExt on String {
  String capitalizeFirstLetter() => this[0].toUpperCase() + substring(1);
}
