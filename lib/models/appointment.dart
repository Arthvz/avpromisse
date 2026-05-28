// lib/models/appointment.dart
// Modelo de dados de um compromisso

class Appointment {
  final String? id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String userId;
  final String category;

  Appointment({
    this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.userId,
    this.category = 'Outro',
  });

  // Converte o objeto para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'userId': userId,
      'category': category,
    };
  }

  // Cria um Appointment a partir de um Map (dados vindos do Firestore)
  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      userId: map['userId'] ?? '',
      category: map['category'] ?? 'Outro',
    );
  }

  // Cria uma cópia do compromisso com campos alterados (útil na edição)
  Appointment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? userId,
    String? category,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      userId: userId ?? this.userId,
      category: category ?? this.category,
    );
  }
}
