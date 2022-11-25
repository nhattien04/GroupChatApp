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

  @override
  void initState() {
    super.initState();

    // Connect to socket in backend when init screen
    connect();
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

  @override
  Widget build(BuildContext context) {
    String username = Provider.of<UserProvider>(context).username;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Group')),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 55,
                    child: TextFormField(
                      controller: _msgController,
                      decoration: InputDecoration(
                          hintText: 'Aa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide(width: 1, color: Colors.orange),
                          )),
                    ),
                  )),
                  IconButton(
                      onPressed: () {
                        if (_msgController.text != '') {
                          sendMsg(_msgController.text, username,
                              DateTime.now().toString().substring(10, 16));
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                          _msgController.clear();
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.orange,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
