import 'package:flutter/material.dart';

void main() {
  runApp(const NucleusApp());
}

class NucleusApp extends StatelessWidget {
  const NucleusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nucleus',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const HarmonizedViewPage(),
    );
  }
}

class HarmonizedViewPage extends StatelessWidget {
  const HarmonizedViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nucleus')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_outlined, size: 64),
              SizedBox(height: 16),
              Text(
                'No cloud accounts connected yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Connect a provider to see your harmonized file view.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null,
        icon: const Icon(Icons.add),
        label: const Text('Connect provider'),
      ),
    );
  }
}
