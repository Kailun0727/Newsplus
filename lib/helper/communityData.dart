import 'package:newsplus/models/CommunityModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<List<CommunityModel>> getCommunity() async {
  List<CommunityModel> mCommunity = [];

  final DatabaseReference communityRef =
  FirebaseDatabase.instance.ref().child("community");

  try {
    // Create a query to retrieve community data
    Query query = communityRef;

    // Retrieve data once from the database
    DatabaseEvent event = await query.once();

    // Check if the snapshot contains data
    if (event.snapshot != null) {
      // Get the value of the snapshot
      final dynamic communityMap = event.snapshot!.value;

      // Check if the retrieved data is a Map
      if (communityMap is Map) {
        // Clear the list before adding fetched items
        mCommunity.clear();

        // Iterate through each key-value pair in the Map
        communityMap.forEach((key, communityData) {
          // Convert the data to a CommunityModel
          CommunityModel community = CommunityModel(
            communityId: communityData['communityId'],
            description: communityData['description'],
          );

          // Add the converted CommunityModel to the mCommunity list
          mCommunity.add(community);
        });

        // Sort the mCommunity list if needed
        // For example, to sort by communityId:
        mCommunity.sort((a, b) => a.communityId.compareTo(b.communityId));
      }
    }

    return mCommunity; // Return the populated mCommunity list
  } catch (error) {
    // Handle any errors that occur during the process
    print('Error fetching community data: $error');
    throw error;
  }
}



