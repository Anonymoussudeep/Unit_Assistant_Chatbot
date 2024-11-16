import 'package:flutter/material.dart';
import 'login_page.dart'; // Import your LoginPage here
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'calendar_screen.dart'; // Import your CalendarScreen here
import 'tutoring_screen.dart'; // Import your TutoringScreen here
import 'contact_supervisor_page.dart'; // Import ContactSupervisorPage here
import 'firestore_service.dart'; // Import FirestoreService
import 'query_responses.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirestoreService _firestoreService =
      FirestoreService(); // FirestoreService instance

  Future<void> _sendMessage(String userMessage) async {
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
    });

    _controller.clear();

    try {
      // Step 1: Check for a predefined response in `query_responses.dart`
      String predefinedResponse =
          QueryResponses.getResponse(userMessage.trim());

      if (predefinedResponse !=
          "I'm sorry, I don't understand that question.") {
        // Display the predefined response if available
        setState(() {
          _messages.add({'role': 'bot', 'content': predefinedResponse});
        });
        // Save the chat in Firestore
        await _firestoreService.addChatMessage(
            "userId", userMessage, predefinedResponse);
      } else {
        // Step 2: If no predefined response, use ChatGPT API as a fallback
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer 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', // Replace with your secure API key
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {'role': 'user', 'content': userMessage},
            ],
            'max_tokens': 100,
            'temperature': 0.7,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final botMessage =
              responseData['choices'][0]['message']['content'].trim();

          setState(() {
            _messages.add({'role': 'bot', 'content': botMessage});
          });

          // Save the conversation in Firestore
          await _firestoreService.addChatMessage(
              "userId", userMessage, botMessage);
        } else {
          setState(() {
            _messages.add({
              'role': 'bot',
              'content': 'Error: Unable to fetch response from ChatGPT'
            });
          });
        }
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Error: $e'});
      });
    }
  }

  void _deleteMessage(int index) {
    setState(() {
      _messages.removeAt(index);
    });
  }

  void _startNewChat() {
    setState(() {
      _messages.clear(); // Clears the chat history to start a new conversation
    });
  }

  void _showChatHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chat History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  leading: Icon(
                    message['role'] == 'user' ? Icons.person : Icons.smart_toy,
                    color:
                        message['role'] == 'user' ? Colors.blue : Colors.green,
                  ),
                  title: Text(
                    'Chat ${index + 1}: ${message['content']!}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(message['role'] == 'user' ? 'User' : 'Bot'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Delete') {
                        _deleteMessage(index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScreen()),
    );
  }

  void _navigateToTutoringScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TutoringScreen()),
    );
  }

  void _navigateToContactSupervisor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactSupervisorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Unit Assistant Chatbot'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showChatHistory,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _navigateToCalendar,
          ),
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: _navigateToTutoringScreen,
          ),
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: _navigateToContactSupervisor,
            tooltip: 'Contact Supervisor',
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu_open_rounded),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Sudeep'),
              accountEmail: const Text('sudeep@edu.au'),
              currentAccountPicture: CircleAvatar(
                child: const Text(
                  'S',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.primary),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('My Plan'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.extension),
              title: const Text('My BOTs'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Customize ChatBOT'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Get ChatBOT Search Extension'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Message'),
                            content: const Text(
                                'Are you sure you want to delete this message?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteMessage(index);
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Align(
                          alignment: message['role'] == 'user'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: message['role'] == 'user'
                                  ? Colors.deepPurple.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              message['content']!,
                              style: const TextStyle(fontSize: 16),
                            ),
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
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text);
                        }
                      },
                      child: const Icon(Icons.send, color: Colors.white),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
