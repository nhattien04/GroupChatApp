import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/models/msg_model.dart';
import 'package:group_chat_app/providers/user_provider.dart';
import 'package:group_chat_app/services/IP_address_service.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../widgets/other_msg_widget.dart';
import '../widgets/own_msg_widget.dart';

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
                  time: msg["time"]),
            );
          });
        }
      });
    });
    // socket!.on('event', (data) => print(data));
    // socket!.onDisconnect((_) => print('disconnect'));
    // socket!.on('fromServer', (_) => print(_));
  }

  void sendMsg(String msg, String senderName, String time) {
    MsgModel ownMsg = new MsgModel(
        type: "ownMsg", msg: msg, senderName: senderName, time: time);
    listMsg.add(ownMsg);
    setState(() {
      listMsg;
    });

    socket!.emit('sendMsg', {
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName,
      "userId": widget.userId,
      "time": time
    });
  }

  Widget emojiSelect() {
    return EmojiPicker(
        config: Config(columns: 8),
        onEmojiSelected: (category, emoji) {
          print(emoji);
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
              onPressed: () {},
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
                  child: ListView.builder(
                controller: _scrollController,
                itemCount: listMsg.length + 1,
                itemBuilder: (context, index) {
                  if (index == listMsg.length) {
                    return Container(
                      height: 80,
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
                                  hintText: 'Type a message',
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
                                        onPressed: () {},
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
                                          .substring(10, 16));
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
