// lib/models/class_event_model.dart

class ClassEvent {
  final int? id;
  final DateTime date;
  final String time;
  final String studentIds; // IDs dos alunos, separados por vírgula. Ex: "1,5,12"
  final String studentNames; // Nomes para exibição rápida. Ex: "Ana, Bruno, Carla"

  ClassEvent({
    this.id,
    required this.date,
    required this.time,
    required this.studentIds,
    required this.studentNames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().substring(0, 10), // Salva apenas a data (YYYY-MM-DD)
      'time': time,
      'studentIds': studentIds,
      'studentNames': studentNames,
    };
  }

  static ClassEvent fromMap(Map<String, dynamic> map) {
    return ClassEvent(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      studentIds: map['studentIds'] as String,
      studentNames: map['studentNames'] as String,
    );
  }
}
