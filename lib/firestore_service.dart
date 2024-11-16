import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Method to retrieve a predefined response based on user query
  Future<String?> getPredefinedResponse(String userQuery) async {
    try {
      final snapshot = await _db
          .collection('bot_answers')
          .where('question', isEqualTo: userQuery.toLowerCase())
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['answer'] as String;
      } else {
        return null; // No matching document found
      }
    } catch (e) {
      print("Error fetching predefined response: $e");
      return null;
    }
  }

  // Method to add a chat message to Firestore
  Future<void> addChatMessage(
      String userId, String question, String answer) async {
    try {
      await _db.collection('chat_history').add({
        'user_id': userId,
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding chat message: $e");
    }
  }
}
