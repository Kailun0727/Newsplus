import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/controllers/postController.dart';
import 'package:newsplus/controllers/replyController.dart';
import 'package:newsplus/controllers/savedNewsController.dart';
import 'package:newsplus/helper/languageMapper.dart';
import 'package:newsplus/models/PostModel.dart';
import 'package:newsplus/models/SavedNewsModel.dart';
import 'package:newsplus/views/ArticleScreen.dart';
import 'package:newsplus/views/CategoryNewsScreen.dart';
import 'package:newsplus/views/CommunityPostScreen.dart';
import 'package:newsplus/views/ReplyScreen.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsplus/models/ReplyModel.dart';





//Bottom Navigation Bar
class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {


  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(color: Colors.blue),
      unselectedLabelStyle: const TextStyle(color: Colors.grey),
      currentIndex: widget.selectedIndex,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label:  AppLocalizations.of(context)!.community,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bookmark),
          label:  AppLocalizations.of(context)!.savedNews,
        ),
      ],
      onTap: (index) {
        widget.onItemSelected(index);
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/community');
            break;
          case 2:
            Navigator.pushNamed(context, '/savedNews');
            break;
          default:
        }
      },
    );
  }
}

class CustomImagePickerDialog extends StatelessWidget {
  final Function(String)? onImageSelected;

  CustomImagePickerDialog({Key? key, this.onImageSelected}) : super(key: key);

  final List<String> avatarUrls = [
    'https://cdn1.iconfinder.com/data/icons/user-pictures/101/malecostume-512.png',
    'https://w7.pngwing.com/pngs/129/292/png-transparent-female-avatar-girl-face-woman-user-flat-classy-users-icon.png',
    'https://t4.ftcdn.net/jpg/03/32/59/65/360_F_332596535_lAdLhf6KzbW6PWXBWeIFTovTii1drkbT.jpg',
    // Add more avatar URLs as needed
  ];

