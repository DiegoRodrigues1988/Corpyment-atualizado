// lib/models/student_model.dart

class Student {
  final int? id;
  final DateTime startDate;

  // --- Dados Pessoais ---
  final String name;
  final String email;
  final String phone;
  final String? birthDate;
  final String? cpf;
  final String? address;
  final String? emergencyContact;

  // --- Dados de Saúde ---
  final String? weight;
  final String? height;
  final String? medicalConditions;
  final String? injuryHistory;
  final String? surgeries;
  final String? medicalRestrictions;
  final String? medications;
  final String? activityLevel;

  // --- Controle Administrativo ---
  final String? plan;
  final String? paymentDetails;
  final String? schedule;
  final String? instructorNotes;

  Student({
    this.id,
    required this.startDate,
    // Pessoais
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    this.cpf,
    this.address,
    this.emergencyContact,
    // Saúde
    this.weight,
    this.height,
    this.medicalConditions,
    this.injuryHistory,
    this.surgeries,
    this.medicalRestrictions,
    this.medications,
    this.activityLevel,
    // Administrativo
    this.plan,
    this.paymentDetails,
    this.schedule,
    this.instructorNotes,
  });

  Student copyWith({int? id}) => Student(
      id: id ?? this.id,
      startDate: startDate,
      name: name,
      email: email,
      phone: phone,
      birthDate: birthDate,
      cpf: cpf,
      address: address,
      emergencyContact: emergencyContact,
      weight: weight,
      height: height,
      medicalConditions: medicalConditions,
      injuryHistory: injuryHistory,
      surgeries: surgeries,
      medicalRestrictions: medicalRestrictions,
      medications: medications,
      activityLevel: activityLevel,
      plan: plan,
      paymentDetails: paymentDetails,
      schedule: schedule,
      instructorNotes: instructorNotes);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'cpf': cpf,
      'address': address,
      'emergencyContact': emergencyContact,
      'weight': weight,
      'height': height,
      'medicalConditions': medicalConditions,
      'injuryHistory': injuryHistory,
      'surgeries': surgeries,
      'medicalRestrictions': medicalRestrictions,
      'medications': medications,
      'activityLevel': activityLevel,
      'plan': plan,
      'paymentDetails': paymentDetails,
      'schedule': schedule,
      'instructorNotes': instructorNotes,
    };
  }

  static Student fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      startDate: DateTime.parse(map['startDate'] as String),
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      birthDate: map['birthDate'] as String?,
      cpf: map['cpf'] as String?,
      address: map['address'] as String?,
      emergencyContact: map['emergencyContact'] as String?,
      weight: map['weight'] as String?,
      height: map['height'] as String?,
      medicalConditions: map['medicalConditions'] as String?,
      injuryHistory: map['injuryHistory'] as String?,
      surgeries: map['surgeries'] as String?,
      medicalRestrictions: map['medicalRestrictions'] as String?,
      medications: map['medications'] as String?,
      activityLevel: map['activityLevel'] as String?,
      plan: map['plan'] as String?,
      paymentDetails: map['paymentDetails'] as String?,
      schedule: map['schedule'] as String?,
      instructorNotes: map['instructorNotes'] as String?,
    );
  }
}
