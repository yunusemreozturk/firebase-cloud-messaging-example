import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  final String? info;
  const SecondPage({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SecondPage')),
      body: Center(
        child: Text(info!),
      ),
    );
  }
}