  Future<void> _selectAvatar(String avatarUrl) async {
    if (onImageSelected != null) {
      onImageSelected!(avatarUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Select Avatar',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
      content: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 300, // Set a minimum height for the AlertDialog
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (String avatarUrl in avatarUrls)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      _selectAvatar(avatarUrl);
                      Navigator.of(context).pop();
                    },
                    child: CircleAvatar(
                      radius: 60, // Adjust the radius to make the avatars larger
                      backgroundImage: CachedNetworkImageProvider(avatarUrl),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


class SavedNewsCard extends StatefulWidget {
  final imageUrl;
  final title;
  final description;
  final url;
  final creationDate;
  final SavedNewsController controller;
  final Function()? onRemove; // callback function

  const SavedNewsCard(
      {Key? key,
        required this.controller,
      required this.imageUrl,
      required this.title,
      required this.description,
      required this.creationDate,
      required this.url,
        this.onRemove
      })
      : super(key: key);

  @override
  _SavedNewsCardState createState() => _SavedNewsCardState();


}

class _SavedNewsCardState extends State<SavedNewsCard> {




  void _handleRemove() async {
    try {
      await widget.controller.removeSavedNews(context, widget.title);

      // Trigger the refresh callback after successful removal
      if (widget.onRemove != null) {
        widget.onRemove!();
      }
    } catch (error) {
      // Removal failed, show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to remove news: $error'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? preferLanguage = prefs.getString('prefer_language');
        String? languageCode = LanguageMapper.getLanguageCode(preferLanguage!);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ArticleScreen(url: widget.url, languageCode: languageCode.toString(),), // Pass the URL to ArticleScreen
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top:8.0, bottom: 8),
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 1.5, // Adds a shadow to the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Customizes the card's shape
            side: const BorderSide( // Customize the border
              color: Colors.black12, // Border color
              width: 1.0, // Border width
            ),
          ),

          child: Container(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align children to the start (left side)
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              width: 500,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0, right: 8),
                            child: Text(
                              widget.creationDate,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0, right: 8),
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0, right: 8),
                            child: Text(
                              widget.description,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8, // Adjust the top position as needed
                        right: 8, // Adjust the right position as needed
                        child: PopupMenuButton<String>(
                          itemBuilder: (context) => <PopupMenuEntry<String>>[

                            PopupMenuItem<String>(
                              value: 'Share',
                              child: Row(
                                children: [
                                  const Icon(Icons.share,
                                      color: Colors.blue), // Share icon
                                  const SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.share,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            PopupMenuItem<String>(
                              value: 'Remove',
                              child: Row(
                                children: [
                                  const Icon(Icons.remove,
                                      color: Colors.blue), // Share icon
                                  const SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.remove,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {

                            if (value == 'Share') {
                              // Perform action for Share

                              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                              analytics.setAnalyticsCollectionEnabled(true);

                              await analytics.logEvent(
                                name: 'share_news',
                                parameters: <String, dynamic>{
                                  'share_news_url': widget.url,
                                },
                              );

                              Share.share(widget.url);
                            } else if (value == 'Remove') {

                              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                              analytics.setAnalyticsCollectionEnabled(true);

                              await analytics.logEvent(
                                name: 'remove_news',
                                parameters: <String, dynamic>{
                                  'news_title': widget.title,
                                },
                              );

                               _handleRemove();
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue, // Change to your desired color
                            ),
                            child: const Icon(
                              Icons
                                  .more_vert, // You can replace this with your kebab menu icon
                              size: 24, // Adjust the icon size as needed
                              color:
                              Colors.white, // Change to your desired icon color
                            ),
                            width:
                            42, // Adjust the width to make the circle smaller
                            height:
                            42, // Adjust the height to make the circle smaller
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//News Card
class NewsCard extends StatefulWidget {
  final imageUrl;
  String? title;
  String? description;
  final url;
  final publishedAt;
  final category;

  NewsCard(
      {Key? key,
      required this.imageUrl,
      required this.title,
      required this.description,
      required this.publishedAt,
      required this.url,
        required this.category

      })
      : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool isSavedToLater = false; // Added state variable
  String? translatedTitle;
  String? translatedDescription;

  Future<void> translateTitleAndDescription() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? preferLanguage = prefs.getString('prefer_language') ?? "English";
    String? languageCode = LanguageMapper.getLanguageCode(preferLanguage!);


    String translateTitle = await NewsController.translate(widget.title,languageCode!.toLowerCase());
    String translateDescription = await NewsController.translate(widget.description,languageCode!.toLowerCase());

    setState(() {
      translatedTitle = translateTitle;
      translatedDescription = translateDescription;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {

        FirebaseAnalytics analytics = FirebaseAnalytics.instance;

        analytics.setAnalyticsCollectionEnabled(true);

        await analytics.logEvent(
          name: 'view_news',
          parameters: <String, dynamic>{
            'news_url': widget.url,
          },
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? preferLanguage = prefs.getString('prefer_language') ?? "English";
        String? languageCode = LanguageMapper.getLanguageCode(preferLanguage!);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ArticleScreen(url: widget.url,languageCode: languageCode.toString(),), // Pass the URL to ArticleScreen
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top:8.0,bottom: 8),
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 1.5, // Adds a shadow to the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Customizes the card's shape
            side: const BorderSide( // Customize the border
              color: Colors.black12, // Border color
              width: 1.0, // Border width
            ),
          ),


          child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align children to the start (left side)
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                              width: 500,
                              height: 200,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(milliseconds: 500), // Adjust the duration as needed
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0,right: 8),
                            child: Text(
                              widget.publishedAt,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0,right: 8),
                            child: Text(
                              translatedTitle ??  widget.title!,

                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:8.0,right: 8),
                            child: Text(
                              translatedDescription ?? widget.description!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8, // Adjust the top position as needed
                        right: 8, // Adjust the right position as needed
                        child: PopupMenuButton<String>(
                          itemBuilder: (context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'Share',
                              child: Row(
                                children: [
                                  const Icon(Icons.share,
                                      color: Colors.blue), // Share icon
                                  const SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.share,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Save',
                              child: Row(
                                children: [
                                  Icon(Icons.bookmark,
                                      color: (isSavedToLater
                                          ? Colors.grey
                                          : Colors.green)), // Save icon
                                  const SizedBox(width: 8.0),
                                  Text(
                                    isSavedToLater ? AppLocalizations.of(context)!.saved : AppLocalizations.of(context)!.saveToLater,
                                    style: TextStyle(
                                      color: isSavedToLater
                                          ? Colors.grey
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'Like',
                              child: Row(
                                children: [
                                  const Icon(Icons.thumb_up,
                                      color: Colors.orange), // Thumb up icon
                                  const SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.moreStories,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        PopupMenuItem<String>(
                            value: 'translate', // Add a value for the "Translate" option
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.translate,
                                  color: Colors.blue, // Set the icon color to blue
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  AppLocalizations.of(context)!.translate, // Add the text for the "Translate" option
                                  style: const TextStyle(
                                    color: Colors.blue, // Set the text color to blue
                                  ),
                                ),
                              ],
                            ),
                        )
                          ],
                          onSelected: (value) async {
                            // Handle the selected menu item
                            if (value == 'Share') {
                              // Perform action for Share

                              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                              analytics.setAnalyticsCollectionEnabled(true);

                              await analytics.logEvent(
                                name: 'share_news',
                                parameters: <String, dynamic>{
                                  'share_news_url': widget.url,
                                },
                              );

                              Share.share(widget.url);
                            } else if (value == 'Save') {

                              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                              analytics.setAnalyticsCollectionEnabled(true);

                              await analytics.logEvent(
                                name: 'save_news',
                                parameters: <String, dynamic>{
                                  'news_url': widget.url,
                                },
                              );

                              if (!isSavedToLater) {
                                final user = FirebaseAuth.instance.currentUser;

                                if (user != null) {
                                  String userId = user.uid;

                                  SavedNewsModel model = SavedNewsModel(
                                    title: widget.title!,
                                    description: widget.description!,
                                    url : widget.url,
                                    imageUrl: widget.imageUrl,
                                    creationDate: DateTime.now().add(const Duration(hours: 8)),
                                    userId: userId,
                                  );

                                  try {
                                    await NewsController.saveNews(model);

                                    setState(() {
                                      isSavedToLater = true;
                                    });

                                    final snackBar = SnackBar(
                                      content: Text(AppLocalizations.of(context)!.saveNewsSuccess),
                                      duration: const Duration(seconds: 2),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } catch (error) {
                                    print('Error saving news: $error');
                                    final snackBar = SnackBar(
                                      content: Text('Error saving news: $error'),
                                      duration: const Duration(seconds: 2),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                }
                              } else {
                                final snackBar = SnackBar(
                                  content: Text(AppLocalizations.of(context)!.searchPostHintText),
                                  duration: const Duration(seconds: 2),
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            } else if (value == 'Like') {

                              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                              analytics.setAnalyticsCollectionEnabled(true);

                              await analytics.logEvent(
                                name: 'recommend_category',
                                parameters: <String, dynamic>{
                                  'category': widget.category,
                                },
                              );

                              // Perform action for More Stories Like This
                              // Store the widget.category using shared preferences
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('prefer_category', widget.category);

                              print('Prefer Category changed to '+ widget.category);

                              final snackBar = SnackBar(
                                content: Text(AppLocalizations.of(context)!.moreStoriesClicked),
                                duration: const Duration(seconds: 2),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(snackBar);


                            } else if (value == 'translate') {

                              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                              analytics.setAnalyticsCollectionEnabled(true);

                              await analytics.logEvent(
                                name: 'translate_news',
                                parameters: <String, dynamic>{
                                  'news_title': widget.title,
                                },
                              );

                                translateTitleAndDescription();

                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue, // Change to your desired color
                            ),
                            width:
                                42, // Adjust the width to make the circle smaller
                            height:
                                42,
                            child: const Icon(
                              Icons
                                  .more_vert, // You can replace this with your kebab menu icon
                              size: 24, // Adjust the icon size as needed
                              color:
                                  Colors.white, // Change to your desired icon color
                            ), // Adjust the height to make the circle smaller
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),


        ),
      ),
    );
  }
}


class ReplyCard extends StatefulWidget {
  ReplyModel reply;
  final String username;
  final String creationDate;
  String content;
  final String photoUrl;
  final ReplyController controller;
  final Function()? onUpdate; // callback function

   ReplyCard({
    required this.reply,
    required this.username,
    required this.creationDate,
    required this.content,
    required this.photoUrl,
    required this.controller,
    required this.onUpdate
  });

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {

  bool isLiked = false;

  bool isReported = false;

  Future<void> translateReply() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? preferLanguage = prefs.getString('prefer_language') ?? "English";
    String? languageCode = LanguageMapper.getLanguageCode(preferLanguage!);

    String translateReply = await NewsController.translate(widget.content,languageCode!.toLowerCase());

    setState(() {
      widget.content = translateReply;
    });
  }


  @override
  Widget build(BuildContext context) {

    final reply = widget.reply; // Access the post from the widget's properties

    void showReportConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.reportTitle),
            content: Text(AppLocalizations.of(context)!.reportHintText),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // User chose not to report
                },
                child: Text(AppLocalizations.of(context)!.reportNo),
              ),
              TextButton(
                onPressed: () async {

                  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                  analytics.setAnalyticsCollectionEnabled(true);

                  await analytics.logEvent(
                    name: 'report_reply',
                    parameters: <String, dynamic>{
                      'reply_id': widget.reply.replyId,
                    },
                  );


                  await widget.controller.updateReplyReportCount(context, reply.postId, reply.replyId, reply.reportCount, isReported);

                  // Toggle the like status
                  setState(() {
                    isReported = !isReported;
                  });

                  // Trigger the refresh callback after successful update
                  if (widget.onUpdate != null) {
                    widget.onUpdate!();
                  }

                  Navigator.of(context).pop(true); // User chose to report

                },
                child: Text(AppLocalizations.of(context)!.reportYes),
              ),
            ],
          );
        },
      );
    }


    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 24.0,
                  backgroundImage: CachedNetworkImageProvider(
                    reply.photoUrl,
                  ),
                ),
                // Username
                Container(
                  margin: const EdgeInsets.only(right: 64.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 6,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Post Created Time
                          Text(
                            widget.creationDate,
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
                // Kebab Menu
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    // Handle menu item selection
                    if (value == 'report') {
                      // Handle report action
                      if (!isReported) {
                        showReportConfirmationDialog(context);
                      } else {
                        // Show a SnackBar message to inform the user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.cannotReportAgain),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }

                    if(value == "translate"){
                      FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                      analytics.setAnalyticsCollectionEnabled(true);

                      await analytics.logEvent(
                        name: 'translate_reply',
                        parameters: <String, dynamic>{
                          'reply_content': widget.content,
                        },
                      );

                      translateReply();
                    }


                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'report',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.report,
                              color: Colors.red, // Set the icon color to red
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              AppLocalizations.of(context)!.reportTitle,
                              style: const TextStyle(
                                color: Colors.red, // Set the text color to red
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'translate', // Add a value for the "Translate" option
                        child: Row(
                          children: [
                            const Icon(
                              Icons.translate,
                              color: Colors.blue, // Set the icon color to blue
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              AppLocalizations.of(context)!.translate, // Add the text for the "Translate" option
                              style: const TextStyle(
                                color: Colors.blue, // Set the text color to blue
                              ),
                            ),
                          ],
                        ),
                      )

                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.content,
                  style: const TextStyle(fontSize: 16.0, ),
                ),
                const SizedBox(height: 6,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {

                        FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                        analytics.setAnalyticsCollectionEnabled(true);

                        await analytics.logEvent(
                          name: 'like__reply',
                          parameters: <String, dynamic>{
                            'reply_like_count': reply.likesCount,
                          },
                        );


                        await widget.controller.updateLikesCount(reply.replyId, reply.likesCount, isLiked);

                        // Toggle the like status
                        setState(() {
                          isLiked = !isLiked;
                        });

                        // Trigger the refresh callback after successful update
                        if (widget.onUpdate != null) {
                          widget.onUpdate!();
                        }

                      },
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        // Change the icon to outline when not liked
                      ),
                      label: Text(
                        widget.reply.likesCount.toString() +' '+ AppLocalizations.of(context)!.likes,
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditPostCard extends StatefulWidget {
  final PostModel post;

  final PostController controller;

  final Function()? onRemove; // callback function

  const EditPostCard({Key? key, required this.post, required this.controller, required this.onRemove}) : super(key: key);

  @override
  _EditPostCardState createState() => _EditPostCardState();
}

class _EditPostCardState extends State<EditPostCard> {
  bool isLiked = false;
  bool isReported = false;

  Future<void> translateTitleAndContent() async {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? preferLanguage = prefs.getString('prefer_language') ?? "English";
    String? languageCode = LanguageMapper.getLanguageCode(preferLanguage!);


    String translateTitle = await NewsController.translate(widget.post.title,languageCode!.toLowerCase());
    String translateContent = await NewsController.translate(widget.post.content,languageCode!.toLowerCase());

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    analytics.setAnalyticsCollectionEnabled(true);

    await analytics.logEvent(
      name: 'translate_post',
      parameters: <String, dynamic>{
        'post_title': widget.post.title,
        'post_content' : widget.post.content
      },
    );

    setState(() {
      widget.post.title = translateTitle;
      widget.post.content = translateContent;
    });
  }

  // map communityId values to category names
  String mapCommunityIdToCategory(String communityId) {
    switch (communityId) {
      case '1':
        return AppLocalizations.of(context)!.general;
      case '2':
        return AppLocalizations.of(context)!.entertainment;
      case '3':
        return AppLocalizations.of(context)!.business;
      case '4':
        return AppLocalizations.of(context)!.technology;
      case '5':
        return AppLocalizations.of(context)!.health;
      case '6':
        return AppLocalizations.of(context)!.science;
      case '7':
        return AppLocalizations.of(context)!.sports;
      default:
        return 'Unknown'; // Default category for unknown communityId
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post; // Access the post from the widget's properties

    void _showEditPostDialog() {
      TextEditingController postTextController = TextEditingController();
      TextEditingController titleController = TextEditingController();
      String selectedCategory = widget.post.communityId;

      final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.editPost),
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText:AppLocalizations.of(context)!.selectCategory,
                          border: OutlineInputBorder(),
                          // Customize the label text style
                          labelStyle: TextStyle(
                            color: Colors
                                .blue, // Change the label text color to your preference
                          ),
                        ),
                        // Customize the dropdown button style
                        icon: Icon(Icons
                            .arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                          color: Colors
                              .black,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '1',
                            child: Text(AppLocalizations.of(context)!.general),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text(AppLocalizations.of(context)!.entertainment),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text(AppLocalizations.of(context)!.business),
                          ),
                          DropdownMenuItem(
                            value: '4',
                            child: Text(AppLocalizations.of(context)!.technology),
                          ),
                          DropdownMenuItem(
                            value: '5',
                            child: Text(AppLocalizations.of(context)!.health),
                          ),
                          DropdownMenuItem(
                            value: '6',
                            child: Text(AppLocalizations.of(context)!.science),
                          ),
                          DropdownMenuItem(
                            value: '7',
                            child: Text(AppLocalizations.of(context)!.sports),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: titleController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.postTitleHintText,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.titleEmpty;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: postTextController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:  AppLocalizations.of(context)!.contentHintText,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.contentEmpty;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                String postText = postTextController.text.toString();
                                String title = titleController.text.toString();

                                final user = FirebaseAuth.instance.currentUser;

                                if (user != null) {

                                  await widget.controller.editPost(widget.post.postId, title, postText, selectedCategory);

                                  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                                  analytics.setAnalyticsCollectionEnabled(true);

                                  await analytics.logEvent(
                                    name: 'edit_post',
                                    parameters: <String, dynamic>{
                                      'post_title': widget.post.title,
                                      'post_content': widget.post.content,
                                    },
                                  );
                                }

                                Navigator.pop(context);

                                // Force to refresh page after creating a post
                                setState(() {});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.editButtonText,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.cancelButtonText,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    void _showDeletePostConfirmationDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(AppLocalizations.of(context)!.confirmDeleteHintText),
            actions: [
              TextButton(
                onPressed: () async {

                  await widget.controller.deletePost(widget.post.postId);

                  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                  analytics.setAnalyticsCollectionEnabled(true);

                  await analytics.logEvent(
                    name: 'delete_post',
                    parameters: <String, dynamic>{
                      'post_id': widget.post.postId
                    },
                  );

                  Navigator.pop(context);

                  setState(() {});

                },
                child: Text(AppLocalizations.of(context)!.delete),
              ),
              TextButton(
                onPressed: () {
                  // Close the dialog without deleting the post
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancelButtonText),
              ),
            ],
          );
        },
      );
    }


    return Card(
      elevation: 1.5,

      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: CircleAvatar(
                          radius: 24.0,
                          backgroundImage: CachedNetworkImageProvider(
                            post.photoUrl,
                          ),
                        ),
                      ),
                      // Username
                      Expanded(
                        child: Container(
                          // Adjust margin or padding as needed
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 6,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Post Created Time
                                  Text(
                                    post.creationDate,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(width: 3.0),
                                  const Icon(
                                    Icons.circle,
                                    size: 4.0,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 3.0),
                                  // Category
                                  Text(
                                    mapCommunityIdToCategory(post.communityId),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Kebab Menu
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          // Handle menu item selection
                          if (value == 'edit') {
                            // Handle edit action
                            _showEditPostDialog();
                          } else if (value == 'delete') {
                            // Handle delete action
                            _showDeletePostConfirmationDialog();
                          }else if(value == "translate"){
                            translateTitleAndContent();
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blue, // Change the icon color for edit
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.edit,
                                    style: TextStyle(
                                      color: Colors.blue, // Change the text color for edit
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red, // Change the icon color for delete
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.delete,
                                    style: TextStyle(
                                      color: Colors.red, // Change the text color for delete
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'translate', // Add a value for the "Translate" option
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.translate,
                                    color: Colors.blue, // Set the icon color to blue
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    AppLocalizations.of(context)!.translate, // Add the text for the "Translate" option
                                    style: const TextStyle(
                                      color: Colors.blue, // Set the text color to blue
                                    ),
                                  ),
                                ],
                              ),
                            )

                          ];
                        },
                      )
                    ],
                  ),


                  const SizedBox(height: 8.0),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        post.title, // Use post.content from the passed PostModel
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6,),
                      Text(
                        post.content, // Use post.content from the passed PostModel
                        style: const TextStyle(fontSize: 14.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final PostModel post;

  final PostController controller;

  final Function()? onUpdate; // callback function

  const PostCard({Key? key, required this.post, required this.controller, required this.onUpdate}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  bool isReported = false;


  Future<void> translateTitleAndContent() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? preferLanguage = prefs.getString('prefer_language') ?? "English";
    String? languageCode = LanguageMapper.getLanguageCode(preferLanguage!);

    String translateTitle = await NewsController.translate(widget.post.title,languageCode!.toLowerCase());
    String translateContent = await NewsController.translate(widget.post.content,languageCode!.toLowerCase());

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    analytics.setAnalyticsCollectionEnabled(true);

    await analytics.logEvent(
      name: 'translate_post',
      parameters: <String, dynamic>{
        'post_title': widget.post.title,
        'post_content': widget.post.content,
      },
    );

    setState(() {
      widget.post.title = translateTitle;
      widget.post.content = translateContent;
    });
  }


  // map communityId values to category names
  String mapCommunityIdToCategory(String communityId) {
    switch (communityId) {
      case '1':
        return AppLocalizations.of(context)!.general;
      case '2':
        return AppLocalizations.of(context)!.entertainment;
      case '3':
        return AppLocalizations.of(context)!.business;
      case '4':
        return AppLocalizations.of(context)!.technology;
      case '5':
        return AppLocalizations.of(context)!.health;
      case '6':
        return AppLocalizations.of(context)!.science;
      case '7':
        return AppLocalizations.of(context)!.sports;
      default:
        return 'Unknown'; // Default category for unknown communityId
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post; // Access the post from the widget's properties

    void showReportConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.reportTitle),
            content: Text(AppLocalizations.of(context)!.reportHintText),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // User chose not to report
                },
                child: Text(AppLocalizations.of(context)!.reportNo),
              ),
              TextButton(
                onPressed: () async {

                  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                  analytics.setAnalyticsCollectionEnabled(true);

                  await analytics.logEvent(
                    name: 'report_post',
                    parameters: <String, dynamic>{
                      'report_post_id': widget.post.postId,
                    },
                  );

                  await widget.controller.updateReportCount(context,post.postId, post.reportCount, isReported);

                  // Toggle the like status
                  setState(() {
                    isReported = !isReported;
                  });

                  // Trigger the refresh callback after successful update
                  if (widget.onUpdate != null) {
                    widget.onUpdate!();
                  }

                  Navigator.of(context).pop(true); // User chose to report

                },
                child: Text(AppLocalizations.of(context)!.reportYes),
              ),
            ],
          );
        },
      );
    }


    return Card(
      elevation: 1.5,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: CircleAvatar(
                          radius: 24.0,
                          backgroundImage: CachedNetworkImageProvider(
                           post.photoUrl,
                          ),
                        ),
                      ),
                      // Username
                      Expanded(
                        child: Container(
                          // Adjust margin or padding as needed
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              const SizedBox(height: 6,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Post Created Time
                                  Text(
                                    post.creationDate,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  const SizedBox(width: 3.0),
                                  const Icon(
                                    Icons.circle,
                                    size: 4.0,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 3.0),
                                  // Category
                                  Text(
                                    mapCommunityIdToCategory(post.communityId),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Kebab Menu
                      PopupMenuButton<String>(
                          onSelected: (value) {
                            // Handle menu item selection
                            if (value == 'report') {
                              // Handle report action
                              if (!isReported) {
                                showReportConfirmationDialog(context);
                              } else {
                                // Show a SnackBar message to inform the user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.cannotReportAgain),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }

                            if(value == "translate"){
                              translateTitleAndContent();
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.report,
                                      color: isReported ? Colors.grey : Colors.red,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      AppLocalizations.of(context)!.reportTitle,
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              PopupMenuItem<String>(
                                value: 'translate', // Add a value for the "Translate" option
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.translate,
                                      color: Colors.blue, // Set the icon color to blue
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      AppLocalizations.of(context)!.translate, // Add the text for the "Translate" option
                                      style: const TextStyle(
                                        color: Colors.blue, // Set the text color to blue
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ];
                          },
                        ),

                    ],
                  ),


                  const SizedBox(height: 8.0),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        post.title, // Use post.content from the passed PostModel
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6,),
                      Text(
                        post.content, // Use post.content from the passed PostModel
                        style: const TextStyle(fontSize: 14.0, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  // Like Button with Like Count and Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {

                          await widget.controller.updateLikesCount(post.postId, post.likesCount, isLiked);

                          // Toggle the like status
                          setState(() {
                            isLiked = !isLiked;
                          });

                          // Trigger the refresh callback after successful update
                          if (widget.onUpdate != null) {
                            widget.onUpdate!();
                          }

                        },
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          // Change the icon to outline when not liked
                        ),
                        label: Text(
                          widget.post.likesCount.toString() + " "+ AppLocalizations.of(context)!.likes,
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20,),

                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle the reply button tap
                          // Navigate to the ReplyScreen and pass the post object
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReplyScreen(post: widget.post),
                            ),
                          );
                        },
                        icon: const Icon(Icons.reply),
                        label: Text(AppLocalizations.of(context)!.reply),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class CommunityCard extends StatelessWidget {
  final String communityId;
  final String description;
  final BuildContext context;

  const CommunityCard({
    Key? key,
    required this.communityId,
    required this.description,
    required this.context
  }) : super(key: key);

  String mapCommunityIdToTitle(String communityId) {
    switch (communityId) {
      case '1':
        return AppLocalizations.of(context)!.general;
      case '2':
        return AppLocalizations.of(context)!.entertainment;
      case '3':
        return AppLocalizations.of(context)!.business;
      case '4':
        return AppLocalizations.of(context)!.technology;
      case '5':
        return AppLocalizations.of(context)!.health;
      case '6':
        return AppLocalizations.of(context)!.science;
      case '7':
        return AppLocalizations.of(context)!.sports;
      default:
        return 'Unknown'; // Default category for unknown communityId
    }
  }

  String mapCommunityIdToDesciption(String communityId) {
    switch (communityId) {
      case '1':
        return AppLocalizations.of(context)!.generalDescription;
      case '2':
        return AppLocalizations.of(context)!.entertainmentDescription;
      case '3':
        return AppLocalizations.of(context)!.businessDescription;
      case '4':
        return AppLocalizations.of(context)!.technologyDescription;
      case '5':
        return AppLocalizations.of(context)!.healthDescription;
      case '6':
        return AppLocalizations.of(context)!.scienceDescription;
      case '7':
        return AppLocalizations.of(context)!.sportsDescription;
      default:
        return 'Unknown'; // Default category for unknown communityId
    }
  }

  String mapCommunityIdToImageUrl(String communityId) {
    switch (communityId) {
      case '1':
        return "https://images.unsplash.com/photo-1432821596592-e2c18b78144f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80";
      case '2':
        return "https://plus.unsplash.com/premium_photo-1682401101972-5dc0756ece88?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80";
      case '3':
        return "https://images.unsplash.com/photo-1507679799987-c73779587ccf?ixlib=rb-1.2.1&auto=format&fit=crop&w=1502&q=80";
      case '4':
        return "https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80";
      case '5':
        return "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80";
      case '6':
        return "https://plus.unsplash.com/premium_photo-1676325102583-0839e57d7a1f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80";
      case '7':
        return "https://images.unsplash.com/photo-1517649763962-0c623066013b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1770&q=80";
      default:
        return ''; // Default imageUrl for unknown communityId
    }
  }
  
  @override
  Widget build(BuildContext context) {
    String communityTitle = mapCommunityIdToTitle(communityId);

    return GestureDetector(
      onTap: () {
        // Handle the tap action for the community card
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CommunityPostScreen(communityTitle: communityTitle, communityId: communityId,)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, left: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: mapCommunityIdToImageUrl(communityId),
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black54,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Add padding to the text
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      communityTitle, // Use the mapped title here
                      style: const TextStyle(
                        fontSize: 18, // Increase font size
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.justify, // Set text alignment to justify
                    ),
                    const SizedBox(height: 6), // Add spacing between title and description
                    Text(
                      mapCommunityIdToDesciption(communityId), // Use the provided description here
                      style: const TextStyle(
                        fontSize: 14, // Increase font size
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center, // Set text alignment to justify
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



//Category Card
class CategoryCard extends StatelessWidget {
  final imageUrl;
  final categoryTitle;

  const CategoryCard(
      {Key? key, required this.imageUrl, required this.categoryTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CategoryNewsScreen(categoryTitle: categoryTitle)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, left: 6),
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 120,
                  height: 60,
                  fit: BoxFit.cover,
                )),
            Container(
              alignment: Alignment.center,
              width: 120,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black54),
              child: Text(
                categoryTitle,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}


