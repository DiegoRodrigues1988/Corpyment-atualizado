// lib/screens/schedule_class_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';
import '../models/class_event_model.dart';
import '../models/student_model.dart';

class ScheduleClassScreen extends StatefulWidget {
  final DateTime selectedDate;
  const ScheduleClassScreen({super.key, required this.selectedDate});

  @override
  State<ScheduleClassScreen> createState() => _ScheduleClassScreenState();
}

class _ScheduleClassScreenState extends State<ScheduleClassScreen> {
  TimeOfDay? _selectedTime;
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  final List<Student> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedInstructorId = 1;

  final Map<int, Color> _instructorColors = {
    1: Colors.purple, 2: Colors.green, 3: Colors.blue.shade900,
    4: Colors.orange, 5: Colors.pink, 6: Colors.grey.shade300,
    7: Colors.black87, 8: Colors.yellow.shade700, 9: Colors.lightGreen,
    10: Colors.grey.shade700,
  };

  Color getTextColorForBackground(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final students = await DatabaseHelper.instance.readAllStudents();
    setState(() {
      _allStudents = students;
      _filteredStudents = students;
    });
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        return student.name.toLowerCase().startsWith(query);
      }).toList();
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveClass() async {
    if (_selectedTime == null || _selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um horário e pelo menos um aluno.')),
      );
      return;
    }

    final newEventData = ClassEvent(
      date: widget.selectedDate,
      time: _selectedTime!.format(context),
      studentIds: _selectedStudents.map((s) => s.id.toString()).join(','),
      studentNames: _selectedStudents.map((s) => s.name).join(', '),
      instructorId: _selectedInstructorId,
    );

    final savedEvent = await DatabaseHelper.instance.createClassEvent(newEventData);
    await NotificationHelper().scheduleNotificationForClass(savedEvent);

    if (mounted) Navigator.of(context).pop(true);
  }

  Widget _buildInstructorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16, bottom: 8),
          child: Text('Selecione o Instrutor(a)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: List.generate(10, (index) {
              final instructorId = index + 1;
              final isSelected = _selectedInstructorId == instructorId;
              final color = _instructorColors[instructorId] ?? Colors.grey;
              final textColor = getTextColorForBackground(color);

              return ChoiceChip(
                label: Text('Inst. $instructorId'),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedInstructorId = instructorId;
                    });
                  }
                },
                selectedColor: color,
                backgroundColor: color.withAlpha(64), // Correção de 'withOpacity'
                labelStyle: TextStyle(
                  color: isSelected ? textColor : color,
                  fontWeight: FontWeight.bold,
                ),
                avatar: isSelected ? Icon(Icons.check, color: textColor, size: 16) : null,
                side: isSelected ? BorderSide.none : BorderSide(color: color.withAlpha(153)), // Correção de 'withOpacity'
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Aula para ${DateFormat('dd/MM/yyyy').format(widget.selectedDate)}'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(_selectedTime == null ? 'Selecionar Horário' : 'Horário: ${_selectedTime!.format(context)}'),
            trailing: const Icon(Icons.access_time),
            onTap: _pickTime,
          ),
          const Divider(),
          _buildInstructorSelector(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar aluno pelo nome...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredStudents.isEmpty
                ? const Center(child: Text('Nenhum aluno encontrado.'))
                : ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                final isSelected = _selectedStudents.contains(student);
                return CheckboxListTile(
                  title: Text(student.name),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedStudents.add(student);
                      } else {
                        _selectedStudents.remove(student);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(onPressed: _saveClass, child: const Text('Salvar Aula')),
          ),
        ],
      ),
    );
  }
}