import 'package:flutter/material.dart';
import 'TransactionDetailsScreen.dart';
import 'TransactionService.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:random_color/random_color.dart';


class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late TransactionService _transactionService;
  late List<Transaction> _transactions;
  bool _isLoading = true; // Variable pour gérer l'état de chargement
  final double thresholdAmount = 700.0; // Define the threshold amount
  final double thresholdGeneralAmount = 2300.0; // Define the threshold for total general amount


  // Add this member variable to store the map
  Map<String, List<Transaction>> nameToTransactions = {};

  @override
  void initState() {
    super.initState();
    _transactionService = TransactionService(Dio());
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _transactionService.getTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false; // Mettre à jour l'état une fois le chargement terminé

      // Update the nameToTransactions map here
      nameToTransactions = groupTransactionsByName(transactions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Afficher le CircularProgressIndicator pendant le chargement
          : _buildTransactionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  // Add this method to group transactions by name
  Map<String, List<Transaction>> groupTransactionsByName(List<Transaction> transactions) {
    final Map<String, List<Transaction>> result = {};
    for (var transaction in transactions) {
      if (result.containsKey(transaction.name)) {
        result[transaction.name]!.add(transaction);
      } else {
        result[transaction.name] = [transaction];
      }
    }
    return result;
  }


  Widget _buildTransactionList() {
    double totalAmount = 0.0;
    Map<String, List<Transaction>> nameToTransactions = {}; // Map to group transactions by name

    if (_transactions.isEmpty) {
      return Center(child: Text('No transactions available.'));
    } else {
      for (var transaction in _transactions) {
        totalAmount += double.parse(transaction.amount);
      }
      // Group transactions by name
      for (var transaction in _transactions) {
        if (nameToTransactions.containsKey(transaction.name)) {
          nameToTransactions[transaction.name]!.add(transaction);
        } else {
          nameToTransactions[transaction.name] = [transaction];
        }
      }

      // Determine color based on threshold for total general amount
      Color generalAmountColor = totalAmount > thresholdGeneralAmount ? Colors.red : Colors.black;

      return ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsScreen(_transactions),
                ),
              );
            },
            child: Text('View All Transactions'),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: nameToTransactions.length,
            itemBuilder: (context, index) {
              final name = nameToTransactions.keys.elementAt(index);
              final transactions = nameToTransactions[name]!;
              double nameTotalAmount = 0.0;

              for (var transaction in transactions) {
                nameTotalAmount += double.parse(transaction.amount);
                totalAmount += double.parse(transaction.amount);
              }

              // Determine color based on threshold
              Color tileColor = nameTotalAmount > thresholdAmount ? Colors.red : Colors.white;

              return ListTile(
                title: Row(
                  children: [
                    Text(name),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTransactionsWithName(name),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                subtitle: Text('Total Amount: $nameTotalAmount'),
                tileColor: tileColor, // Apply the determined color
              );
            },
          ),

          // Ajoutez ce widget pour afficher le graphique circulaire
          Container(
            height: 300, // Hauteur du graphique
            child: _buildPieChart(), // Méthode pour construire le graphique
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total General Amount: $totalAmount', // Display the total general amount
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: generalAmountColor,),
            ),
          ),
        ],
      );
    }
  }
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: _buildPieChartSections(), // Sections du graphique
        centerSpaceRadius: 40, // Rayon de l'espace central (peut être ajusté)
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    List<PieChartSectionData> sections = [];

    // Créez une instance de RandomColor
    final randomColor = RandomColor();

    // Parcourez les transactions groupées par nom et ajoutez-les au graphique
    nameToTransactions.forEach((name, transactions) {
      double totalAmount = 0.0;

      for (var transaction in transactions) {
        totalAmount += double.parse(transaction.amount);
      }

      sections.add(
        PieChartSectionData(
          title: '$totalAmount',
          value: totalAmount,
          color: randomColor.randomColor(), // Génère une couleur aléatoire
          showTitle: true,
        ),
      );
    });

    return sections;
  }




  void _deleteTransactionsWithName(String name) async {
    try {
      final transactionsToDelete = nameToTransactions[name]!;

      // Show a confirmation dialog
      final confirmed = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete all transactions with name "$name"?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // Cancel
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // Confirm
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // If user confirmed, proceed with deletion
      if (confirmed == true) {
        for (var transaction in transactionsToDelete) {
          await _transactionService.deleteTransaction(transaction.id);
        }

        _loadTransactions();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Transactions deleted successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error deleting transactions: $error');
    }
  }


  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        double amount = 0.0;

        return AlertDialog(
          title: Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => name = value,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
                decoration: InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newTransaction = Transaction(
                  id: _transactions.length + 1,
                  name: name,
                  amount: amount.toString(),
                  date: DateTime.now().toString(),
                );

                await _transactionService.addTransaction(newTransaction.toJson());

                _loadTransactions();
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Success'),
                      content: Text('Transaction added successfully.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

}
