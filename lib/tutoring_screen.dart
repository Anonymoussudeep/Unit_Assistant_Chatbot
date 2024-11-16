import 'package:flutter/material.dart';

class TutoringScreen extends StatefulWidget {
  const TutoringScreen({super.key});

  @override
  _TutoringScreenState createState() => _TutoringScreenState();
}

class _TutoringScreenState extends State<TutoringScreen> {
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<Map<String, String>> _requests = [];

  void _postRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.blueAccent),
            const SizedBox(width: 8),
            const Text('Request Tutoring'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit Code or Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (e.g., specific topics)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _addTutoringRequest,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Post Request'),
          ),
        ],
      ),
    );
  }

  void _addTutoringRequest() {
    if (_unitController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      setState(() {
        _requests.add({
          'unit': _unitController.text,
          'description': _descriptionController.text,
          'status': 'Looking for Tutor',
        });
      });
      _unitController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }
  }

  void _offerHelp(int index) {
    setState(() {
      _requests[index]['status'] = 'Matched with a Tutor';
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutoringChatScreen(request: _requests[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Tutoring Requests'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _postRequestDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Request Tutoring'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _requests.isEmpty
                  ? Center(
                      child: Text(
                        'No tutoring requests yet.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  request['status'] == 'Looking for Tutor'
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent,
                              child: Icon(
                                request['status'] == 'Looking for Tutor'
                                    ? Icons.person_search
                                    : Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              request['unit']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text(request['description']!),
                                const SizedBox(height: 5),
                                Text(
                                  'Status: ${request['status']}',
                                  style: TextStyle(
                                    color:
                                        request['status'] == 'Looking for Tutor'
                                            ? Colors.orangeAccent
                                            : Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: request['status'] == 'Looking for Tutor'
                                ? ElevatedButton(
                                    onPressed: () => _offerHelp(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Offer Help'),
                                  )
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutoringChatScreen extends StatefulWidget {
  final Map<String, String> request;

  const TutoringChatScreen({Key? key, required this.request}) : super(key: key);

  @override
  _TutoringChatScreenState createState() => _TutoringChatScreenState();
}

class _TutoringChatScreenState extends State<TutoringChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _chatMessages.add({
          'sender': 'You',
          'message': _messageController.text,
        });
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - ${widget.request['unit']}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return Align(
                  alignment: message['sender'] == 'You'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'You'
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: message['sender'] == 'You'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
