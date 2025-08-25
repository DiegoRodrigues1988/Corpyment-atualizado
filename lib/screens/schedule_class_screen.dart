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
  List<Student> _filteredStudents = []; // Nova lista para os resultados da busca
  final List<Student> _selectedStudents = [];
  final TextEditingController _searchController = TextEditingController(); // Controlador para o campo de busca

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents); // Adiciona um "ouvinte" para a busca
  }

  @override
  void dispose() {
    _searchController.dispose(); // Libera o controlador da memória
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final students = await DatabaseHelper.instance.readAllStudents();
    setState(() {
      _allStudents = students;
      _filteredStudents = students; // No início, a lista filtrada é a lista completa
    });
  }

  // Função que filtra os alunos com base no que foi digitado
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
    );

    final savedEvent = await DatabaseHelper.instance.createClassEvent(newEventData);
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

            // --- NOVO CAMPO DE BUSCA ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                itemCount: _filteredStudents.length, // Usa a lista filtrada
                itemBuilder: (context, index) {
                  final student = _filteredStudents[index]; // Usa a lista filtrada
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
