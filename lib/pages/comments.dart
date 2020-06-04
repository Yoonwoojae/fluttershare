import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String mediaUrl;

  Comments({this.postId, this.ownerId, this.mediaUrl});

  @override
  CommentsState createState() => CommentsState(
        postId: postId,
        ownerId: ownerId,
        mediaUrl: mediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String ownerId;
  final String mediaUrl;

  CommentsState({this.postId, this.ownerId, this.mediaUrl});

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];

        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(children: comments);
      },
    );
  }

  addComment() {
    commentsRef.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestemp": timestamp,
      "avataUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: OutlineButton(
              onPressed: () => addComment,
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avataUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avataUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avataUrl: doc['avataUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avataUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
