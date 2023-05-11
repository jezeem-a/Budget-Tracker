import 'package:budget_tracker/model/transaction_item.dart';
import 'package:budget_tracker/view_models/budget_view_model.dart';
import 'package:budget_tracker/view_models/budget_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AddTransactionDialog(
                  itemToAdd: (transactionItem) {
                    final budgetViewModel =
                        Provider.of<BudgetViewModel>(context, listen: false);
                    budgetViewModel.addItem(transactionItem);
                  },
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: screenSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Consumer<BudgetViewModel>(
                    builder: (context, value, child) {
                      final balance = value.getBalance();
                      final budget = value.getBudget();
                      double percentage = balance / budget;
                      if (percentage < 0) {
                        percentage = 0;
                      }
                      if (percentage > 1) {
                        percentage = 1;
                      }

                      return CircularPercentIndicator(
                        radius: screenSize.width / 2,
                        lineWidth: 10.0,
                        percent: percentage,
                        backgroundColor: Colors.white,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "\$" + balance.toString().split(".")[0],
                              style: TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Balance",
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              "Budget: \$" + budget.toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        progressColor: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                const Text(
                  "Items",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<BudgetViewModel>(builder: ((context, value, child) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.items.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TransactionCard(
                          item: value.items[index],
                        );
                      });
                }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionItem item;
  const TransactionCard({this.item, Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const Text("Delete Item"),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final budgetViewModel = Provider.of<BudgetViewModel>(
                            context,
                            listen: false);
                        budgetViewModel.deleteItem(item);
                        Navigator.pop(context);
                      },
                      child: const Text("Yes"),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Yes"))
                  ],
                ),
              ),
            );
          })),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionItem) itemToAdd;
  const AddTransactionDialog({this.itemToAdd, Key key}) : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController itemTitleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool _isExpenseController = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.3,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const Text(
                "Add an expense",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: itemTitleController,
                decoration: const InputDecoration(hintText: "Name of expense"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  hintText: "Amount in \$",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Is Expensive?"),
                  Switch.adaptive(
                      value: _isExpenseController,
                      onChanged: (b) {
                        setState(() {
                          _isExpenseController = b;
                        });
                      }),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  if (amountController.text.isNotEmpty &&
                      itemTitleController.text.isNotEmpty) {
                    widget.itemToAdd(TransactionItem(
                      amount: double.parse(amountController.text),
                      itemTitle: itemTitleController.text,
                      isExpense: _isExpenseController,
                    ));
                    Navigator.pop(context);
                  }
                },
                child: Text("ADD"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
