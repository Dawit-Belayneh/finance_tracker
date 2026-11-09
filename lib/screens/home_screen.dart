import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> items = ['Salary', 'Groceries', 'Transport'];

  void addItem() {
    setState(() {
      items.add('New item ${items.length + 1}');
    });
  }

  void updateItem(int index) {
    setState(() {
      items[index] = '${items[index]} (edited)';
    });
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(items[index]),
          onTap: () => updateItem(index),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => deleteItem(index),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}