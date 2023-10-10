
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsplus/controllers/replyController.dart';
import 'package:newsplus/l10n/l10n.dart';

import 'package:intl/intl.dart';
import 'package:newsplus/controllers/newsController.dart';
import 'package:newsplus/controllers/postController.dart';
import 'package:newsplus/controllers/savedNewsController.dart';


import 'package:newsplus/views/ArticleScreen.dart';
import 'package:newsplus/views/CommunityScreen.dart';
import 'package:newsplus/views/CustomProfileScreen.dart';
import 'package:newsplus/firebase_options.dart';
import 'package:newsplus/views/SavedNewsScreen.dart';
import 'package:newsplus/views/home_page.dart';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      name: 'newsplus',
      options: DefaultFirebaseOptions.currentPlatform
  );

  print('Connected to firebase');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => PostController()),
        ChangeNotifierProvider(create: (_) => SavedNewsController()),
        ChangeNotifierProvider(create: (_) => ReplyController()),
        // Add other providers if needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  const MyApp({Key? key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = Locale('en');


  // Define a method to load the initial language from SharedPreferences.
  Future<void> loadInitialLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? initialLanguage = prefs.getString('display_language');

    if (initialLanguage != null) {


      switch (initialLanguage) {
        case 'English':
          changeLanguage(Locale('en'));
          break;
        case 'Chinese':
          changeLanguage(Locale('zh'));
          break;
        case 'Malay':
          changeLanguage(Locale('ms'));
          break;
        default:
          changeLanguage(Locale('en'));
          break;
      }


    }
  }

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadInitialLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final providers = [EmailAuthProvider()];



    return MaterialApp(

      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: L10n.all,

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
                  AuthStateChangeAction<SignedIn>((context, state) async {
                    try {
                      if(mounted){
                        Navigator.pushReplacementNamed(context, '/home');

                        FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                        await analytics.logEvent(
                          name: 'login',
                          parameters: <String, dynamic>{
                            'user_login': 'true',
                          },
                        );
                      }
                    } catch (e) {
                      // Handle login error and display a message to the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid email or password"),
                        ),
                      );
                      print("Login error: $e");
                    }
                  }),

                  AuthStateChangeAction<UserCreated>((context, state) async{
                      final user = FirebaseAuth.instance.currentUser;

                      if (user != null) {

                        String name = user.email!.split("@")[0];

                        await user.updateDisplayName(name); // Await the update

                        final userData = {
                          'username': name,
                          'email': user.email ?? '',
                          'registrationDate': DateTime.now().add(Duration(hours: 8)).toString(),
                        };

                        DatabaseReference ref = FirebaseDatabase.instance.ref("user/"+user.uid);

                        await ref.set(userData);
                      }

                      // Navigate to the home page
                      if(mounted){
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                  }),

                ],
              );
            } else {
              // User is authenticated, navigate to home
              return Builder(
                builder: (BuildContext context) {
                  // Use Builder to create a new context
                  final user = FirebaseAuth.instance.currentUser;
                  user!.reload();
                  return const HomePage();
                },
              );

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
              AuthStateChangeAction<SignedIn>((context, state) async {
                try {

                  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                  final user = FirebaseAuth.instance.currentUser;

                  if(user!=null){
                    await analytics.logEvent(
                      name: 'login',
                      parameters: <String, dynamic>{
                        'user_login': user.email,
                      },
                    );

                    if(mounted){
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }


                } catch (e) {
                  // Handle login error and display a message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Invalid email or password"), // Customize the message as needed
                    ),
                  );

                  print("Login error: $e");
                }
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
                    'registrationDate': DateTime.now().add(Duration(hours: 8)).toString(),
                    'preferredLanguage' : 'English',
                    // Add more fields as needed
                  };

                  // Store the user data in the Realtime Database
                  DatabaseReference ref = FirebaseDatabase.instance.ref("user/"+user.uid);

                  await ref.set(userData);

                  print("Added user to database");
                }

                // Navigate to the home page

                if(mounted){
                  Navigator.pushReplacementNamed(context, '/home');

                }
              }),


            ],
          );
        },
        '/home': (context) => const HomePage(),
        '/profile': (context) => const CustomProfileScreen(),
        '/savedNews' : (context) => const SavedNewsScreen(),
        '/community' : (context) => const CommunityScreen(),

      },
    );
  }
}


