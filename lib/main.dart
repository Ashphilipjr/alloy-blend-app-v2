import 'package:flutter/material.dart';
import 'screens/grade_list_screen.dart';

void main() {
  runApp(const AlloyBlendApp());
}

class AlloyBlendApp extends StatelessWidget {
  const AlloyBlendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alloy Blend Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const GradeListScreen(),
    );
  }
}
