import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  // Attributes
  late String uid; // Unique id for the message
  late String userUid; // uid of the user who sent the message
  late String userPseudo;
  late String message; // Message content
  late DateTime dateTime; // Date and time when the message was sent

  // Constructors
  Message(){
    uid = "";
    userUid = "";
    message = "";
  }

  // Constructor to create instance from DocumentSnapshot
  Message.fromDatabase(DocumentSnapshot documentSnapshot){
    uid = documentSnapshot.id;
    Map<String,dynamic> map = documentSnapshot.data() as Map<String,dynamic>;
    userUid = map["userUid"];
    userPseudo = map["userPseudo"];
    message = map["message"];
    Timestamp? timestamp = map["dateTime"];
    if(timestamp != null){
      dateTime = timestamp.toDate();
    }
  }


  // Method to convert the object to map, useful for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'message': message,
      'dateTime': dateTime,
    };
  }


  static Stream<List<Message>> getAllMessagesStream() {
    return FirebaseFirestore.instance
        .collection('MESSAGES')
        .orderBy('dateTime')
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Message.fromDatabase(doc);
      }).toList() as List<Message>;
    });
  }


  Future<void> addMessageToDatabase() async {
    await FirebaseFirestore.instance.collection('MESSAGES').add(
      {
        'userUid': this.userUid,
        'userPseudo': this.userPseudo,
        'message': this.message,
        'dateTime': FieldValue.serverTimestamp(),
      },
    );
  }


  static Future<List<Message>> getNewMessages(List<Message> currentMessages) async {
    DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(0); // default value

    if(currentMessages.isNotEmpty){
      lastUpdate = currentMessages
          .map((message) => message.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0))
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('MESSAGES')
        .where('dateTime', isGreaterThan: lastUpdate)
        .orderBy('dateTime')
        .get();

    List<Message> newMessages = querySnapshot.docs
        .map((doc) => Message.fromDatabase(doc))
        .toList();

    currentMessages.addAll(newMessages);

    return currentMessages;
  }
}
