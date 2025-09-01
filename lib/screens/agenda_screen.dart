// lib/screens/agenda_screen.dart

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';
import '../models/class_event_model.dart';
import '../models/student_model.dart';
import 'schedule_class_screen.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final LinkedHashMap<DateTime, List<ClassEvent>> _eventsByDay;
  List<ClassEvent> _selectedDayEvents = [];

  final List<String> _workoutSteps = const [
    'Cadillac', 'Barrel', 'Chair', 'Reformer', 'Mat', 'Acessórios'
  ];

  // --- NOVO --- Mapa de cores dos instrutores
  final Map<int, Color> _instructorColors = {
    1: Colors.purple,
    2: Colors.green,
    3: Colors.blue.shade900,
    4: Colors.orange,
    5: Colors.pink,
    6: Colors.grey.shade300,
    7: Colors.black87,
    8: Colors.yellow.shade700,
    9: Colors.lightGreen,
    10: Colors.grey.shade700,
  };

  // --- NOVA --- Função para pegar a cor do texto que contrasta com o fundo
  Color getTextColorForBackground(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark) {
      return Colors.white;
    }
    return Colors.black;
  }


  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _eventsByDay = LinkedHashMap<DateTime, List<ClassEvent>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    _loadAllEvents();
  }

  Future<void> _loadAllEvents() async {
    final allEvents = await DatabaseHelper.instance.readAllEvents();
    _eventsByDay.clear();
    for (final event in allEvents) {
      final day = DateTime.utc(event.date.year, event.date.month, event.date.day);
      if (_eventsByDay[day] == null) {
        _eventsByDay[day] = [];
      }
      _eventsByDay[day]!.add(event);
    }
    if (mounted && _selectedDay != null) {
      _selectedDayEvents = _getEventsForDay(_selectedDay!);
      setState(() {});
    }
  }

  List<ClassEvent> _getEventsForDay(DateTime day) {
    return _eventsByDay[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  Future<void> _contactStudent(String studentName, ClassEvent event) async {
    final students = await DatabaseHelper.instance.readAllStudents();
    try {
      final student = students.firstWhere((s) => s.name.trim() == studentName.trim());
      final formattedDate = DateFormat('dd/MM/yyyy').format(event.date);
      final message = "Olá, ${student.name}! Lembrete da sua aula de Pilates agendada para o dia $formattedDate às ${event.time}.";
      final Uri whatsappUri = Uri.parse("https://wa.me/${student.phone}?text=${Uri.encodeComponent(message)}");
      if (!mounted) return;
      if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Não foi possível abrir o WhatsApp.")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Não foi possível encontrar o contato para $studentName.")));
    }
  }

  Future<void> _showStudentProgressDialog(String studentName, ClassEvent event) async {
    final students = await DatabaseHelper.instance.readAllStudents();
    final Student? student = students.firstWhere((s) => s.name.trim() == studentName.trim(), orElse: () => null!);

    if (student == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível carregar os dados para $studentName.')),);
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        Student tempStudent = student;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> updateStep(int step) async {
              final nextStep = (step == _workoutSteps.length) ? 1 : step + 1;
              final updatedStudent = tempStudent.copyWith(workoutStep: nextStep);
              await DatabaseHelper.instance.update(updatedStudent);
              setDialogState(() {
                tempStudent = updatedStudent;
              });
            }

            return AlertDialog(
              title: Text(tempStudent.name),
              content: Wrap(
                spacing: 8.0, runSpacing: 8.0,
                children: _workoutSteps.asMap().entries.map((entry) {
                  final int index = entry.key; final String name = entry.value; final int currentStepNumber = index + 1;
                  final bool isDone = currentStepNumber < tempStudent.workoutStep; final bool isNext = currentStepNumber == tempStudent.workoutStep;
                  Color chipColor; Color textColor;
                  if (isDone) { chipColor = Colors.orange.shade300; textColor = Colors.white; }
                  else if (isNext) { chipColor = Colors.green.shade400; textColor = Colors.white; }
                  else { chipColor = Colors.grey.shade300; textColor = Colors.black87; }
                  return GestureDetector(
                    onTap: () => updateStep(currentStepNumber),
                    child: Chip(
                      backgroundColor: chipColor,
                      label: Text('${currentStepNumber}. $name', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      avatar: isDone ? Icon(Icons.check, color: textColor, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.message, color: Colors.green), label: const Text('WhatsApp', style: TextStyle(color: Colors.green)),
                  onPressed: () { Navigator.of(context).pop(); _contactStudent(tempStudent.name, event); },
                ),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('FECHAR')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Aulas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), tooltip: 'Agendar Nova Aula',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ScheduleClassScreen(selectedDate: _selectedDay!)),
              );
              if (result == true) { _loadAllEvents(); }
            },
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<ClassEvent>(
            locale: 'pt_BR', firstDay: DateTime.utc(2020), lastDay: DateTime.utc(2030), focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected, eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(128), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.green[700], shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          ),
          const Divider(),
          Expanded(
            child: _selectedDayEvents.isEmpty
                ? const Center(child: Text('Nenhuma aula agendada para este dia.'))
                : ListView.builder(
              itemCount: _selectedDayEvents.length,
              itemBuilder: (context, index) {
                final event = _selectedDayEvents[index];
                final studentNames = event.studentNames.split(',');
                // --- MUDANÇA PRINCIPAL AQUI ---
                final cardColor = _instructorColors[event.instructorId] ?? Colors.grey;
                final textColor = getTextColorForBackground(cardColor);
                final iconColor = textColor.withOpacity(0.8);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: cardColor, // Define a cor do card
                  child: ExpansionTile(
                    iconColor: iconColor,
                    collapsedIconColor: iconColor,
                    leading: Icon(Icons.access_time, color: iconColor),
                    title: Text(
                      "Instrutor ${event.instructorId} - Aula às ${event.time}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: textColor.withOpacity(0.7)),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteClassEvent(event.id!);
                        await NotificationHelper().cancelNotificationForClass(event.id!);
                        _loadAllEvents();
                      },
                    ),
                    children: studentNames.map((name) => ListTile(
                      title: Text(name.trim(), style: TextStyle(color: textColor)),
                      onTap: () => _showStudentProgressDialog(name.trim(), event),
                      trailing: Icon(Icons.touch_app, color: iconColor),
                    )).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}