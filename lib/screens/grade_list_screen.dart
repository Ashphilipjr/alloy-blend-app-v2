import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'grade_detail_screen.dart';

class GradeListScreen extends StatefulWidget {
  const GradeListScreen({super.key});
  @override
  State<GradeListScreen> createState() => _GradeListScreenState();
}

class _GradeListScreenState extends State<GradeListScreen> {
  List<Map<String, dynamic>> _grades = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DatabaseHelper.instance.getGrades();
    setState(() => _grades = rows);
  }

  Future<void> _delete(int id) async {
    await DatabaseHelper.instance.deleteGrade(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grade Directory')),
      body: _grades.isEmpty
          ? const Center(child: Text('No grades yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _grades.length,
              itemBuilder: (context, i) {
                final g = _grades[i];
                return Dismissible(
                  key: ValueKey(g['id']),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _delete(g['id']),
                  child: ListTile(
                    title: Text(g['name']),
                    subtitle: (g['standard'] ?? '').isNotEmpty
                        ? Text(g['standard'])
                        : null,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GradeDetailScreen(gradeId: g['id']),
                        ),
                      );
                      _load();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GradeDetailScreen(gradeId: null),
            ),
          );
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
