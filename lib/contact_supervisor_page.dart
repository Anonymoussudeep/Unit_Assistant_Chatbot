import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupervisorPage extends StatelessWidget {
  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.email, color: Colors.indigo),
              title: Text('Email'),
              onTap: () async {
                final emailUrl = 'mailto:sardar.farhad@vu.edu.au';
                if (await canLaunch(emailUrl)) {
                  await launch(emailUrl);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: Colors.blue),
              title: Text('LinkedIn'),
              onTap: () async {
                final linkedInUrl =
                    'https://www.linkedin.com/in/sardar-farhad'; // Replace with actual LinkedIn URL
                if (await canLaunch(linkedInUrl)) {
                  await launch(linkedInUrl);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Phone'),
              onTap: () async {
                final phoneUrl =
                    'tel:+123456789'; // Replace with actual phone number
                if (await canLaunch(phoneUrl)) {
                  await launch(phoneUrl);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showScheduleMeetingForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScheduleMeetingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Supervisor"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.indigo.shade100,
                    child: Icon(
                      Icons.person,
                      color: Colors.indigo,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Dr.Sardar Farhad',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Supervisor",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Divider(
                    height: 30,
                    thickness: 1,
                    color: Colors.grey[300],
                    indent: 30,
                    endIndent: 30,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showContactOptions(context),
                    icon: Icon(Icons.contact_mail),
                    label: Text("Contact Options"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showScheduleMeetingForm(context),
                    icon: Icon(Icons.schedule),
                    label: Text("Schedule Meeting"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScheduleMeetingPage extends StatefulWidget {
  @override
  _ScheduleMeetingPageState createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedMeetingType;
  final TextEditingController meetingLinkController = TextEditingController();

  final List<String> meetingTypes = ['Zoom', 'Google Meet', 'Microsoft Teams'];

  void _scheduleMeeting() {
    if (selectedDate != null &&
        selectedTime != null &&
        selectedMeetingType != null &&
        meetingLinkController.text.isNotEmpty) {
      // Code to save or handle the meeting details can go here
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meeting scheduled successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Schedule Meeting'), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Meeting',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.indigo),
              title: Text(selectedDate == null
                  ? 'Select Date'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.indigo),
              title: Text(selectedTime == null
                  ? 'Select Time'
                  : '${selectedTime!.format(context)}'),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => selectedTime = time);
                }
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Meeting Type',
                border: OutlineInputBorder(),
              ),
              value: selectedMeetingType,
              items: meetingTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedMeetingType = value);
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: meetingLinkController,
              decoration: InputDecoration(
                labelText: 'Meeting Link',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleMeeting,
              child: Text('Confirm Meeting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
