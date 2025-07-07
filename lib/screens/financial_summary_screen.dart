import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../services/pdf_service.dart'; 

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  _FinancialSummaryScreenState createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    // Filter transactions for the selected month
    List<Transaction> monthlyTransactions = transactions.where((t) {
      return t.date.year == selectedMonth.year && t.date.month == selectedMonth.month;
    }).toList();

    // Calculate monthly income, expenses, and balance
    double totalIncome = monthlyTransactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);

    double totalExpenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);

    double balance = totalIncome - totalExpenses;

    // Categorized expense breakdown for the pie chart
    Map<String, double> categoryTotals = {};
    for (var transaction in monthlyTransactions.where((t) => t.type == 'expense')) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Financial Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            _buildMonthPicker(),
            const SizedBox(height: 10),
            _buildSummaryCard("Total Income", totalIncome, Colors.green),
            _buildSummaryCard("Total Expenses", totalExpenses, Colors.red),
            _buildSummaryCard("Balance", balance, Colors.blue),
            const SizedBox(height: 20),

            const Text("Expense Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            categoryTotals.isEmpty
                ? const Text("No expenses recorded for this month.", style: TextStyle(fontSize: 16))
                : SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: categoryTotals.entries.map((entry) {
                          return PieChartSectionData(
                            value: entry.value,
                            title: "${entry.key}\n\Frw ${entry.value.toStringAsFixed(2)}",
                            color: _getCategoryColor(entry.key),
                            radius: 80,
                            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            // Export PDF Button (Now with error handling)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Download PDF"),
                onPressed: () async {
                  try {
                    final file = await PDFService.generateTransactionReport(monthlyTransactions);
                    OpenFile.open(file.path);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to generate report: $e")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Month Picker Widget
  Widget _buildMonthPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
            });
          },
        ),
        Text(
          DateFormat.yMMMM().format(selectedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text("${amount.toStringAsFixed(2)}\ Frw", style: TextStyle(fontSize: 18, color: color)),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Groceries":
        return Colors.orange;
      case "Utilities":
        return Colors.blue;
      case "Entertainment":
        return Colors.purple;
      case "Salary":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
