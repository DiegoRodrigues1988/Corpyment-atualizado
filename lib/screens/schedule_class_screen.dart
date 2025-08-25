// lib/screens/schedule_class_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart'; // Importe o helper de notificação
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
  final List<Student> _selectedStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await DatabaseHelper.instance.readAllStudents();
    setState(() => _allStudents = students);
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
    );

    // Salva o evento e pega o objeto retornado com o ID
    final savedEvent = await DatabaseHelper.instance.createClassEvent(newEventData);

    // --- AGENDA A NOTIFICAÇÃO ---
    await NotificationHelper().scheduleNotificationForClass(savedEvent);

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agendar Aula para ${DateFormat('dd/MM/yyyy').format(widget.selectedDate)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(_selectedTime == null ? 'Selecionar Horário' : 'Horário: ${_selectedTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Selecione os Alunos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Expanded(
              child: _allStudents.isEmpty
                  ? const Center(child: Text('Nenhum aluno cadastrado.'))
                  : ListView.builder(
                itemCount: _allStudents.length,
                itemBuilder: (context, index) {
                  final student = _allStudents[index];
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
            ElevatedButton(onPressed: _saveClass, child: const Text('Salvar Aula')),
          ],
        ),
      ),
    );
  }
}
