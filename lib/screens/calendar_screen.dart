import 'package:flutter/material.dart';
import 'package:pmspbd/firebase/database_sales.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { porCumplir, cancelado, completado }

class Event {
  final String title;
  final DateTime date;
  final EventStatus status;

  Event({required this.title, required this.date, required this.status});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Event>> _events = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  final DatabaseSales _databaseSales = DatabaseSales();

  @override
  void initState() {
    super.initState();
    _loadEventsFromDatabase();
  }

  Future<void> _loadEventsFromDatabase() async {
    _databaseSales.getsales().listen((snapshot) {
      setState(() {
        _events = {};
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final statusString = data['status'] as String;
          final status = _getEventStatusFromString(statusString);

          final event = Event(
            title: data['title'],
            date: date,
            status: status,
          );

          if (_events[date] == null) {
            _events[date] = [];
          }
          _events[date]!.add(event);
        }
      });
    });
  }

  EventStatus _getEventStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'por cumplir':
        return EventStatus.porCumplir;
      case 'cancelado':
        return EventStatus.cancelado;
      case 'completado':
        return EventStatus.completado;
      default:
        return EventStatus.porCumplir;
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.porCumplir:
        return Colors.green;
      case EventStatus.cancelado:
        return Colors.red;
      case EventStatus.completado:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _showEventDetails(context, selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events.map((event) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _getStatusColor((event as Event).status),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, DateTime selectedDate) {
    List<Event> events = _getEventsForDay(selectedDate);
    showDialog(
      context: context,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Eventos del ${selectedDate.toLocal().toIso8601String().split("T").first}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (events.isEmpty)
                  Text("No hay eventos para este día."),
                for (var event in events)
                  ListTile(
                    leading: Icon(Icons.circle, color: _getStatusColor(event.status)),
                    title: Text(event.title),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
