import 'package:flutter/material.dart';
import 'package:notodo/UI/NoToDo.dart';

void main() =>
    runApp(MaterialApp(
      title: "Nothing",
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text("NoToDo"),
        centerTitle: true,
      ),
      body: new NoToDo(),
    );
  }
}

