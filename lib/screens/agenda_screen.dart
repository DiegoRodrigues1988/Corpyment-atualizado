// lib/screens/agenda_screen.dart
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/database_helper.dart';
import '../models/class_event_model.dart';
import 'schedule_class_screen.dart';

// Função auxiliar para o LinkedHashMap, garantindo que as datas sejam comparadas corretamente.
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

  // Armazena todos os eventos carregados, organizados por dia.
  late final LinkedHashMap<DateTime, List<ClassEvent>> _eventsByDay;

  // Controla a lista de eventos para o dia que foi selecionado.
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

  // Carrega todos os eventos do banco de dados e os organiza no mapa _eventsByDay.
  Future<void> _loadAllEvents() async {
    final allEvents = await DatabaseHelper.instance.readAllEvents();
    _eventsByDay.clear();
    for (final event in allEvents) {
      // Normaliza a data para ignorar a hora, usando UTC para consistência.
      final day = DateTime.utc(event.date.year, event.date.month, event.date.day);
      if (_eventsByDay[day] == null) {
        _eventsByDay[day] = [];
      }
      _eventsByDay[day]!.add(event);
    }
    // Atualiza a lista de eventos para o dia atualmente selecionado.
    _selectedDayEvents = _getEventsForDay(_selectedDay!);
    setState(() {}); // Atualiza a UI para mostrar os marcadores.
  }

  // Função que o calendário usa para saber quais eventos mostrar para cada dia.
  List<ClassEvent> _getEventsForDay(DateTime day) {
    return _eventsByDay[day] ?? [];
  }

  // Chamado quando o usuário toca em um dia no calendário.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  Future<void> _contactStudent(String studentName) async {
    // ... (código para contatar aluno permanece o mesmo)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de Aulas')),
      body: Column(
        children: [
          TableCalendar<ClassEvent>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,

            // --- LÓGICA PARA MARCAR OS DIAS ---
            eventLoader: _getEventsForDay,

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withAlpha(128), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
              // Estilo do marcador de evento (o pontinho verde).
              markerDecoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
              ),
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
                        _loadAllEvents(); // Recarrega tudo para atualizar os marcadores
                      },
                    ),
                    children: studentNames.map((name) => ListTile(
                      title: Text(name.trim()),
                      trailing: IconButton(
                        icon: const Icon(Icons.message, color: Colors.green),
                        onPressed: () => _contactStudent(name.trim()),
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ScheduleClassScreen(selectedDate: _selectedDay!)),
          );
          if (result == true) {
            _loadAllEvents(); // Recarrega tudo para atualizar os marcadores
          }
        },
      ),
    );
  }
}
