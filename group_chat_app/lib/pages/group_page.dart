import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/models/msg_model.dart';
import 'package:group_chat_app/providers/user_provider.dart';
import 'package:group_chat_app/services/IP_address_service.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GroupPageState();
  }
}

class _GroupPageState extends State<GroupPage> {
  IO.Socket? socket;
  List<MsgModel> listMsg = [];
  TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Connect to socket in backend when init screen
    connect();
  }

  void connect() {
    // Dart client
    socket = IO.io('http://${IPAddressService().setIPAddress()}:3000', <String, dynamic> {
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
        listMsg.add(msg);
      });
    });
    // socket!.on('event', (data) => print(data));
    // socket!.onDisconnect((_) => print('disconnect'));
    // socket!.on('fromServer', (_) => print(_));
  }

  void senMsg(String msg, String senderName) {
    MsgModel owmMsg = MsgModel(type: "ownMsg", msg: msg, senderName: senderName);
    listMsg.add(owmMsg);

    socket!.emit('sendMsg', {
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName
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
            Expanded(child: Container()),
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
                        borderSide: BorderSide(width: 1, color: Colors.orange),
                      )
                  ),
                ),
                    )),
                IconButton(onPressed: () {
                  if (_msgController.text != '') {
                    senMsg(_msgController.text, username);
                    _msgController.clear();
                  }
                }, icon: Icon(Icons.send, color: Colors.orange,))
              ],
            ),),
          ],
        ),
      ),
    );
  }
}
