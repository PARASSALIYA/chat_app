import 'package:chat_app/services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../model/chat_model.dart';
import '../../../model/user.model.dart';
import '../../../services/colud_notification_services.dart';
import '../../../services/firestore_services.dart';
import '../../../uitlls/get_pages.dart';
import '../../wallpaper/controller/wallpaper_controller.dart';
import '../controller/chat_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    UserModel user = Get.arguments;
    ChatController chatController = Get.put(ChatController());
    WallpaperController wallpaperController = Get.put(WallpaperController());
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_camera_back_outlined),
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: const Text("WallPaper"),
                  onTap: () {
                    Get.toNamed(GetPages.wallpaper);
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GetBuilder<WallpaperController>(builder: (context) {
            return Container(
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "${wallpaperController.images[wallpaperController.currentIndex]}",
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirestoreServices.firestoreServices.fetchChat(
                        sent:
                            AuthServices.authServices.currentUser!.email ?? '',
                        receiver: user.email),
                    builder: (context, snapshot) {
                      var data = snapshot.data;
                      var allData = data?.docs ?? [];

                      List<ChatModel> allChat = allData
                          .map((e) => ChatModel.toMap(e.data()))
                          .toList();
                      return ListView.builder(
                        itemCount: allChat.length,
                        itemBuilder: (context, index) {
                          if ((allChat[index].receiver == user.email)) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onDoubleTap: () {
                                      FirestoreServices.firestoreServices
                                          .deleteChat(
                                        sent: AuthServices.authServices
                                                .currentUser?.email ??
                                            "",
                                        receiver: user.email,
                                        id: allData[index].id,
                                      );
                                    },
                                    onLongPress: () {
                                      String msg = messageController.text =
                                          allChat[index].msg;

                                      chatController.changeUpdateValue(
                                          id: allData[index].id);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xffFFE1A5),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            allChat[index].msg,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.w,
                                            height: 5.h,
                                          ),
                                          Align(
                                            child: Text(
                                              "${allChat[index].time.toDate().hour}:${allChat[index].time.toDate().minute}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Visibility(
                                              child: Icon(
                                                Icons.done_all_outlined,
                                                size: 15,
                                                color: allChat[index].status ==
                                                        "seen"
                                                    ? Colors.blue
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            FirestoreServices.firestoreServices.seenChat(
                              id: allData[index].id,
                              receiver: user.email,
                              sent: AuthServices
                                      .authServices.currentUser!.email ??
                                  '',
                              selectIndex:
                                  "${wallpaperController.currentIndex}",
                            );
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onDoubleTap: () {
                                      FirestoreServices.firestoreServices
                                          .deleteChat(
                                        sent: AuthServices.authServices
                                                .currentUser?.email ??
                                            "",
                                        receiver: user.email,
                                        id: allData[index].id,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xff85C996),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            allChat[index].msg,
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                const Alignment(0.0, 1.0),
                                            child: Text(
                                              "${allChat[index].time.toDate().hour}:${allChat[index].time.toDate().minute}",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        controller: messageController,
                        decoration: const InputDecoration(
                          focusColor: Colors.black,
                          focusedBorder: OutlineInputBorder(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          labelText: 'Message...',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    GetBuilder<ChatController>(
                      builder: (context) {
                        return IconButton(
                          onPressed: () async {
                            String msg = messageController.text.trim();
                            if (msg.isNotEmpty) {
                              if (!chatController.isUpdate) {
                                ChatModel chatModel = ChatModel(
                                  sent: AuthServices
                                          .authServices.currentUser!.email ??
                                      '',
                                  receiver: user.email,
                                  msg: msg,
                                  status: "Unseen",
                                  selectIndex:
                                      "${wallpaperController.currentIndex}",
                                  time: Timestamp.now(),
                                );

                                FirestoreServices.firestoreServices
                                    .sentChat(chatModel: chatModel);
                                messageController.clear();
                              } else {
                                FirestoreServices.firestoreServices.updateChat(
                                  sent: AuthServices
                                          .authServices.currentUser!.email ??
                                      "",
                                  id: chatController.id,
                                  msg: messageController.text.trim(),
                                  receiver: user.email,
                                );
                                messageController.clear();
                                chatController.changeUpdateValueFalse();
                              }
                              await Notifications.notifications
                                  .sendNotification(
                                title: user.name,
                                body: msg,
                                token: user.token,
                              );
                              messageController.clear();
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
