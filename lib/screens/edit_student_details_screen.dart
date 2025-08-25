// lib/screens/edit_student_details_screen.dart

import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/student_model.dart';

class EditStudentDetailsScreen extends StatefulWidget {
  final Student student;
  const EditStudentDetailsScreen({super.key, required this.student});

  @override
  State<EditStudentDetailsScreen> createState() =>
      _EditStudentDetailsScreenState();
}

class _EditStudentDetailsScreenState extends State<EditStudentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _controllers = {
      'name': TextEditingController(text: s.name), 'email': TextEditingController(text: s.email), 'phone': TextEditingController(text: s.phone),
      'birthDate': TextEditingController(text: s.birthDate), 'cpf': TextEditingController(text: s.cpf), 'address': TextEditingController(text: s.address),
      'emergencyContact': TextEditingController(text: s.emergencyContact), 'weight': TextEditingController(text: s.weight), 'height': TextEditingController(text: s.height),
      'medicalConditions': TextEditingController(text: s.medicalConditions), 'injuryHistory': TextEditingController(text: s.injuryHistory), 'surgeries': TextEditingController(text: s.surgeries),
      'medicalRestrictions': TextEditingController(text: s.medicalRestrictions), 'medications': TextEditingController(text: s.medications), 'activityLevel': TextEditingController(text: s.activityLevel),
      'plan': TextEditingController(text: s.plan), 'paymentDetails': TextEditingController(text: s.paymentDetails), 'schedule': TextEditingController(text: s.schedule),
      'instructorNotes': TextEditingController(text: s.instructorNotes),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final updatedStudent = Student(
        id: widget.student.id,
        startDate: widget.student.startDate,
        name: _controllers['name']!.text, email: _controllers['email']!.text, phone: _controllers['phone']!.text,
        birthDate: _controllers['birthDate']!.text, cpf: _controllers['cpf']!.text, address: _controllers['address']!.text,
        emergencyContact: _controllers['emergencyContact']!.text, weight: _controllers['weight']!.text, height: _controllers['height']!.text,
        medicalConditions: _controllers['medicalConditions']!.text, injuryHistory: _controllers['injuryHistory']!.text, surgeries: _controllers['surgeries']!.text,
        medicalRestrictions: _controllers['medicalRestrictions']!.text, medications: _controllers['medications']!.text, activityLevel: _controllers['activityLevel']!.text,
        plan: _controllers['plan']!.text, paymentDetails: _controllers['paymentDetails']!.text, schedule: _controllers['schedule']!.text,
        instructorNotes: _controllers['instructorNotes']!.text,
      );

      await DatabaseHelper.instance.update(updatedStudent);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ficha atualizada com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Retorna 'true' para indicar que houve atualização
      }
    }
  }

  Widget _buildTextField(String key, String label, {TextInputType keyboardType = TextInputType.text, bool isRequired = false, int maxLines = 1}) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: isRequired ? (value) {
        if (value == null || value.trim().isEmpty) return 'Este campo é obrigatório.';
        if (key == 'email' && !value.contains('@')) return 'Por favor, insira um e-mail válido.';
        return null;
      } : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Ficha de ${widget.student.name}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ExpansionTile(
              title: const Text('1. Dados Pessoais e de Contato', style: TextStyle(fontWeight: FontWeight.bold)),
              initiallyExpanded: true,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTextField('name', 'Nome Completo', isRequired: true),
                _buildTextField('email', 'E-mail', keyboardType: TextInputType.emailAddress, isRequired: true),
                _buildTextField('phone', 'Telefone / WhatsApp', keyboardType: TextInputType.phone, isRequired: true),
                _buildTextField('birthDate', 'Data de Nascimento'),
                _buildTextField('cpf', 'CPF ou RG'),
                _buildTextField('address', 'Endereço'),
                _buildTextField('emergencyContact', 'Contato de Emergência'),
              ],
            ),
            ExpansionTile(
              title: const Text('2. Dados de Saúde e Histórico', style: TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTextField('weight', 'Peso'), _buildTextField('height', 'Altura'),
                _buildTextField('medicalConditions', 'Condições Médicas', maxLines: 3),
                _buildTextField('injuryHistory', 'Histórico de Lesões', maxLines: 3),
                _buildTextField('surgeries', 'Cirurgias Anteriores', maxLines: 3),
                _buildTextField('medicalRestrictions', 'Restrição Médica', maxLines: 3),
                _buildTextField('medications', 'Medicamentos Contínuos', maxLines: 3),
                _buildTextField('activityLevel', 'Nível de Atividade Física'),
              ],
            ),
            ExpansionTile(
              title: const Text('3. Controle Administrativo', style: TextStyle(fontWeight: FontWeight.bold)),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTextField('plan', 'Plano Escolhido'),
                _buildTextField('paymentDetails', 'Valor / Forma de Pagamento'),
                _buildTextField('schedule', 'Horários / Turmas'),
                _buildTextField('instructorNotes', 'Observações do Instrutor', keyboardType: TextInputType.multiline, maxLines: 5),
              ],
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Salvar Alterações'),
              ),
          ],
        ),
      ),
    );
  }
}
