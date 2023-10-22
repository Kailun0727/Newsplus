
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:newsplus/main.dart';

class ProfileController extends ChangeNotifier {


  Future<bool> updatePassword(String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (password.isNotEmpty && isValidPassword(password)) {
          await user.updatePassword(password);
          // Password update was successful
          return true;
        } else {
          // Invalid password format or empty
          return false;
        }
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
        if (username.isNotEmpty && isValidUsername(username)) {
          await user.updateDisplayName(username);
          // Username update was successful
          return true;
        } else {
          // Invalid username format or empty
          return false;
        }
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
        if (email.isNotEmpty && isValidEmail(email)) {
          await user.updateEmail(email);
          // Email update was successful
          return true;
        } else {
          // Invalid email format or empty
          return false;
        }
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

  bool isValidUsername(String username) {
    // Minimum length of 3 characters, maximum length of 20 characters
    return username.length >= 3 && username.length <= 20;
  }

  bool isValidPassword(String password) {
    return password.length >= 6; //Minimum length of 6 characters
  }

  bool isValidEmail(String email) {
    // Regular expression to match a valid email format
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
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