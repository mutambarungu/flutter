import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context).transactions;

    return transactions.isEmpty
        ? Center(
            child: Text("No transactions added yet!",
                style: TextStyle(fontSize: 18)))
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (ctx, index) {
              final txn = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        txn.type == "income" ? Colors.green : Colors.red,
                    radius: 25,
                    child: Icon(
                      txn.type == "income"
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(txn.category,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(txn.description),
                  trailing: Text(
                    "\$${txn.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: txn.type == "income" ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
  }
}
