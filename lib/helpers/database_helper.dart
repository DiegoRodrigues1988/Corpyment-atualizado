// lib/helpers/database_helper.dart

import 'package:sqflite/sqflite.dart'; // <-- O ERRO ESTAVA AQUI
import 'package:path/path.dart';
import '../models/student_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeOptional = 'TEXT';
    const dateType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE students ( 
        id $idType, 
        startDate $dateType,
        name $textType,
        email $textType,
        phone $textType,
        birthDate $textTypeOptional,
        cpf $textTypeOptional,
        address $textTypeOptional,
        emergencyContact $textTypeOptional,
        weight $textTypeOptional,
        height $textTypeOptional,
        medicalConditions $textTypeOptional,
        injuryHistory $textTypeOptional,
        surgeries $textTypeOptional,
        medicalRestrictions $textTypeOptional,
        medications $textTypeOptional,
        activityLevel $textTypeOptional,
        plan $textTypeOptional,
        paymentDetails $textTypeOptional,
        schedule $textTypeOptional,
        instructorNotes $textTypeOptional
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("DROP TABLE IF EXISTS students");
      await _createDB(db, newVersion);
    }
  }

  Future<Student> create(Student student) async {
    final db = await instance.database;
    final id = await db.insert('students', student.toMap());
    return student.copyWith(id: id);
  }

  Future<List<Student>> readAllStudents() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('students', orderBy: orderBy);
    return result.map((json) => Student.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
