import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipssi2023montevrain/controller/background_controller.dart';
import 'package:ipssi2023montevrain/globale.dart';
import 'package:ipssi2023montevrain/model/Message.dart';
import 'package:ipssi2023montevrain/model/utilisateur.dart';

class Messagerie extends StatefulWidget {
  const Messagerie({Key? key}) : super(key: key);

  @override
  State<Messagerie> createState() => _MessagerieState();
}

class _MessagerieState extends State<Messagerie> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      _updateMessages();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    messages = await Message.getAllMessages();
    setState(() {});
  }

  Future<void> _updateMessages() async {
    messages = await Message.getNewMessages(messages);
    setState(() {});
  }

  Future<void> _addMessage(String userUid, String userPseudo, String messageContent) async {
    Message message = Message();
    message.userUid = userUid;
    message.userPseudo = userPseudo;
    message.message = messageContent;
    setState(() {
      messages.insert(0, message); // Insert the message at the start of the list
    });
    await message.addMessageToDatabase();
    _updateMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MyBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Messagerie'),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Message message = messages[messages.length - index - 1];
                    bool isCurrentUser = message.userUid == moi.uid;
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.userPseudo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              message.message,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),  // Set border radius here
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Write a message',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          _addMessage(moi.uid, moi.nickName, _messageController.text);
                          _messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
