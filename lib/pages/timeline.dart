import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doclinked1/models/user.dart';
import 'package:doclinked1/pages/home.dart';
import 'package:doclinked1/widgets/header.dart';
import 'package:doclinked1/widgets/post.dart';
import 'package:doclinked1/widgets/progress.dart';
import 'package:flutter/material.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async{
    QuerySnapshot snapshot = await timelineRef.document(widget.currentUser.id).collection('timelinePosts').orderBy('timestamp', descending: true).getDocuments();
    List<Post> posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    }
    else if (posts.isEmpty) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/images/neo-sakura-404-not-found.png"),
                height: 260.0,
              ),
            ],
          ),
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                "No Posts",
                cursor: "",
                textAlign: TextAlign.center,
                textStyle: const TextStyle(
                  fontSize: 50.0,
                  fontFamily: "Signatra",
                  color: Colors.grey,
                ),
                speed: const Duration(milliseconds: 200),
              ),
            ],
            //totalRepeatCount: 4,
            pause: const Duration(milliseconds: 1000),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
            repeatForever: true,
          ),
        ],
      );
    }
    else {
      return ListView(
        children: posts,
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
