// lib/screens/appointment_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/category_utils.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Appointment? appointment;

  const AppointmentFormScreen({super.key, this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _dbService = DatabaseService();
  final _authService = AuthService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Outro';
  bool _isLoading = false;

  bool get _isEditing => widget.appointment != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.appointment!.title;
      _descriptionController.text = widget.appointment!.description;
      _selectedDate = widget.appointment!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.dateTime);
      _selectedCategory = widget.appointment!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final userId = _authService.currentUser!.uid;

    try {
      if (_isEditing) {
        final updated = widget.appointment!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: dateTime,
          category: _selectedCategory,
        );
        await _dbService.updateAppointment(updated);
      } else {
        final newAppointment = Appointment(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: dateTime,
          userId: userId,
          category: _selectedCategory,
        );
        await _dbService.addAppointment(newAppointment);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final timeLabel = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Compromisso' : 'Novo Compromisso'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ex: Reunião com cliente',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título do compromisso';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  hintText: 'Observações, local, etc.',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Categoria
              const Text(
                'Categoria',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoryUtils.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final color = CategoryUtils.colorOf(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: color.withAlpha(60),
                    side: BorderSide(
                      color: isSelected ? color : Colors.grey.shade300,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? color : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    avatar: isSelected
                        ? Icon(Icons.check, size: 16, color: color)
                        : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Data e Hora
              const Text(
                'Data e Hora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dateLabel),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(timeLabel),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botão salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSave,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isEditing ? 'Salvar Alterações' : 'Adicionar Compromisso',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
