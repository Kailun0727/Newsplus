import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ArticleScreen extends StatefulWidget {
  final String url;

  // Named constructor that takes a parameter
  const ArticleScreen({Key? key, required this.url}) : super(key: key);

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late InAppWebViewController _webViewController;

  bool _isLoading = true; // Add this variable

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
            '&_x_tr_sl=auto&_x_tr_tl=zh-CN&_x_tr_hl=en-US&_x_tr_pto=wapp';
      } else {
        // The transformedUrl does not contain the '?' symbol
        return transformedUrl +
            '?_x_tr_sl=auto&_x_tr_tl=zh-CN&_x_tr_hl=en-US&_x_tr_pto=wapp';
      }


    } else {
      // If the URL doesn't have at least 4 parts, return it as is
      return inputUrl;
    }
  }

  @override
  void dispose() async{

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              print("Current Transform URL :" + transformUrl(widget.url));
              setState(() {
                _isLoading = true; // Start loading
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false; // Stop loading
              });
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
