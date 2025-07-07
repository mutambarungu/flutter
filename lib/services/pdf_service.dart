import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction.dart';

class PDFService {
  static Future<File> generateTransactionReport(List<Transaction> transactions) async {
    final pdf = pw.Document();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Ensure proper date formatting

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Financial Transactions Report",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ["Date", "Category", "Type", "Amount", "Description"],
              data: transactions.map((t) {
                return [
                  dateFormat.format(t.date), // Correct date formatting
                  t.category,
                  t.type.toUpperCase(),
                  "\$${t.amount.toStringAsFixed(2)}",
                  t.description
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellPadding: pw.EdgeInsets.all(5),
            ),
          ],
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final file = File("${output.path}/transaction_report.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
