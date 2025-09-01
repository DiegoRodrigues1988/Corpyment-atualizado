// lib/helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/class_event_model.dart';
import '../models/student_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pilates_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // ATUALIZE A VERSÃO PARA 5
    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await _createStudentsTable(db);
    await _createClassEventsTable(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("DROP TABLE IF EXISTS students");
      await _createStudentsTable(db);
    }
    if (oldVersion < 3) {
      await _createClassEventsTable(db);
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE students ADD COLUMN workoutStep INTEGER NOT NULL DEFAULT 1');
    }
    // --- NOVA LÓGICA DE MIGRAÇÃO ---
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE class_events ADD COLUMN instructorId INTEGER NOT NULL DEFAULT 1');
    }
  }

  Future<void> _createStudentsTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeOptional = 'TEXT';
    const dateType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL DEFAULT 1';

    await db.execute('''
      CREATE TABLE students ( 
        id $idType, startDate $dateType, name $textType, email $textType, phone $textType,
        birthDate $textTypeOptional, cpf $textTypeOptional, address $textTypeOptional,
        emergencyContact $textTypeOptional, weight $textTypeOptional, height $textTypeOptional,
        medicalConditions $textTypeOptional, injuryHistory $textTypeOptional, surgeries $textTypeOptional,
        medicalRestrictions $textTypeOptional, medications $textTypeOptional, activityLevel $textTypeOptional,
        plan $textTypeOptional, paymentDetails $textTypeOptional, schedule $textTypeOptional,
        instructorNotes $textTypeOptional,
        workoutStep $intType
      )
    ''');
  }

  Future<void> _createClassEventsTable(Database db) async {
    await db.execute('''
      CREATE TABLE class_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, time TEXT NOT NULL,
        studentIds TEXT NOT NULL, studentNames TEXT NOT NULL,
        instructorId INTEGER NOT NULL DEFAULT 1 
      )
    ''');
  }

  // --- MÉTODOS PARA ALUNOS ---
  Future<Student> create(Student student) async {
    final db = await instance.database;
    final id = await db.insert('students', student.toMap());
    return student.copyWith(id: id);
  }

  Future<List<Student>> readAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students', orderBy: 'name ASC');
    return result.map((json) => Student.fromMap(json)).toList();
  }

  Future<Student> readOneStudent(int id) async {
    final db = await instance.database;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Student.fromMap(maps.first);
    throw Exception('ID $id não encontrado');
  }

  Future<int> update(Student student) async {
    final db = await instance.database;
    return db.update('students', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // --- MÉTODOS PARA AULAS ---
  Future<ClassEvent> createClassEvent(ClassEvent event) async {
    final db = await instance.database;
    final id = await db.insert('class_events', event.toMap());
    return event.copyWith(id: id);
  }

  Future<List<ClassEvent>> readEventsForDate(DateTime date) async {
    final db = await instance.database;
    final dateString = date.toIso8601String().substring(0, 10);
    final result = await db.query('class_events', where: 'date = ?', whereArgs: [dateString]);
    return result.map((json) => ClassEvent.fromMap(json)).toList();
  }

  Future<List<ClassEvent>> readAllEvents() async {
    final db = await instance.database;
    final result = await db.query('class_events');
    return result.map((json) => ClassEvent.fromMap(json)).toList();
  }

  Future<int> deleteClassEvent(int id) async {
    final db = await instance.database;
    return await db.delete('class_events', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}