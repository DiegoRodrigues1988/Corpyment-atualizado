// lib/models/class_event_model.dart

class ClassEvent {
  final int? id;
  final DateTime date;
  final String time;
  final String studentIds;
  final String studentNames;
  final int instructorId;
  final bool isConcluded; // --- NOVO CAMPO ---

  ClassEvent({
    this.id,
    required this.date,
    required this.time,
    required this.studentIds,
    required this.studentNames,
    this.instructorId = 1,
    this.isConcluded = false, // --- NOVO CAMPO (padrão 'false') ---
  });

  ClassEvent copyWith({int? id, int? instructorId, bool? isConcluded}) {
    return ClassEvent(
      id: id ?? this.id,
      date: date,
      time: time,
      studentIds: studentIds,
      studentNames: studentNames,
      instructorId: instructorId ?? this.instructorId,
      isConcluded: isConcluded ?? this.isConcluded, // --- NOVO CAMPO ---
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().substring(0, 10),
      'time': time,
      'studentIds': studentIds,
      'studentNames': studentNames,
      'instructorId': instructorId,
      'isConcluded': isConcluded ? 1 : 0, // --- NOVO CAMPO (salva como 1 ou 0) ---
    };
  }

  static ClassEvent fromMap(Map<String, dynamic> map) {
    return ClassEvent(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      time: map['time'] as String,
      studentIds: map['studentIds'] as String,
      studentNames: map['studentNames'] as String,
      instructorId: map['instructorId'] as int? ?? 1,
      isConcluded: (map['isConcluded'] as int? ?? 0) == 1, // --- NOVO CAMPO (lê 1 ou 0) ---
    );
  }
}