import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OwnMsgWidget extends StatelessWidget {
  final String senderName;
  final String message;
  final String time;
  const OwnMsgWidget(
      {Key? key,
      required this.senderName,
      required this.message,
      required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 60),
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 1 / 100,
                left: MediaQuery.of(context).size.width * 15 / 100,
                right: MediaQuery.of(context).size.width * 2 / 100),
            padding: EdgeInsets.only(top: 15, bottom: 15, right: 20, left: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              color: Colors.green,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  message,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          )),
    );
  }
}
