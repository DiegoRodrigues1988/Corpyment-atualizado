// lib/screens/student_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Agora passamos o 'context' para a função auxiliar.
                _buildDetailRow(
                  context: context, // Passando o contexto
                  icon: Icons.person_outline,
                  title: 'Nome Completo',
                  subtitle: student.name,
                ),
                const Divider(),
                _buildDetailRow(
                  context: context, // Passando o contexto
                  icon: Icons.email_outlined,
                  title: 'E-mail',
                  subtitle: student.email,
                ),
                const Divider(),
                _buildDetailRow(
                  context: context, // Passando o contexto
                  icon: Icons.phone_outlined,
                  title: 'Telefone',
                  subtitle: student.phone,
                ),
                const Divider(),
                _buildDetailRow(
                  context: context, // Passando o contexto
                  icon: Icons.calendar_today_outlined,
                  title: 'Data de Cadastro',
                  subtitle: DateFormat('dd/MM/yyyy \'às\' HH:mm')
                      .format(student.startDate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A função agora recebe o BuildContext como parâmetro.
  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      // ERRO E AVISO CORRIGIDOS AQUI:
      // 1. Agora temos acesso ao 'context'.
      // 2. Usamos .withAlpha() em vez de .withOpacity().
      leading: Icon(icon,
          color: Theme.of(context).primaryColor.withAlpha(179)), // Opacidade de 70%
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}
