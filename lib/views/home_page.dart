import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:newsplus/widgets/components.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsplus'),
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const Header("Welcome to Newsplus!"),


          // Add a button to navigate to the '/profile' page
          ElevatedButton(
            onPressed: () {
              // Navigate to the '/profile' page
              Navigator.pushNamed(context, '/profile');
            },
            child: Text('Go to Profile'),
          ),
        ],
      ),
    );
  }
}
