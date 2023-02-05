import 'package:flutter/material.dart';
import 'package:scholar_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../widgets/chat_buble.dart';

class ChatPage extends StatelessWidget {
  static String id = 'ChatPage';
  final _controller = ScrollController();
  CollectionReference messages =
      FirebaseFirestore.instance.collection(kMessagesCollections);
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var email = ModalRoute.of(context)!.settings.arguments;
    return StreamBuilder<QuerySnapshot>(
      stream: messages.orderBy(kCreatedAt, descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Message> messagesList = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            messagesList.add(
              Message.fromJson(
                snapshot.data!.docs[i],
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: kPrimaryColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    kLogo,
                    height: 50,
                  ),
                  const Text('Chat'),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      reverse: true,
                      controller: _controller,
                      itemCount: messagesList.length,
                      itemBuilder: (context, index) {
                        return messagesList[index].id == email
                            ? ChatBuble(
                                message: messagesList[index],
                              )
                            : ChatBubleForFriend(
                                message: messagesList[index],
                              );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: controller,
                    onSubmitted: (data) {
                      messages.add({
                        kMessage: data,
                        kCreatedAt: DateTime.now(),
                        kId: email
                      });
                      controller.clear();
                      _controller.animateTo(0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn);
                    },
                    decoration: InputDecoration(
                      hintText: 'Send Message',
                      suffixIcon: const Icon(
                        Icons.send,
                        color: kPrimaryColor,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: kPrimaryColor)),
                    ),
                  ),
                )
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: Text(
                'Loading........',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
