import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/helper/languageMapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleScreen extends StatefulWidget {

  final String languageCode;

  String url;

  // Named constructor that takes a parameter
  ArticleScreen({Key? key, required this.url, required this.languageCode}) : super(key: key);

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late InAppWebViewController _webViewController;

  bool _isLoading = true; // Add this variable

  String transformUrl(String inputUrl){
    // Split the input URL by '/'
    List<String> urlParts = inputUrl.split('/');

    if (urlParts.length >= 4) {
      // Replace '.' with '-' in the part before ".translate.goog"
      String domainPart = urlParts[2].replaceAll('.', '-');

      // Reconstruct the URL with ".translate.goog" inserted before the third '/'
      String transformedUrl = 'https://${domainPart}.translate.goog';

      // Append the remaining parts of the URL
      for (int i = 3; i < urlParts.length; i++) {
        transformedUrl += '/${urlParts[i]}';
      }



      if (transformedUrl.contains('?')) {
        // The transformedUrl contains the '?' symbol
        return transformedUrl +
            '&_x_tr_sl=auto&_x_tr_tl='+ widget.languageCode  +'&_x_tr_hl=en-US&_x_tr_pto=wapp';
      } else {
        // The transformedUrl does not contain the '?' symbol
        return transformedUrl +
            '?_x_tr_sl=auto&_x_tr_tl='+ widget.languageCode  +'&_x_tr_hl=en-US&_x_tr_pto=wapp';
      }


    } else {
      // If the URL doesn't have at least 4 parts, return it as is
      return inputUrl;
    }
  }

  String extractUrlFromText(String text) {
    // Define a regular expression pattern to match "Google NewsOpening" and capture the URL
    final pattern = RegExp(r'Google NewsOpening (.+?) ');

    // Search for the pattern in the text
    final match = pattern.firstMatch(text);

    if (match != null) {
      // Extract the captured URL (group 1)
      final url = match.group(1);

      if (url != null) {
        // Remove any leading and trailing whitespaces
        return url.trim();
      }
    }

    // Return an empty string if no URL is found
    return '';
  }

  final FlutterTts flutterTts = FlutterTts(); // Define flutterTts at the class level



  Future<void> initTts(String languageCode) async {
    await flutterTts.setLanguage(languageCode); // Set the initial language (you can change this)

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? preferLanguage = prefs.getString('prefer_language') ?? 'English';
    // if (preferLanguage != null) {
    //   String? languageCode = LanguageMapper.getLanguageCode(preferLanguage);
    //
    //
    // }

  }

   Future<void> speakContent(String content) async {
    await flutterTts.speak(content);
  }

  List<String> splitTextIntoChunks(String text, {int maxChunkLength = 400}) {
    List<String> chunks = [];
    int textLength = text.length;
    for (int i = 0; i < textLength; i += maxChunkLength) {
      int end = i + maxChunkLength;
      if (end > textLength) {
        end = textLength; // Ensure we don't go beyond the text length
      }
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }




  @override
  void dispose() async{

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize TTS engine
    initTts(widget.languageCode);
  }




  @override
  Widget build(BuildContext context) {

    bool isTtsPaused = false; // Initially, TTS is not paused

    return Scaffold(

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_summary",
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? preferLanguage = prefs.getString('prefer_language') ?? 'English';


              if (preferLanguage != null) {


                String extractedText = await NewsController.extractText(widget.url);

                String summary = await NewsController.summarizeNews(extractedText);

                String? languageCode = LanguageMapper.getLanguageCode(preferLanguage);

                String translation = await NewsController.translateText(summary, languageCode!);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Summary"),
                      content: SingleChildScrollView(
                        child: (extractedText == "Extract failed"
                            ? Text("This site does not support summarization")
                            : Text(translation)),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Icon(Icons.add),
          ),

          SizedBox(height: 20,),

          FloatingActionButton(
              onPressed: () async {
                String extractedText = await NewsController.extractText(widget.url);

                // Split the extracted text into sentences
                List<String> sentences = extractedText.split('. '); // Split by sentences (you might need a more robust sentence splitting logic)

                // Define a function to speak each sentence with completion await
                Future<void> speakWithCompletion(int index) async {
                  if (index < sentences.length) {
                    // Speak the current sentence
                    await flutterTts.speak(sentences[index]);

                    // Wait for the TTS to complete speaking the current sentence
                    await flutterTts.awaitSpeakCompletion(true);

                    // Move to the next sentence
                    await speakWithCompletion(index + 1);
                  }
                }

                // Start speaking sentences from the beginning
                await speakWithCompletion(0);
              },


              child: Icon(Icons.volume_up), // You can use a speaker icon or any other appropriate icon
            tooltip: "Read Content",
          )

        ],
      ),



        appBar: AppBar(
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
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Plus",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/profile',
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          InAppWebView(
            shouldOverrideUrlLoading:
                (controller, navigationAction) async {

              return NavigationActionPolicy.ALLOW;
            },

            initialUrlRequest:
            URLRequest(url: Uri.parse(transformUrl(widget.url))),

            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                useWideViewPort: true,
                useOnRenderProcessGone: true,


              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),



            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },

            onLoadError: (controller, url, code, message) {
              print("Error loading web page: $message");
              // Handle the error here or take appropriate action
            },

            onLoadStart: (controller, url) {
              // print("Current URL :" + widget.url);
              // Intercept the URL and set it as the current URL
              setState(() {
                _isLoading = true; // Start loading
              });

              print("On Load Start : " + widget.url);

            },
            onLoadStop: (controller, url) {

              setState(() {
                _isLoading = false; // Stop loading
              });

              print("On Load Stop : " + widget.url);
            },
          ),


          if (_isLoading)
            Center(
              child: CircularProgressIndicator(), // Show a loading indicator
            ),
        ],
      ),
    );
  }
}
