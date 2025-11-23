import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Invoice'),
      ),
      body: const Center(
        child: Text('Invoice feature - To be implemented'),
      ),
    );
  }
}