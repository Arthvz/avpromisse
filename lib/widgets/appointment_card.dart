// lib/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/category_utils.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd/MM/yyyy').format(appointment.dateTime);
    final formattedTime = DateFormat('HH:mm').format(appointment.dateTime);
    final isPast = appointment.dateTime.isBefore(DateTime.now());
    final categoryColor = CategoryUtils.colorOf(appointment.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isPast ? Colors.grey.shade300 : Colors.indigo.shade100,
          child: Icon(
            Icons.event,
            color: isPast ? Colors.grey : Colors.indigo,
          ),
        ),
        title: Text(
          appointment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isPast ? TextDecoration.lineThrough : null,
            color: isPast ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: Colors.indigo),
                const SizedBox(width: 4),
                Text('$formattedDate às $formattedTime',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                // Badge de categoria
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: categoryColor.withAlpha(100), width: 1),
                  ),
                  child: Text(
                    appointment.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: categoryColor.withAlpha(220),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                appointment.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
