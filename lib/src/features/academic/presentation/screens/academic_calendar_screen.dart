import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/academic_provider.dart';
import '../../domain/models/academic_event_model.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicProvider>();
    final events = provider.getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CALENDARIO',
          style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar<AcademicEventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: (day) => provider.getEventsForDay(day),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Dismissible(
                  key: Key(event.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    provider.deleteEvent(event.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: _buildEventTypeIcon(event.type),
                      title: Text(
                        event.title,
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${event.type} • ${DateFormat('HH:mm').format(event.date)}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventTypeIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'Examen':
        icon = Icons.assignment_late;
        color = Colors.red;
        break;
      case 'Entrega':
        icon = Icons.upload_file;
        color = Colors.orange;
        break;
      case 'Estudio':
        icon = Icons.menu_book;
        color = Colors.blue;
        break;
      default:
        icon = Icons.event;
        color = Colors.grey;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedType = 'Examen';
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? selectedSubjectId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final subjects = context.read<AcademicProvider>().subjects;

          return AlertDialog(
            title: Text(
              'Nuevo Evento',
              style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo'),
                    items: const [
                      DropdownMenuItem(value: 'Examen', child: Text('Examen')),
                      DropdownMenuItem(
                        value: 'Entrega',
                        child: Text('Entrega'),
                      ),
                      DropdownMenuItem(
                        value: 'Estudio',
                        child: Text('Estudio'),
                      ),
                      DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                    ],
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    decoration: const InputDecoration(
                      labelText: 'Ramo (Opcional)',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Ninguno'),
                      ),
                      ...subjects.map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedSubjectId = value),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Fecha'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hora'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty) return;

                  final finalDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  context.read<AcademicProvider>().addEvent(
                    titleController.text,
                    finalDateTime,
                    selectedType,
                    subjectId: selectedSubjectId,
                  );
                  Navigator.pop(context);
                },
                child: const Text('GUARDAR'),
              ),
            ],
          );
        },
      ),
    );
  }
}
