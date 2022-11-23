import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier {
  late String _username;
  String get username => _username;

  setUsername(String username) {
    this._username = username;
    notifyListeners();
  }
}
