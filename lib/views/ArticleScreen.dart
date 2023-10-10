import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/helper/languageMapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ArticleScreen extends StatefulWidget {
  final String languageCode;

  String url;

  // Named constructor that takes a parameter
  ArticleScreen({Key? key, required this.url, required this.languageCode})
      : super(key: key);

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late InAppWebViewController _webViewController;

  bool _isLoading = true; // Add this variable

  StreamController<bool> shouldPlayStream = StreamController<bool>();

  String transformUrl(String inputUrl) {
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
            '&_x_tr_sl=auto&_x_tr_tl=' +
            widget.languageCode +
            '&_x_tr_hl=en-US&_x_tr_pto=wapp';
      } else {
        // The transformedUrl does not contain the '?' symbol
        return transformedUrl +
            '?_x_tr_sl=auto&_x_tr_tl=' +
            widget.languageCode +
            '&_x_tr_hl=en-US&_x_tr_pto=wapp';
      }
    } else {
      // If the URL doesn't have at least 4 parts, return it as is
      return inputUrl;
    }
  }

  final FlutterTts flutterTts =
      FlutterTts(); // Define flutterTts at the class level

  Future<void> initTts(String languageCode) async {
    await flutterTts.setLanguage(languageCode); // Set the initial language
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
  void dispose() async {
    super.dispose();
    stopSpeaking();
    await flutterTts.stop();

  }

  @override
  void initState() {
    super.initState();
    // Initialize TTS engine
    initTts(widget.languageCode);
  }

  bool shouldContinue = true;

  void stopSpeaking() {
    shouldContinue = false;
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_summary",
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? preferLanguage =
                  prefs.getString('prefer_language') ?? 'English';
              if (preferLanguage != null) {
                // String extractedText = await NewsController.extractTextAPI(widget.url);
                String extractedText =
                    await NewsController.extractText(widget.url);

                String summary =
                    await NewsController.summarizeNews(extractedText);

                String? languageCode =
                    LanguageMapper.getLanguageCode(preferLanguage);

                String translation = await NewsController.translate(
                    summary, languageCode!.toLowerCase());

                FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                analytics.setAnalyticsCollectionEnabled(true);

                await analytics.logEvent(
                  name: 'summary_news',
                  parameters: <String, dynamic>{
                    'summary': 'true',
                  },
                );


                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.summary),
                      content: SingleChildScrollView(
                        child: (extractedText == "Extract failed"
                            ? Text("This site does not support summarization")
                            : Text(translation)),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.cancelButtonText),
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
            child: Icon(Icons.description),
          ),
          SizedBox(
            height: 20,
          ),

          FloatingActionButton(
            heroTag: "btn_speak",
            onPressed: () async {

              shouldContinue = true; //

              shouldPlayStream?.add(true);

              String extractedText = await NewsController.extractText(widget.url);
              List<String> sentences = extractedText.split('. ');

              for (int index = 0; index < sentences.length; index++) {
                if (!shouldContinue) {
                  break;
                }

                String translate = await NewsController.translate(sentences[index],widget.languageCode.toLowerCase());

                await flutterTts.speak(translate);
                await flutterTts.awaitSpeakCompletion(true);
              }
            },
            child: Icon(Icons.volume_up),
            tooltip: "Read Content",
          ),

          SizedBox(
            height: 20,
          ),

          FloatingActionButton(
            heroTag: "btn_pause",
            onPressed: () async {
              await flutterTts.stop();
              shouldPlayStream?.add(false);
              stopSpeaking();

              FirebaseAnalytics analytics = FirebaseAnalytics.instance;

              analytics.setAnalyticsCollectionEnabled(true);

              await analytics.logEvent(
                name: 'pause_tts',
                parameters: <String, dynamic>{
                  'pause': 'true',
                },
              );

            },
            child: Icon(Icons.pause),
            tooltip: "Pause",
          ),



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
            shouldOverrideUrlLoading: (controller, navigationAction) async {
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

              print("On Load Start ");
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false; // Stop loading
              });

              print("On Load Stop");
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
