// lib/screens/agenda_screen.dart
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';
import '../models/class_event_model.dart';
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
    _selectedDayEvents = _getEventsForDay(_selectedDay!);
    setState(() {});
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

  // --- FUNÇÃO DO WHATSAPP ATUALIZADA ---
  Future<void> _contactStudent(String studentName, ClassEvent event) async {
    final students = await DatabaseHelper.instance.readAllStudents();
    try {
      final student = students.firstWhere((s) => s.name.trim() == studentName.trim());

      // Formata a data e cria a mensagem personalizada
      final formattedDate = DateFormat('dd/MM/yyyy').format(event.date);
      final message = "Olá, ${student.name}! Lembrete da sua aula de Pilates agendada para o dia $formattedDate às ${event.time}.";

      // Codifica a mensagem para ser usada em uma URL
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Aulas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agendar Nova Aula',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ScheduleClassScreen(selectedDate: _selectedDay!)),
              );
              if (result == true) {
                _loadAllEvents();
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<ClassEvent>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    leading: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                    title: Text("Aula às ${event.time}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteClassEvent(event.id!);
                        await NotificationHelper().cancelNotificationForClass(event.id!);
                        _loadAllEvents();
                      },
                    ),
                    children: studentNames.map((name) => ListTile(
                      title: Text(name.trim()),
                      trailing: IconButton(
                        tooltip: 'Avisar no WhatsApp',
                        icon: const Icon(Icons.message, color: Colors.green),
                        // Passa o evento para a função de contato
                        onPressed: () => _contactStudent(name.trim(), event),
                      ),
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
