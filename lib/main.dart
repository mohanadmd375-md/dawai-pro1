import 'package:flutter/material.dart';

void main() {
  runApp(const DawaiProApp());
}

class DawaiProApp extends StatelessWidget {
  const DawaiProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAWAI PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دوائي برو - DAWAI PRO'),
      ),
      body: const Center(
        child: Text(
          'مرحباً بك في تطبيق دوائي برو',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
