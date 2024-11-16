import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _assignments =
      {}; // Stores assignments with time
  FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    _localNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _scheduleNotification(
      String assignment, DateTime dateTime) async {
    final androidDetails = AndroidNotificationDetails(
      'assignment_channel',
      'Assignment Deadlines',
      channelDescription: 'Notifications for assignment deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.schedule(
      dateTime.hashCode,
      'Assignment Due',
      assignment,
      dateTime,
      notificationDetails,
    );
  }

  Future<void> _cancelNotification(int notificationId) async {
    await _localNotificationsPlugin.cancel(notificationId);
  }

  void _addAssignmentDialog(
      {Map<String, dynamic>? assignmentToEdit, int? index}) {
    final TextEditingController _assignmentController = TextEditingController(
      text: assignmentToEdit?['title'] ?? '',
    );
    DateTime selectedDateTime =
        assignmentToEdit?['time'] ?? (_selectedDay ?? DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            assignmentToEdit == null ? 'Add Assignment' : 'Edit Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _assignmentController,
              decoration: const InputDecoration(hintText: 'Assignment Title'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Set Time:"),
                ElevatedButton(
                  onPressed: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  },
                  child: Text(
                      "${TimeOfDay.fromDateTime(selectedDateTime).format(context)}"),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final assignmentText = _assignmentController.text;
              if (assignmentText.isNotEmpty) {
                setState(() {
                  if (!_assignments.containsKey(_selectedDay)) {
                    _assignments[_selectedDay!] = [];
                  }

                  if (assignmentToEdit == null) {
                    // Add new assignment
                    _assignments[_selectedDay]!.add({
                      'title': assignmentText,
                      'time': selectedDateTime,
                    });
                    _scheduleNotification(assignmentText, selectedDateTime);
                  } else {
                    // Update existing assignment
                    final originalNotificationId =
                        assignmentToEdit['time'].hashCode;
                    _cancelNotification(originalNotificationId);
                    _assignments[_selectedDay]![index!] = {
                      'title': assignmentText,
                      'time': selectedDateTime,
                    };
                    _scheduleNotification(assignmentText, selectedDateTime);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(assignmentToEdit == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteAssignment(DateTime day, int index) {
    setState(() {
      final notificationId = _assignments[day]![index]['time'].hashCode;
      _cancelNotification(notificationId);
      _assignments[day]!.removeAt(index);
      if (_assignments[day]!.isEmpty) {
        _assignments.remove(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Deadlines'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _addAssignmentDialog(); // Prompt to add an assignment with time
              },
              eventLoader: (day) =>
                  _assignments[day]?.map((e) => e['title']).toList() ?? [],
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (_selectedDay != null &&
                      _assignments[_selectedDay] != null &&
                      _assignments[_selectedDay]!.isNotEmpty)
                    ..._assignments[_selectedDay]!.asMap().entries.map((entry) {
                      final index = entry.key + 1; // Starting numbering from 1
                      final assignment = entry.value;
                      final time = assignment['time'] as DateTime;
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              index.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.deepPurple,
                          ),
                          title: Text(
                            assignment['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "Due at ${TimeOfDay.fromDateTime(time).format(context)}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _addAssignmentDialog(
                                    assignmentToEdit: assignment,
                                    index: entry.key),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteAssignment(_selectedDay!, entry.key),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  else
                    Center(
                      child: Text(
                        "No assignments for the selected day.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
