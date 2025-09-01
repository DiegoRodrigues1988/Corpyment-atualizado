// lib/screens/student_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers/database_helper.dart';
import '../models/student_model.dart';
import 'edit_student_details_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student _student;

  final List<String> _workoutSteps = const [
    'Cadillac', 'Barrel', 'Chair', 'Reformer', 'Mat', 'Acessórios'
  ];

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  Future<void> _updateWorkoutStep(int step) async {
    final nextStep = (step == _workoutSteps.length) ? 1 : step + 1;
    final updatedStudent = _student.copyWith(workoutStep: nextStep);
    await DatabaseHelper.instance.update(updatedStudent);

    setState(() {
      _student = updatedStudent;
    });
  }

  Future<void> _navigateToEditScreen() async {
    if (!mounted) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditStudentDetailsScreen(student: _student),
      ),
    );

    if (result == true && mounted) {
      final updatedStudent =
      await DatabaseHelper.instance.readOneStudent(_student.id!);
      setState(() {
        _student = updatedStudent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Editar Ficha',
            onPressed: _navigateToEditScreen,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWorkoutTracker(context),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: 'Dados Pessoais e de Contato',
            icon: Icons.person_outline,
            details: {
              'Nome Completo': _student.name, 'E-mail': _student.email, 'Telefone': _student.phone,
              'Data de Nascimento': _student.birthDate, 'CPF/RG': _student.cpf, 'Endereço': _student.address,
              'Contato de Emergência': _student.emergencyContact,
            },
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: 'Dados de Saúde e Histórico',
            icon: Icons.monitor_heart_outlined,
            details: {
              'Peso': _student.weight, 'Altura': _student.height, 'Condições Médicas': _student.medicalConditions,
              'Histórico de Lesões': _student.injuryHistory, 'Cirurgias': _student.surgeries, 'Restrições Médicas': _student.medicalRestrictions,
              'Medicamentos': _student.medications, 'Nível de Atividade': _student.activityLevel,
            },
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: 'Controle Administrativo',
            icon: Icons.business_center_outlined,
            details: {
              'Data de Matrícula': DateFormat('dd/MM/yyyy \'às\' HH:mm').format(_student.startDate),
              'Plano': _student.plan, 'Pagamento': _student.paymentDetails, 'Horários / Turmas': _student.schedule,
              'Observações do Instrutor': _student.instructorNotes,
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTracker(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.checklist, color: Theme.of(context).primaryColor),
              title: const Text('Progresso do Treino',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _workoutSteps.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String name = entry.value;
                  final int currentStepNumber = index + 1;

                  final bool isDone = currentStepNumber < _student.workoutStep;
                  final bool isNext = currentStepNumber == _student.workoutStep;

                  Color chipColor;
                  Color textColor;

                  if (isDone) {
                    chipColor = Colors.orange.shade300;
                    textColor = Colors.white;
                  } else if (isNext) {
                    chipColor = Colors.green.shade400;
                    textColor = Colors.white;
                  } else {
                    chipColor = Colors.grey.shade300;
                    textColor = Colors.black87;
                  }

                  return GestureDetector(
                    onTap: () {
                      _updateWorkoutStep(currentStepNumber);
                    },
                    child: Chip(
                      backgroundColor: chipColor,
                      label: Text(
                        '${currentStepNumber}. $name',
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                      ),
                      avatar:
                      isDone ? Icon(Icons.check, color: textColor, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Map<String, String?> details}) {
    final validDetails = Map.fromEntries(details.entries.where((entry) => entry.value != null && entry.value!.trim().isNotEmpty));
    if (validDetails.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: Theme.of(context).primaryColor),
              title: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const Divider(),
            ...validDetails.entries.map((entry) {
              return _buildDetailRow(context,
                  title: entry.key, subtitle: entry.value!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, {required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.black87))),
        ],
      ),
    );
  }
}