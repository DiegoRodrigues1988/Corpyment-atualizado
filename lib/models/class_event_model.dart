// lib/models/class_event_model.dart

class ClassEvent {
  final int? id;
  final DateTime date;
  final String time;
  final String studentIds; // IDs dos alunos, separados por vírgula. Ex: "1,5,12"
  final String studentNames; // Nomes para exibição rápida. Ex: "Ana, Bruno, Carla"
  final int instructorId; // --- NOVO CAMPO ---

  ClassEvent({
    this.id,
    required this.date,
    required this.time,
    required this.studentIds,
    required this.studentNames,
    this.instructorId = 1, // --- NOVO CAMPO (padrão 1) ---
  });

  ClassEvent copyWith({int? id, int? instructorId}) {
    return ClassEvent(
        id: id ?? this.id,
        date: date,
        time: time,
        studentIds: studentIds,
        studentNames: studentNames,
        instructorId: instructorId ?? this.instructorId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().substring(0, 10), // Salva apenas a data (YYYY-MM-DD)
      'time': time,
      'studentIds': studentIds,
      'studentNames': studentNames,
      'instructorId': instructorId, // --- NOVO CAMPO ---
    };
  }

  static ClassEvent fromMap(Map<String, dynamic> map) {
    return ClassEvent(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      studentIds: map['studentIds'] as String,
      studentNames: map['studentNames'] as String,
      instructorId: map['instructorId'] as int? ?? 1, // --- NOVO CAMPO (com padrão) ---
    );
  }
}