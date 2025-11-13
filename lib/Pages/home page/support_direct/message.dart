import 'package:chop_chop_africa/utility/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utility/simple_message.dart';



class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isKeyboardVisible = false;


  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user's message
    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _controller.clear();
    });

    // Fake delay and response
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.add(Message(text: _generateFakeResponse(), isUser: false));
      });
    });
  }

  String _generateFakeResponse() {
    // This could be random gibberish, fixed responses, or even a Markov chain
    final responses = [
      "Hmm... interesting!",
      "Can you tell me more?",
      "Let me check that for you.",
      "Haha, that's funny.",
      "I'm not sure I understand 🤔",
      "One moment please...",
    ];
    responses.shuffle();
    return responses.first;
  }

  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    if(mounted){
      setState(() {
        _isKeyboardVisible = bottomInset > 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Support',
            style:TextStyle(
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.9.pH),
          child: Divider(
            color: Colors.grey,
          ),
        ),
      ),
      body:!_isKeyboardVisible && _messages.isEmpty?
      Center(
        child: Icon(Icons.message,size: 15.pH,),
      ):ListView.builder(
        reverse: true,
        itemCount: _messages.length,
        itemBuilder: (_, index) {
          final msg = _messages[_messages.length - 1 - index];
          return Align(
            alignment: msg.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: msg.isUser ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.text,
                style: TextStyle(color: msg.isUser ? Colors.white : Colors.black),
              ),
            ),
          );
        },
      ),
      persistentFooterButtons: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Type your message..."),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              )
            ],
          ),
        ),
        3.gap
      ],
    );
  }
}
