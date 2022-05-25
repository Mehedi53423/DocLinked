import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doclinked1/widgets/header.dart';
import 'package:doclinked1/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'home.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
    postId: this.postId,
    postOwnerId: this.postOwnerId,
    postMediaUrl: this.postMediaUrl,
  );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments(){
    return StreamBuilder(
      stream: commentsRef.document(postId).collection('comments').orderBy("timestamp", descending: false).snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc){
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment(){
    commentsRef.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });

    bool isNotPostOwner = postOwnerId != currentUser.id;

    if(isNotPostOwner){
      activityFeedRef.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentData": commentController.text,
        "timestamp": timestamp,
        "postId": postId,
        "userId": currentUser.id,
        "username": currentUser.username,
        "userProfileImg": currentUser.photoUrl,
        "mediaUrl": postMediaUrl,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Comments"
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: buildComments()
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            title: TextFormField(
              style: TextStyle(
                color: Colors.white,
              ),
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Write a comment...",
                labelStyle: TextStyle(
                    color: Colors.grey,
                ),
              ),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              //borderSide: BorderSide.none,
              child: Text(
                  "Post",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
              comment,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
