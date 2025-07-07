// import 'package:flutter/material.dart';
// import '../models/transaction.dart';
// import '../services/db_helper.dart';

// class TransactionProvider with ChangeNotifier {
//   final List<Transaction> _transactions = [];
//   final DBHelper _dbHelper = DBHelper();

//   List<Transaction> get transactions => List.unmodifiable(_transactions);

//   // Fetch transactions from the database
//   Future<void> fetchTransactions() async {
//     try {
//       final db = await _dbHelper.database;
//       final transactionList = await db.query('transactions');

//       _transactions.clear(); // Clear existing list before adding
//       _transactions.addAll(transactionList.map((txn) => Transaction.fromMap(txn)));

//       notifyListeners(); // 🔄 Refresh UI
//     } catch (e) {
//       print("Error fetching transactions: $e");
//     }
//   }

//   // Add a new transaction and store in the database
//   Future<void> addTransaction(Transaction transaction) async {
//     try {
//       final db = await _dbHelper.database;
//       await db.insert('transactions', transaction.toMap());

//       _transactions.add(transaction);
//       notifyListeners();
//     } catch (e) {
//       print("Error adding transaction: $e");
//     }
//   }

//   // Update a transaction
//   Future<void> updateTransaction(Transaction updatedTransaction) async {
//     try {
//       final db = await _dbHelper.database;
//       await db.update(
//         'transactions',
//         updatedTransaction.toMap(),
//         where: 'id = ?',
//         whereArgs: [updatedTransaction.id],
//       );

//       final index = _transactions.indexWhere((txn) => txn.id == updatedTransaction.id);
//       if (index != -1) {
//         _transactions[index] = updatedTransaction;
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Error updating transaction: $e");
//     }
//   }

//   // Delete a transaction
//   Future<void> deleteTransaction(String id) async {
//     try {
//       final db = await _dbHelper.database;
//       await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

//       _transactions.removeWhere((txn) => txn.id == id);
//       notifyListeners();
//     } catch (e) {
//       print(" Error deleting transaction: $e");
//     }
//   }
// }

import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final DBHelper _dbHelper = DBHelper();

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Fetch transactions from the database for a specific user
  Future<void> fetchTransactions(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      // ✅ Filter transactions by user_id
      final transactionList = await db.query(
        'transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      _transactions.clear(); // Clear existing list before adding
      _transactions.addAll(transactionList.map((txn) => Transaction.fromMap(txn)));

      notifyListeners(); // 🔄 Refresh UI
    } catch (e) {
      print("❌ Error fetching transactions: $e");
    }
  }

  /// Add a new transaction and store in the database
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('transactions', transaction.toMap());

      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      print("❌ Error adding transaction: $e");
    }
  }

  /// Update a transaction
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'transactions',
        updatedTransaction.toMap(),
        where: 'id = ?',
        whereArgs: [updatedTransaction.id],
      );
      
      final index = _transactions.indexWhere((txn) => txn.id == updatedTransaction.id);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error updating transaction: $e");
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

      _transactions.removeWhere((txn) => txn.id == id);
      notifyListeners();
    } catch (e) {
      print("❌ Error deleting transaction: $e");
    }
  }

  /// Clear all transactions (useful for logout)
  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }
}
