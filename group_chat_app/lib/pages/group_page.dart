import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/models/msg_model.dart';
import 'package:group_chat_app/providers/user_provider.dart';
import 'package:group_chat_app/services/IP_address_service.dart';
import 'package:group_chat_app/widgets/other_file_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../widgets/other_msg_widget.dart';
import '../widgets/own_file_card.dart';
import '../widgets/own_msg_widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'call_page.dart';

class GroupPage extends StatefulWidget {
  final String userId;
  const GroupPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GroupPageState();
  }
}

class _GroupPageState extends State<GroupPage> {
  IO.Socket? socket;
  List<MsgModel> listMsg = [];
  TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool showEmojiSelect = false;
  FocusNode focusNode = FocusNode();
  // ImagePicker _picker = ImagePicker();
  // XFile? file;
  File? pickedImage;
  TextEditingController callIdController =
      TextEditingController(text: "call_id");

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      setState(() {
        pickedImage = tempImage;
      });

      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    // Connect to socket in backend when init screen
    connect();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          showEmojiSelect = false;
        });
      }
    });
  }

  void connect() {
    // Dart client
    socket = IO.io(
        'http://${IPAddressService().setIPAddress()}:3000', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket!.connect(); // Connect

    // Connecting
    socket!.onConnect((_) {
      print('Connected into Frontend!');
      // socket!.emit('sendMsg', 'Test emit event!');
      socket!.on("sendMsgServer", (msg) {
        print(msg);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        if (msg["userId"] != widget.userId) {
          setState(() {
            listMsg.add(
              MsgModel(
                  type: msg["type"],
                  msg: msg["msg"],
                  senderName: msg["senderName"],
                  time: msg["time"],
                  path: msg["path"]),
            );
          });
        }
      });
    });
    // socket!.on('event', (data) => print(data));
    // socket!.onDisconnect((_) => print('disconnect'));
    // socket!.on('fromServer', (_) => print(_));
  }

  void sendMsg(String msg, String senderName, String time, String path) {
    MsgModel ownMsg = new MsgModel(
        type: "ownMsg",
        msg: msg,
        senderName: senderName,
        time: time,
        path: path);
    listMsg.add(ownMsg);
    setState(() {
      listMsg;
    });

    socket!.emit('sendMsg', {
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName,
      "userId": widget.userId,
      "time": time,
      "path": path
    });
  }

  Widget emojiSelect() {
    return EmojiPicker(
        config: Config(columns: 8),
        onEmojiSelected: (category, emoji) {
          print(emoji);
        });
  }

  // void onImageSend(String path) async {
  //   var request = http.MultipartRequest(
  //       "POST",
  //       Uri.parse(
  //           "http://${IPAddressService().setIPAddress()}/routes/addimage"));
  //   request.files.add(await http.MultipartFile.fromPath("img", path));
  //   request.headers.addAll({
  //     "Content-type": "multipart/form-data",
  //   });
  //   http.StreamedResponse response = await request.send();
  //   print(response.statusCode);
  // }

  void ShowOption() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        context: this.context,
        builder: (context) {
          return Container(
            height: 120,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () async {
                      // file = await _picker.pickImage(source: ImageSource.camera);
                      pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.camera,
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Chụp ảnh',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.red),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  width: 240,
                  child: ElevatedButton(
                    onPressed: () async {
                      // file = await _picker.pickImage(source: ImageSource.gallery);
                      pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(
                            Icons.add_a_photo_outlined,
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Chọn từ Thư viện',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.red),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String username = Provider.of<UserProvider>(context).username;

    return Scaffold(
      backgroundColor: Color(0xFFE0E0E0),
      appBar: AppBar(
        leadingWidth: MediaQuery.of(context).size.width * 20 / 100,
        leading: Row(
          children: [
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.people_rounded,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // width: MediaQuery.of(context).size.width,
              child: Text(
                'GroupName',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CallPage(callID: callIdController.text),
                ));
              },
              icon: Icon(
                Icons.videocam,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                color: Colors.white,
              )),
        ],
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmojiSelect) {
              setState(() {
                showEmojiSelect = false;
              });
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
          },
          child: Column(
            children: [
              Expanded(
                  // child: ListView(
                  //   children: [OwnFileCard(), OtherFileCard()],
                  // ),
                  child: ListView.builder(
                controller: _scrollController,
                itemCount: listMsg.length + 1,
                itemBuilder: (context, index) {
                  if (index == listMsg.length) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 5 / 100,
                    );
                  }
                  if (listMsg[index].type == "ownMsg") {
                    return OwnMsgWidget(
                      senderName: listMsg[index].senderName.toString(),
                      message: listMsg[index].msg.toString(),
                      time: listMsg[index].time.toString(),
                    );
                  } else {
                    return OtherMsgWidget(
                      senderName: listMsg[index].senderName.toString(),
                      message: listMsg[index].msg.toString(),
                      time: listMsg[index].time.toString(),
                    );
                  }
                },
              )),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          child: Card(
                            margin:
                                EdgeInsets.only(left: 2, right: 2, bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            child: TextFormField(
                              controller: _msgController,
                              focusNode: focusNode,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.multiline,
                              maxLines: 20,
                              minLines: 1,
                              decoration: InputDecoration(
                                  hintText: 'Type a message...',
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      Icons.emoji_emotions,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      focusNode.unfocus();
                                      focusNode.canRequestFocus = false;
                                      setState(() {
                                        showEmojiSelect = !showEmojiSelect;
                                      });
                                    },
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.attach_file,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          ShowOption();
                                        },
                                        icon: Icon(
                                          Icons.camera_alt,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  contentPadding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width *
                                          5 /
                                          100),
                                  border: InputBorder.none),
                            ),
                          ),
                        )),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8, right: 5, left: 2),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.orange,
                            child: IconButton(
                              onPressed: () {
                                if (_msgController.text != '') {
                                  sendMsg(
                                      _msgController.text,
                                      username,
                                      DateTime.now()
                                          .toString()
                                          .substring(10, 16),
                                      "");
                                  _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut);
                                  _msgController.clear();
                                }
                              },
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    showEmojiSelect ? emojiSelect() : Container()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
