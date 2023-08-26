import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:newsplus/widgets/components.dart';


class CustomProfileScreen extends StatelessWidget {
  const CustomProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String? name;
    String? email;

    if (user != null) {
      // Name, email address
      name = user.displayName;
      email = user.email;

      print("Profile screen Username:"+ name.toString());
      print("Profile screen Email:"+ email.toString());

    }



    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsplus'),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 8),
          const Header("Profile Screen"),

          Text("Hello "+ name.toString()),
          Text("Email : "+ email.toString()),

          // Add a button to navigate to the '/home' page
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Text('Go to Home'),
          ),

          // Add a button to sign out
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // After signing out, navigate to a desired page (e.g., login screen)
                print('Sign out');
                Navigator.pushReplacementNamed(context, '/sign-in');
              } catch (e) {
                print('Sign Out Error: $e');
                // Handle sign-out error if necessary
              }
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
