import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';

// FirestoreHelper is a helper class that encapsulates all the Firestore logic
// for our application, making it easier to manage data and separate concerns.

class FirestoreHelper {                                                                   
  static final FirestoreHelper _instance = FirestoreHelper._internal();                       // We create a private static instance of the class to implement the Singleton pattern.
                                                                                             // This ensures that we only have one instance of FirestoreHelper throughout the app.  
  factory FirestoreHelper() {                                                                // The factory constructor returns the single instance of FirestoreHelper.
    return _instance;
  }

  FirestoreHelper._internal();                                                               // Private constructor to prevent instantiation from outside the class.                                                                                                                             
  final FirebaseAuth _auth = FirebaseAuth.instance;                                          // Get the FirebaseAuth instance to handle user authentication.

  final FirebaseFirestore _db = FirebaseFirestore.instance;                                  // Get the FirebaseFirestore instance to interact with Firestore database.    

  // This getter returns a collection reference for "suppliers" with a converter.
  // The converter automatically handles the conversion between a `Supplier` object
  // and a `Map<String, dynamic>` when writing to and reading from Firestore.
  // This makes our code much cleaner and prevents type-casting errors.
  CollectionReference<Supplier> get _suppliersCollection {
    return _db.collection('Suppliers').withConverter<Supplier>(
      fromFirestore: (snapshot, _) => Supplier.fromFirestore(snapshot),
      toFirestore: (supplier, _) => supplier.toMap(),
    );
  }

  // Add a new supplier to the 'suppliers' collection.
  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _suppliersCollection.add(supplier);
    } catch (e) {
      print('Error adding supplier: $e');
      rethrow;
    }
  }

  // Stream all suppliers from the 'suppliers' collection in real-time.
  // The `snapshots()` method returns a `Stream<QuerySnapshot>`, which we map
  // to a `Stream<List<Supplier>>`.
  Stream<List<Supplier>> streamSuppliers() {
    return _suppliersCollection.snapshots().map((querySnapshot) {
      // The `withConverter` takes care of the mapping, so we can get the data
      // directly from the document.
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Delete a supplier by their Firestore document ID.
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _suppliersCollection.doc(supplierId).delete();
    } catch (e) {
      print('Error deleting supplier: $e');
      rethrow;
    }
  }

  // Update an existing supplier's data.
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      if (supplier.id != null) {
        await _suppliersCollection.doc(supplier.id).set(supplier);
      }
    } catch (e) {
      print('Error updating supplier: $e');
      rethrow;
    }
  }

  // This getter returns a collection reference for "Contracts" with a converter.
  CollectionReference<ContractInfo> get _contractsCollection {
    return _db.collection('Contracts').withConverter<ContractInfo>(
      fromFirestore: (snapshot, _) => ContractInfo.fromFirestore(snapshot),
      toFirestore: (contract, _) => contract.toMap(), // Assuming ContractInfo has a toMap method
    );
  }

  // This getter returns a collection reference for "Banks" with a converter.
  CollectionReference<BankDetails> get _banksCollection {
    return _db.collection('Banks').withConverter<BankDetails>(
      fromFirestore: (snapshot, _) => BankDetails.fromFirestore(snapshot),
      toFirestore: (bank, _) => bank.toMap(), // Assuming BankDetails has a toMap method
    );
  }

  // Get contract information for a given SupId.
  Future<ContractInfo?> getContractInfo(int supId) async {
    final querySnapshot = await _contractsCollection
        .where('SupId', isEqualTo: supId)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.data() : null;
  }

  // Get bank details for a given SupId.
  Future<BankDetails?> getBankDetails(int supId) async {
    final querySnapshot = await _banksCollection
        .where('SupId', isEqualTo: supId)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.data() : null;
  }

  // Check if a user is logged in.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
