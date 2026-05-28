// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/category_utils.dart';
import '../widgets/appointment_card.dart';
import 'appointment_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String? _filterCategory; // null = Todos

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtra e agrupa os compromissos ──────────────────────────────────────

  List<Appointment> _applyFilters(List<Appointment> all) {
    return all.where((a) {
      final matchCategory =
          _filterCategory == null || a.category == _filterCategory;
      final matchSearch = _searchQuery.isEmpty ||
          a.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  /// Agrupa por dia (sem horário). Retorna mapa ordenado por data.
  Map<DateTime, List<Appointment>> _groupByDay(List<Appointment> list) {
    final map = <DateTime, List<Appointment>>{};
    for (final a in list) {
      final key =
          DateTime(a.dateTime.year, a.dateTime.month, a.dateTime.day);
      map.putIfAbsent(key, () => []).add(a);
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (day == today) return 'Hoje';
    if (day == tomorrow) return 'Amanhã';
    return DateFormat('dd/MM/yyyy').format(day);
  }

  // ── Bottom sheet de filtro ────────────────────────────────────────────────

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (ctx, scrollCtrl) {
                return SingleChildScrollView(
                  controller: scrollCtrl,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Filtrar por categoria',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<String?>(
                          value: null,
                          groupValue: _filterCategory,
                          title: const Text('Todos'),
                          onChanged: (v) {
                            setSheetState(() {});
                            setState(() => _filterCategory = v);
                          },
                        ),
                        ...CategoryUtils.categories.map((cat) {
                          final color = CategoryUtils.colorOf(cat);
                          return RadioListTile<String?>(
                            value: cat,
                            groupValue: _filterCategory,
                            title: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cat),
                              ],
                            ),
                            onChanged: (v) {
                              setSheetState(() {});
                              setState(() => _filterCategory = v);
                            },
                          );
                        }),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Fechar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── Diálogo de confirmação de exclusão ────────────────────────────────────

  Future<void> _confirmDelete(
      BuildContext context, Appointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Compromisso'),
        content: Text(
            'Tem certeza que deseja excluir "${appointment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _dbService.deleteAppointment(appointment.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compromisso excluído.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser!;
    final isFiltering = _filterCategory != null || _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Minha Agenda'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Ícone de filtro (destaca quando ativo)
          IconButton(
            icon: Badge(
              isLabelVisible: _filterCategory != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filtrar por categoria',
            onPressed: _showFilterSheet,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                user.email ?? '',
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja encerrar a sessão?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sair',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) await _authService.logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de busca ──────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar compromisso...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // ── Lista com agrupamento por data ──────────────────────────────
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: _dbService.getAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                final filtered = _applyFilters(snapshot.data ?? []);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isFiltering
                              ? Icons.search_off
                              : Icons.event_busy,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isFiltering
                              ? 'Nenhum resultado encontrado.'
                              : 'Nenhum compromisso ainda.',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.grey),
                        ),
                        if (!isFiltering) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Toque no + para adicionar.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final grouped = _groupByDay(filtered);

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: grouped.length,
                  itemBuilder: (context, sectionIndex) {
                    final day = grouped.keys.elementAt(sectionIndex);
                    final items = grouped[day]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de data
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                          child: Text(
                            _dayLabel(day),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Cards do dia
                        ...items.map(
                          (a) => AppointmentCard(
                            appointment: a,
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AppointmentFormScreen(appointment: a),
                              ),
                            ),
                            onDelete: () =>
                                _confirmDelete(context, a),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AppointmentFormScreen(),
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}
