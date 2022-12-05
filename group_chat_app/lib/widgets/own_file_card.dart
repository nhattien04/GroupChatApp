import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OwnFileCard extends StatelessWidget {
  final String path;
  const OwnFileCard({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Container(
          width: MediaQuery.of(context).size.width * 65 / 100,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
          child: Card(
            child: Image.file(File(path)),
          ),
        ),
      ),
    );
  }
}
