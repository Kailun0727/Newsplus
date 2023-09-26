import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsplus/widgets/components.dart';

class CustomProfileScreen extends StatefulWidget {
  const CustomProfileScreen({Key? key});

  @override
  _CustomProfileScreenState createState() => _CustomProfileScreenState();
}

class _CustomProfileScreenState extends State<CustomProfileScreen> {

  File? selectedImage;

  bool isEditing = false; // Track if the user is in edit mode

  // Declare TextEditingController variables for username and email editing
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

// Create lists for dropdown menus (preferred language and country/region)
  final List<String> supportedLanguages = ['English', 'Spanish', 'French'];
  final List<String> countries = ['USA', 'Canada', 'UK'];

// Initialize variables to store user preferences for language and country
  String selectedLanguage = 'English';
  String selectedCountry = 'USA';

// Function to update user profile
  Future<void> updateUserProfile(String username, String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update username and email
        await user?.updateDisplayName(username);
        await user?.updateEmail(email);

        setState(() {

        });
        // Update preferred language and country/region
        // You can save these preferences in Firebase or your app's storage
      }
    } catch (error) {
      // Handle any errors
      print('Error updating profile: $error');
    }
  }

// Function to delete the user's account
  Future<void> deleteUserAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete the user's account
        await user.delete();
        // After deleting the account, you can navigate to a sign-in or registration screen
        Navigator.pushReplacementNamed(context, '/sign-in');
      }
    } catch (error) {
      // Handle any errors
      print('Error deleting account: $error');
    }
  }

  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;
    String? name;
    String? email;

    if (user != null) {
      // Name, email address
      name = user.displayName;
      email = user.email;

      //set default value for controller
      usernameController.text = name ?? "";
      emailController.text = email ?? "";

      print("Profile screen Username:"+ name.toString());
      print("Profile screen Email:"+ email.toString());

    }




    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomImagePickerDialog(
                        onImageSelected: (image) async {
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await user.updatePhotoURL(image);
                              // Refresh the user object to reflect the changes
                              await user.reload();
                              final updatedUser = FirebaseAuth.instance.currentUser;
                              if (updatedUser != null) {
                                setState(() {
                                  // Update the UI to reflect the new photoURL
                                  // You can also update the user's photoURL variable here if you're using a state management solution like Provider.
                                });
                              }
                            }
                          } catch (error) {
                            // Handle any errors that occur during the update
                            print('Error updating photoURL: $error');
                          }
                        },
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: CachedNetworkImageProvider(
                    user?.photoURL ?? 'https://t4.ftcdn.net/jpg/03/32/59/65/360_F_332596535_lAdLhf6KzbW6PWXBWeIFTovTii1drkbT.jpg', // Add a user profile image if available
                  // Add a user profile image if available
                  ),
                ),
              ),

              // Display Username (Editable)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Add padding
                child: ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: isEditing
                      ? TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue, // Color when not editing
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green, // Color when editing
                        ),
                      ),
                    ),
                  )
                      : Text(
                    isEditing ? '' : (name ?? ''),
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: isEditing
                      ? IconButton(
                    icon: Icon(
                      Icons.check, // Checkmark icon
                      color: Colors.green, // Color for the checkmark icon
                    ),
                    onPressed: () {
                      setState(() {
                        updateUserProfile(
                            usernameController.text.toString(),
                            emailController.text.toString());
                        // Save changes
                        isEditing = false; // Disable edit mode
                      });
                    },
                  )
                      : IconButton(
                    icon: Icon(
                      Icons.edit, // Edit icon
                      color: Colors.blue, // Color for the edit icon
                    ),
                    onPressed: () {
                      setState(() {
                        isEditing = true; // Enable edit mode
                      });
                    },
                  ),
                ),
              ),

// Display Email (Editable)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Add padding
                child: ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.email,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: isEditing
                      ? TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue, // Color when not editing
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.green, // Color when editing
                        ),
                      ),
                    ),
                  )
                      : Text(
                    isEditing ? '' : (email ?? ''),
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: isEditing
                      ? IconButton(
                    icon: Icon(
                      Icons.check, // Checkmark icon
                      color: Colors.green, // Color for the checkmark icon
                    ),
                    onPressed: () {
                      setState(() {
                        updateUserProfile(
                            usernameController.text.toString(),
                            emailController.text.toString());
                        // Save changes
                        isEditing = false; // Disable edit mode
                      });
                    },
                  )
                      : IconButton(
                    icon: Icon(
                      Icons.edit, // Edit icon
                      color: Colors.blue, // Color for the edit icon
                    ),
                    onPressed: () {
                      setState(() {
                        isEditing = true; // Enable edit mode
                      });
                    },
                  ),
                ),
              ),

// Preferred Language Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferred Translate Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedLanguage, // The selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLanguage = newValue!;
                      });
                    },
                    items: supportedLanguages.map<DropdownMenuItem<String>>((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                  ),
                ],
              ),

// Country/Region Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Country',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedCountry, // The selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCountry = newValue!;
                      });
                    },
                    items: countries.map<DropdownMenuItem<String>>((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                  ),
                ],
              ),




              Container(
                width: double.infinity, // Makes the button as wide as the parent container
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/sign-in');
                    } catch (e) {
                      // Handle sign-out error if necessary
                    }
                  },
                  child: Text('Sign Out'),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
