// lib/database/firestore_helper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini001/models/farmer.dart';

// FirestoreHelper is a helper class that encapsulates all the Firestore logic
// for our application, making it easier to manage data and separate concerns.

class FirestoreHelper {                                                                   
  
  static final FirestoreHelper _instance = FirestoreHelper._internal();                       // We create a private static instance of the class to implement the Singleton pattern.
                                                                                              // This ensures that we only have one instance of FirestoreHelper throughout the app.  
  factory FirestoreHelper() {                                                                 // The factory constructor returns the single instance of FirestoreHelper.
    return _instance;
  }

  FirestoreHelper._internal();                                                                // Private constructor to prevent instantiation from outside the class.                                                                                                                             
  final FirebaseAuth _auth = FirebaseAuth.instance;                                           // Get the FirebaseAuth instance to handle user authentication.

  final FirebaseFirestore _db = FirebaseFirestore.instance;                                   // Get the FirebaseFirestore instance to interact with Firestore database.    

  // This getter returns a collection reference for "farmers" with a converter.
  // The converter automatically handles the conversion between a `Farmer` object
  // and a `Map<String, dynamic>` when writing to and reading from Firestore.
  // This makes our code much cleaner and prevents type-casting errors.
  CollectionReference<Farmer> get _farmersCollection {
    return _db.collection('farmers').withConverter<Farmer>(
      fromFirestore: (snapshot, _) => Farmer.fromFirestore(snapshot),
      toFirestore: (farmer, _) => farmer.toMap(),
    );
  }

  // Add a new farmer to the 'farmers' collection.
  Future<void> addFarmer(Farmer farmer) async {
    try {
      await _farmersCollection.add(farmer);
    } catch (e) {
      print('Error adding farmer: $e');
      rethrow;
    }
  }

  // Stream all farmers from the 'farmers' collection in real-time.
  // The `snapshots()` method returns a `Stream<QuerySnapshot>`, which we map
  // to a `Stream<List<Farmer>>`.
  Stream<List<Farmer>> streamFarmers() {
    return _farmersCollection.snapshots().map((querySnapshot) {
      // The `withConverter` takes care of the mapping, so we can get the data
      // directly from the document.
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Delete a farmer by their Firestore document ID.
  Future<void> deleteFarmer(String farmerId) async {
    try {
      await _farmersCollection.doc(farmerId).delete();
    } catch (e) {
      print('Error deleting farmer: $e');
      rethrow;
    }
  }




  // Update an existing farmer's data.
  Future<void> updateFarmer(Farmer farmer) async {
    try {
      if (farmer.id != null) {
        await _farmersCollection.doc(farmer.id).set(farmer);
      }
    } catch (e) {
      print('Error updating farmer: $e');
      rethrow;
    }
  }

  // Check if a user is logged in.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
