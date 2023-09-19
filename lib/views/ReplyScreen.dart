import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newsplus/controllers/replyController.dart';
import 'package:newsplus/models/PostModel.dart';
import 'package:newsplus/models/ReplyModel.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:provider/provider.dart';

class ReplyScreen extends StatefulWidget {
  final PostModel post;

  ReplyScreen({required this.post});

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {

  bool loading = true;

  ReplyController replyController = ReplyController();

  getReply() async {


    await replyController.fetchRealTimeRepliesByPostId(widget.post.postId, () {setState(() {});});

    // await replyController.fetchRepliesByPostId(widget.post.postId); // Use the replyController to fetch reply data


    setState(() {
      loading = false;
    });

  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReply();

    for (var reply in replyController.mReplyList) {
      print('postId: ${reply.postId}');
      print('content: ${reply.content}');
      print('creationDate: ${reply.creationDate}');
      print('likesCount: ${reply.likesCount}');
      print('userId: ${reply.userId}');
      print('username: ${reply.username}');
      print('---------------'); // Add a separator for clarity
    }

  }

  TextEditingController replyTextController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: Container(child: CircularProgressIndicator()))
        : Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back, // Use the back arrow icon
              color: Colors.blue, // Set the color to blue
            ),
            onPressed: () {
              Navigator.pop(
                  context); // Navigate back when the back button is pressed
            },
          ),
          centerTitle: true,
          title: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "News",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Plus",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.blue, // Set the color to blue
              ),
              onPressed: () {
                Navigator.pushNamed(
                    context, '/profile'); // Replace with your profile route
              },
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Consumer<ReplyController>(builder: (context, replyProvider, child) {

        return Container(
          height: double.infinity,
          child: Stack(
            children : [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child:
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            widget.post.title,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircleAvatar(
                                        radius: 24.0,
                                        backgroundImage: NetworkImage(
                                          'https://t4.ftcdn.net/jpg/03/32/59/65/360_F_332596535_lAdLhf6KzbW6PWXBWeIFTovTii1drkbT.jpg',
                                        ),
                                      ),
                                    ),
                                    // Username
                                    Container(
                                      margin: EdgeInsets.only(right: 64.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.post
                                                .username, // Use post.username from the passed PostModel
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              // Post Created Time
                                              Text(
                                                widget.post.creationDate,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                     widget.post.content,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),

                                SizedBox(
                                  height: 20,
                                ),
                                Divider(
                                    color: Colors.black12,
                                    thickness: 4), // Add a grey divider

                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'All Comments : ' + replyController.mReplyList.length.toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8), // Add some spacing below the "All Comments" text

                                      Container(
                                        height: 350,
                                        child: ListView.builder(
                                          primary: false,
                                          shrinkWrap: true, // Wrap the ListView with a limited height
                                          itemCount: replyController.mReplyList.length, // Replace with the number of replies
                                          itemBuilder: (context, index) {
                                            // Use the data from your replyData list to create ReplyCard widgets
                                            final reply = replyController.mReplyList[index]; // Replace replyData with your data source

                                            return ReplyCard(
                                              controller: replyController,
                                              reply: reply,
                                              username: replyController.mReplyList[index].username,
                                              creationDate: replyController.mReplyList[index].creationDate,
                                              content: replyController.mReplyList[index].content,
                                              onUpdate: () {setState(() {

                                              });},
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ],
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyTextController,
                          decoration: InputDecoration(
                            hintText: 'Write your reply...',
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Handle posting the reply
                          String replyContent = replyTextController.text;

                          final user = FirebaseAuth.instance.currentUser;


                          if (user != null) {
                            final displayName = user.displayName ?? 'Unknown User';

                            await replyController.addReply(widget.post.postId, user.uid, displayName, replyContent);
                          }

                          // Force to refresh page after creating a post
                          setState(() {});

                          print('Posted reply: $replyContent');
                          // Clear the text field
                          replyTextController.clear();
                        },
                        child: Text('Reply'),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ),
        );
        }),
          );

  }
}
