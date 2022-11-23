import 'package:flutter/material.dart';
import 'package:group_chat_app/pages/home_page.dart';
import 'package:group_chat_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GroupChatApp(),
    ),
  );
}

class GroupChatApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GroupChatApp();
  }
}

class _GroupChatApp extends State<GroupChatApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Chat App',
      theme: ThemeData(primaryColor: Colors.white),
      home: Scaffold(
        body: SafeArea(
          child: HomePage(),
        ),
      ),
    );
  }
}
