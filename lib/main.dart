import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:doclinked1/pages/home.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();

  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_){
    print("Timestamps enabled in snapshots\n");
  }, onError: (_){
    print("Error enabling timestamps in snapshots\n");
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocLinked',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        primarySwatch: Colors.grey,
        cardColor: Colors.white70,
        accentColor: Colors.black,
      ),
      home: Home(),
    );
  }
}
