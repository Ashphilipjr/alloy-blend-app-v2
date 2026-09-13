import 'package:flutter/material.dart';
import '../db/database_helper.dart';

const kElements = ['C','Si','Mn','P','S','Cr','Ni','Mo','Cu','N','Fe','Ti','Nb','Co','W','Al'];

class _ChemRow {
  String element;
  TextEditingController minC, maxC, targetC;
  _ChemRow(this.element)
      : minC = TextEditingController(),
        maxC = TextEditingController(),
        targetC = TextEditingController();
  Map<String, dynamic> toMap() => {
        'element': element,
        'min_pct': double.tryParse(minC.text),
        'max_pct': double.tryParse(maxC.text),
        'target_pct': double.tryParse(targetC.text),
      };
}

class GradeDetailScreen extends StatefulWidget {
  final int? gradeId;
  const GradeDetailScreen({super.key, required this.gradeId});
  @override
  State<GradeDetailScreen> createState() => _GradeDetailScreenState();
}

class _GradeDetailScreenState extends State<GradeDetailScreen> {
  final _nameC = TextEditingController();
  final _standardC = TextEditingController();
  final _notesC = TextEditingController();
  final List<_ChemRow> _chem = [];

  @override
  void initState() {
    super.initState();
    if (widget.gradeId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final db = DatabaseHelper.instance;
    final grades = await db.getGrades();
    final g = grades.firstWhere((r) => r['id'] == widget.gradeId);
    _nameC.text = g['name'];
    _standardC.text = g['standard'] ?? '';
    _notesC.text = g['notes'] ?? '';
    final chem = await db.getChemistry(widget.gradeId!);
    setState(() {
      for (var r in chem) {
        final row = _ChemRow(r['element']);
        row.minC.text = r['min_pct']?.toString() ?? '';
        row.maxC.text = r['max_pct']?.toString() ?? '';
        row.targetC.text = r['target_pct']?.toString() ?? '';
        _chem.add(row);
      }
    });
  }

  Future<void> _save() async {
    if (_nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade name is required')));
      return;
    }
    final db = DatabaseHelper.instance;
    final gradeRow = {
      'name': _nameC.text.trim(),
      'standard': _standardC.text.trim(),
      'notes': _notesC.text.trim(),
    };
    int id;
    if (widget.gradeId == null) {
      id = await db.insertGrade(gradeRow);
    } else {
      id = widget.gradeId!;
      await db.updateGrade(id, gradeRow);
    }
    await db.replaceChemistry(id, _chem.map((r) => r.toMap()).toList());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gradeId == null ? 'Add Grade' : 'Edit Grade'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _nameC,
            decoration: const InputDecoration(labelText: 'Grade name', hintText: 'e.g. 316L')),
        TextField(controller: _standardC,
            decoration: const InputDecoration(labelText: 'Standard', hintText: 'e.g. ASTM A959')),
        TextField(controller: _notesC,
            decoration: const InputDecoration(labelText: 'Notes')),
        const SizedBox(height: 24),
        Row(children: [
          const Text('Chemistry (% by weight)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _chem.add(_ChemRow(kElements.first))),
            icon: const Icon(Icons.add), label: const Text('Add element')),
        ]),
        for (int i = 0; i < _chem.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              DropdownButton<String>(
                value: _chem[i].element,
                items: kElements.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _chem[i].element = v!),
              ),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _chem[i].minC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Min'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _chem[i].maxC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Max'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _chem[i].targetC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target'))),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => setState(() => _chem.removeAt(i))),
            ]),
          ),
      ]),
    );
  }
}
