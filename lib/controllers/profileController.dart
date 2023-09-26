


import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/main.dart';

class ProfileController extends ChangeNotifier {


  Future<bool> updatePassword(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(password);
        // Password update was successful
        return true;
      } else {
        // User is null, meaning no user is signed in
        return false;
      }
    } catch (error) {
      // Handle any errors
      print('Error updating password: $error');
      // Password update failed
      return false;
    }
  }


  Future<bool> updateUsername(String username) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(username);
        // Username update was successful
        return true;
      } else {
        // User is null, meaning no user is signed in
        return false;
      }
    } catch (error) {
      // Handle any errors
      print('Error updating username: $error');
      // Username update failed
      return false;
    }
  }


  Future<bool> updateEmail(String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateEmail(email);
        // Email update was successful
        return true;
      } else {
        // User is null, meaning no user is signed in
        return false;
      }
    } catch (error) {
      // Handle any errors
      print('Error updating email: $error');
      // Email update failed
      return false;
    }
  }

  void setAppLocale(BuildContext context,String displayLanguage) {
    // Map the display language to the corresponding Locale
    switch (displayLanguage) {
      case 'English':

        MyApp.setLocale(context, Locale('en'));

        break;
      case 'Chinese':
        MyApp.setLocale(context, Locale('zh'));
        break;
      case 'Malay':
        MyApp.setLocale(context, Locale('ms'));
        break;
      default:
        MyApp.setLocale(context, Locale('en'));
        break;
    }

  }


}