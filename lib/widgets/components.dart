// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/views/ArticleScreen.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


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
      selectedLabelStyle: TextStyle(color: Colors.blue),
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      currentIndex: widget.selectedIndex,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Saved News',
        ),
      ],
      onTap: (index) {
        widget.onItemSelected(index);
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/profile');
            break;
          case 2:
            Navigator.pushNamed(context, '/profile');
            break;
          default:
        }
      },
    );
  }
}



//News Card
class NewsCard extends StatelessWidget {
  final imageUrl;
  final title;
  final description;
  final url;
  final publishedAt;




  const NewsCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.publishedAt,
    required this.url
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()  {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleScreen(url: url), // Pass the URL to ArticleScreen
          ),
        );
      },
      child: Container(
        child: Container(
          margin: EdgeInsets.only(bottom: 14),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left side)
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 500,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 6,),
                      Text(
                        publishedAt,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 6,),
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6,),
                      Text(
                        description,
                        style: TextStyle(color: Colors.black54),
                      ),

                    ],
                  ),
                  Positioned(
                    top: 8, // Adjust the top position as needed
                    right: 1, // Adjust the right position as needed
                    child: Container(

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue, // Change to your desired color
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.more_vert, // You can replace this with your kebab menu icon
                          size: 24, // Adjust the icon size as needed
                          color: Colors.white, // Change to your desired icon color
                        ),
                        onPressed: () {
                          // Implement the action when the kebab menu is clicked
                        },
                      ),
                      width: 42, // Adjust the width to make the circle smaller
                      height: 42, // Adjust the height to make the circle smaller
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
      onTap: () {},
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
                  color: Colors.black26),
              child: Text(
                categoryTitle,
                style: const TextStyle(
                    fontSize: 12,
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

class Header extends StatelessWidget {
  const Header(this.heading, {super.key});
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class Paragraph extends StatelessWidget {
  const Paragraph(this.content, {super.key});
  final String content;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          content,
          style: const TextStyle(fontSize: 18),
        ),
      );
}

class IconAndDetail extends StatelessWidget {
  const IconAndDetail(this.icon, this.detail, {super.key});
  final IconData icon;
  final String detail;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              detail,
              style: const TextStyle(fontSize: 18),
            )
          ],
        ),
      );
}

class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed, super.key});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepPurple)),
        onPressed: onPressed,
        child: child,
      );
}
