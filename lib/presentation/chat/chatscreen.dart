import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introchat/model/chat/chat_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/chat/chat_websocket.dart';

final messageStreamProvider = StreamProvider.autoDispose((ref) {
  needScroll = true;
  return ChatWebSocket.getInstance().getMessageStream();
});

bool needScroll = false;

class ChatScreen extends ConsumerStatefulWidget {
  static String id = 'chatscreen';
  const ChatScreen({
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  late TextEditingController _controller;
  late String? username;
  late AnimationController animationController;
  late Animation<Offset> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      reverseDuration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 0.1))
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.ease));
    _controller = TextEditingController();
    getUsername();
  }

  @override
  void dispose() {
    _controller.dispose();
    ChatWebSocket.getInstance().closeWebSocket();
    super.dispose();
  }

  void getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    needScroll = true;
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) async {
      print('need Scroll $needScroll');
      if (scrollController.hasClients && needScroll) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        await Future.delayed(const Duration(seconds: 1));
        needScroll = false;
      }
    });

    final messageList = ref.watch(messageStreamProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VerticalDivider(
              color: Colors.black12,
              thickness: 1,
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: const Text(
                        'Introchat',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 21),
                      ),
                    ),
                    const Divider(
                      color: Colors.black12,
                      thickness: 1,
                    ),
                    const Flexible(
                      child: Text(
                          '"Silence speaks volumes, and so do our chats. Our chat app is designed for introverts in the workplace who want to communicate comfortably and confidently, without the pressure of face-to-face interactions. Join us in embracing the power of quiet conversation."',
                          style: TextStyle(
                            wordSpacing: 2,
                            height: 2,
                          )),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Flexible(
                        child: SlideTransition(
                            position: animation,
                            child: Image.asset('images/chat.png'))),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xffEDF0F5),
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Group Chat',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 19)),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffD1E7E8),
                                borderRadius: BorderRadius.circular(
                                  5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              child: const Text(
                                'messages',
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            messageList.when(data: (data) {
                              final List chat = jsonDecode(data);
                              List<ChatMessage>? chatList = chat.map((element) {
                                return ChatMessage(
                                    element['username'], element['message']);
                              }).toList();
                              return Expanded(
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(20),
                                    controller: scrollController,
                                    itemCount: chatList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment: username ==
                                                  chatList[index].username
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Material(
                                              color: const Color(0xffEDF0F5),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Text(
                                                        chatList[index]
                                                            .username,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: const TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: username ==
                                                                chatList[index]
                                                                    .username
                                                            ? const Color(
                                                                0xffD0D3E3)
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(15),
                                                          topRight: const Radius
                                                              .circular(15),
                                                          bottomLeft: username ==
                                                                  chatList[
                                                                          index]
                                                                      .username
                                                              ? const Radius
                                                                  .circular(15)
                                                              : Radius.zero,
                                                          bottomRight: username ==
                                                                  chatList[
                                                                          index]
                                                                      .username
                                                              ? Radius.zero
                                                              : const Radius
                                                                  .circular(15),
                                                        ),
                                                      ),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10,
                                                          vertical: 10),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Text(
                                                        chatList[index].message,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          letterSpacing: 2,
                                                          wordSpacing: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }, error: (obj, stake) {
                              return const Center(
                                  child: Text(
                                'Service unavailable',
                                style: TextStyle(color: Colors.red),
                              ));
                            }, loading: () {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.teal,
                                  backgroundColor: Colors.white,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 10,
                            child: Form(
                              child: TextFormField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  labelText: 'Send a message',
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(
                                        5,
                                      ),
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        if (_controller.text.isNotEmpty) {
                                          ChatWebSocket.getInstance()
                                              .sendMessage(
                                            username!,
                                            _controller.text,
                                          );
                                          _controller.clear();
                                        }
                                      },
                                      icon: const Icon(Icons.send,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildDivider() {
    return const Divider(
      thickness: 1,
      color: Colors.white12,
    );
  }
}
