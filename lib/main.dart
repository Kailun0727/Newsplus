import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/views/CustomProfileScreen.dart';
import 'package:newsplus/firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:newsplus/views/home_page.dart';

import 'package:firebase_database/firebase_database.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  print('Connected to firebase');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final user = snapshot.data;
            if (user == null) {
              // User is not authenticated, navigate to sign-in
              return SignInScreen(
                providers: providers,
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }),

                  AuthStateChangeAction<UserCreated>((context, state) async{
                    // User registration is successful
                      print("Register is success, above");

                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {
                        print("User is not null");

                        String name = user.email!.split("@")[0];

                        await user.updateDisplayName(name); // Await the update

                        print(name);

                        final userData = {
                          'username': name,
                          'email': user.email ?? '',
                          'registrationDate': DateTime.now().toUtc().toString(),
                          'preferredLanguage' : 'English',
                          // Add more fields as needed
                        };

                        // Store the user data in the Realtime Database
                        DatabaseReference ref = FirebaseDatabase.instance.ref("user/"+user.uid);

                        await ref.set(userData);

                        print("Added user to database");
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Registration successful! You can now sign in.'),
                      ),
                    );
                    // Navigate to the home page
                    Navigator.pushReplacementNamed(context, '/home');
                  }),

                ],
              );
            } else {
              // User is authenticated, navigate to home
              return const HomePage();
            }
          }
          return CircularProgressIndicator(); // Loading state
        },
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue, // Change this to your desired primary color
        brightness: Brightness.light,
        visualDensity: VisualDensity.standard,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(8),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(8),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
      routes: {
        '/sign-in': (context) {
          return SignInScreen(
            providers: providers,
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.pushReplacementNamed(context, '/home');
              }),

              AuthStateChangeAction<UserCreated>((context, state) async{
                // User registration is successful
                print("Register is success, below");

                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  print("User is not null");

                  String name = user.email!.split("@")[0];

                  await user.updateDisplayName(name); // Await the update

                  print(name);

                  final userData = {
                    'username': name,
                    'email': user.email ?? '',
                    'registrationDate': DateTime.now().toUtc().toString(),
                    'preferredLanguage' : 'English',
                    // Add more fields as needed
                  };

                  // Store the user data in the Realtime Database
                  DatabaseReference ref = FirebaseDatabase.instance.ref("user/"+user.uid);

                  await ref.set(userData);

                  print("Added user to database");
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Registration successful! You can now sign in.'),
                  ),
                );
                // Navigate to the home page
                Navigator.pushReplacementNamed(context, '/home');
              }),


            ],
          );
        },
        '/home': (context) => const HomePage(),
        '/profile': (context) => const CustomProfileScreen(),
      },
    );
  }
}


