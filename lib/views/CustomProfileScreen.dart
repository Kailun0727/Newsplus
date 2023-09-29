import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:newsplus/controllers/profileController.dart';
import 'package:newsplus/main.dart';
import 'package:newsplus/views/UserPost.dart';
import 'package:newsplus/widgets/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomProfileScreen extends StatefulWidget {
  const CustomProfileScreen({Key? key});

  @override
  _CustomProfileScreenState createState() => _CustomProfileScreenState();
}

class _CustomProfileScreenState extends State<CustomProfileScreen> {
  File? selectedImage;

  bool isEditingUsername = false;
  bool isEditingPassword = false;
  bool isEditingEmail = false;


  final ProfileController profileController = ProfileController();

  // Declare TextEditingController variables for username, password, and email editing
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

// Create lists for dropdown menus (preferred language and country/region)
  final List<String> supportedLanguages = ['English', 'Chinese', 'Malay'];
  final List<String> displayLanguages = ['English', 'Chinese', 'Malay'];

// Initialize variables to store user preferences for language and country
  String selectedLanguage = 'English';
  String selectedDisplayLanguage = 'English';

  // Define a method to load the initial language values from SharedPreferences.
  Future<void> loadInitialLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('prefer_language') ?? 'English';
      selectedDisplayLanguage = prefs.getString('display_language') ?? 'English';
    });
  }



  @override
  void initState() {
    super.initState();
    loadInitialLanguage();
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

    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 8),
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
                                final updatedUser =
                                    FirebaseAuth.instance.currentUser;
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
                      user?.photoURL ??
                          'https://t4.ftcdn.net/jpg/03/32/59/65/360_F_332596535_lAdLhf6KzbW6PWXBWeIFTovTii1drkbT.jpg', // Add a user profile image if available
                      // Add a user profile image if available
                    ),
                  ),
                ),


                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Display Username (Editable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0), // Add padding
                      child: ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: isEditingUsername
                            ? Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue, // Color when not editing
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green, // Color when editing
                                ),
                              ),
                              hintText: AppLocalizations.of(context)!.usernameHintText, // Add hint text
                            ),
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            isEditingUsername ? '' : (name ?? ''),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: isEditingUsername
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check, // Checkmark icon
                                color: Colors.green, // Color for the checkmark icon
                              ),
                              onPressed: () async {

                                bool updateSuccess = await profileController.updateUsername(usernameController.text.toString());

                                if (updateSuccess) {
                                  // Email update was successful
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.updateSuccess),
                                      // You can customize the appearance and duration of the SnackBar as needed
                                    ),
                                  );
                                } else {


                                  // Email update failed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.usernameUpdateFailed),
                                      // You can customize the appearance and duration of the SnackBar as needed
                                    ),
                                  );
                                }

                                setState(() {
                                  isEditingUsername = false; // Disable edit mode
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close, // Close icon
                                color: Colors.red, // Color for the close icon
                              ),
                              onPressed: () {
                                setState(() {
                                  isEditingUsername = false; // Disable edit mode
                                });
                              },
                            ),
                          ],
                        )
                            : IconButton(
                          icon: const Icon(
                            Icons.edit, // Edit icon
                            color: Colors.blue, // Color for the edit icon
                          ),
                          onPressed: () {
                            setState(() {
                              isEditingUsername = true; // Enable edit mode
                            });
                          },
                        ),
                      ),
                    ),


                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0), // Add padding
                      child: ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.password,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: isEditingPassword
                            ? Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue, // Color when not editing
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green, // Color when editing
                                ),
                              ),

                              hintText: AppLocalizations.of(context)!.passwordHintText, // Add hint text
                            ),
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            isEditingPassword ? '' : ("********"),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: isEditingPassword
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check, // Checkmark icon
                                color: Colors.green, // Color for the checkmark icon
                              ),
                              onPressed: () async {

                                bool updateSuccess = await profileController.updatePassword(passwordController.text.toString());

                                if (updateSuccess) {
                                  // Email update was successful
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.updateSuccess),
                                      // You can customize the appearance and duration of the SnackBar as needed
                                    ),
                                  );
                                } else {
                                  // Email update failed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.passwordUpdateFailed),
                                      // You can customize the appearance and duration of the SnackBar as needed
                                    ),
                                  );
                                }

                                setState(() {
                                  isEditingPassword = false; // Disable edit mode
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close, // Close icon
                                color: Colors.red, // Color for the close icon
                              ),
                              onPressed: () {
                                setState(() {
                                  isEditingPassword = false; // Disable edit mode
                                });
                              },
                            ),
                          ],
                        )
                            : IconButton(
                          icon: const Icon(
                            Icons.edit, // Edit icon
                            color: Colors.blue, // Color for the edit icon
                          ),
                          onPressed: () {
                            setState(() {
                              isEditingPassword = true; // Enable edit mode
                            });
                          },
                        ),
                      ),
                    ),

                    // Display Email (Editable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.email,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: isEditingEmail
                            ? Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue, // Color when not editing
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green, // Color when editing
                                ),
                              ),
                              hintText: AppLocalizations.of(context)!.emailHintText, // Add hint text
                            ),
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            isEditingEmail ? '' : (email ?? ''),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: isEditingEmail
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check, // Checkmark icon
                                color: Colors.green, // Color for the checkmark icon
                              ),
                              onPressed: () async {
                                // Save changes
                                bool updateSuccess = await profileController.updateEmail(emailController.text.toString());

                                if (updateSuccess) {
                                  // Email update was successful
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.updateSuccess),
                                      // You can customize the appearance and duration of the SnackBar as needed
                                    ),
                                  );
                                } else {
                                  // Email update failed
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.emailUpdateFailed),
                                      // You can customize the appearance and duration of the SnackBar as needed
                                    ),
                                  );
                                }


                                setState(() {
                                  isEditingEmail = false; // Disable edit mode
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close, // Close icon
                                color: Colors.red, // Color for the close icon
                              ),
                              onPressed: () {
                                setState(() {
                                  isEditingEmail = false; // Disable edit mode
                                });
                              },
                            ),
                          ],
                        )
                            : IconButton(
                          icon: const Icon(
                            Icons.edit, // Edit icon
                            color: Colors.blue, // Color for the edit icon
                          ),
                          onPressed: () {
                            setState(() {
                              isEditingEmail = true; // Enable edit mode
                            });
                          },
                        ),
                      ),
                    ),

                    // Preferred Language Dropdown
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.translateNewsTo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8,),

                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: DropdownButton<String>(



                                value: selectedLanguage,
                                onChanged: (String? newValue) async {

                                  setState(() {
                                    selectedLanguage = newValue!;
                                  });

                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('prefer_language', selectedLanguage.toString());
                                },
                                items: supportedLanguages
                                    .map<DropdownMenuItem<String>>((String language) {
                                  return DropdownMenuItem<String>(
                                    value: language,
                                    child: Text(language, style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),),

                                  );
                                }).toList(),
                                icon: const Icon(Icons.arrow_drop_down),
                                underline: const SizedBox(), // Remove the default underline
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8,),

                    // Country Dropdown
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.displayLanguage,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8,),


                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: DropdownButton<String>(

                                value: selectedDisplayLanguage,
                                onChanged: (String? newValue) async{
                                  setState(() {
                                    selectedDisplayLanguage = newValue!;
                                  });

                                  profileController.setAppLocale(context, selectedDisplayLanguage);

                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('display_language', selectedDisplayLanguage.toString());
                                },
                                items: displayLanguages
                                    .map<DropdownMenuItem<String>>((String country) {
                                  return DropdownMenuItem<String>(
                                    value: country,
                                    child: Text(country, style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),),

                                  );
                                }).toList(),
                                icon: const Icon(Icons.arrow_drop_down),
                                underline: const SizedBox(), // Remove the default underline
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top : 16, left:16,right:16),
                      child: Container(
                        width: double
                            .infinity, // Makes the button as wide as the parent container
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UserPost()),
                            );
                          },
                          child: Text(AppLocalizations.of(context)!.managePost),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show an alert dialog for confirmation
                            bool confirmSignOut = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(AppLocalizations.of(context)!.confirmSignOutTitle),
                                  content: Text(AppLocalizations.of(context)!.confirmSignOutHintText),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(AppLocalizations.of(context)!.cancelButtonText),
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // Return false to cancel
                                      },
                                    ),
                                    TextButton(
                                      child: Text(AppLocalizations.of(context)!.signOut),
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // Return true to confirm
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            // If the user confirmed, sign out
                            if (confirmSignOut == true) {
                              try {
                                await FirebaseAuth.instance.signOut();
                                print("Successfully sign out");
                                Navigator.pushReplacementNamed(context, '/sign-in');
                              } catch (e) {
                                // Handle sign-out error
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Set the background color to red
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.signOut,
                            style: TextStyle(color: Colors.white), // Set the text color to white
                          ),
                        ),
                      ),
                    )



                  ],)



              ],
            ),
          ),
        ),
      ),
    );
  }
}
