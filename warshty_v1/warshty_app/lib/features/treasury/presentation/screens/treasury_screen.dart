import 'package:flutter/material.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الخزينة')),
      body: const Center(child: Text('الخزينة')),
    );
  }
}
