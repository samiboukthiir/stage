import 'package:flutter/material.dart';
import 'TransactionService.dart';


class TransactionDetailsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  TransactionDetailsScreen(this.transactions);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Retour à la page précédente
            },
            child: Text('Back'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(transaction.name),
                  subtitle: Text('Amount: ${transaction.amount}, Date: ${transaction.date}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
