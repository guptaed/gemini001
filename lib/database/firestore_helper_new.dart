import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';
import 'package:gemini001/models/smartphoneaccess.dart';
import 'package:gemini001/models/announcement.dart';
import 'package:gemini001/models/credit_check.dart';
import 'package:gemini001/models/bid.dart';
import 'package:gemini001/models/shipment.dart';
import 'package:gemini001/models/bid_flow.dart';
import 'package:gemini001/models/supplier_history.dart';
import 'package:gemini001/utils/logging.dart';

// FirestoreHelper is a helper class that encapsulates all the Firestore logic
// for our application, making it easier to manage data and separate concerns.

class FirestoreHelper {
  static final FirestoreHelper _instance = FirestoreHelper
      ._internal(); // We create a private static instance of the class to implement the Singleton pattern.
  // This ensures that we only have one instance of FirestoreHelper throughout the app.
  factory FirestoreHelper() {
    // The factory constructor returns the single instance of FirestoreHelper.
    return _instance;
  }

  FirestoreHelper._internal(); // Private constructor to prevent instantiation from outside the class.
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // Get the FirebaseAuth instance to handle user authentication.

  final FirebaseFirestore _db = FirebaseFirestore
      .instance; // Get the FirebaseFirestore instance to interact with Firestore database.

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

  // This getter returns a collection reference for "Shipments" with a converter.
  CollectionReference<Shipment> get _shipmentsCollection {
    return _db.collection('Shipments').withConverter<Shipment>(
          fromFirestore: (snapshot, _) => Shipment.fromFirestore(snapshot),
          toFirestore: (shipment, _) => shipment.toMap(),
        );
  }

  // This getter returns a collection reference for "SupplierHistory" with a converter.
  CollectionReference<SupplierHistory> get _supplierHistoryCollection {
    return _db.collection('SupplierHistory').withConverter<SupplierHistory>(
          fromFirestore: (snapshot, _) => SupplierHistory.fromFirestore(snapshot),
          toFirestore: (history, _) => history.toMap(),
        );
  }

  // Add a new supplier to the 'suppliers' collection.
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addSupplier(Supplier supplier) async {
    try {
      final currentUser = _auth.currentUser;
      final supplierWithMetadata = supplier.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _suppliersCollection.add(supplierWithMetadata);
    } catch (e) {
      logger.e('Error adding supplier: $e');
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
      logger.e('Error deleting supplier: $e');
      rethrow;
    }
  }

  // Get a supplier by their SupId
  Future<Supplier?> getSupplierBySupId(int supId) async {
    try {
      final querySnapshot = await _suppliersCollection
          .where('SupId', isEqualTo: supId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.first.data()
          : null;
    } catch (e) {
      logger.e('Error fetching supplier by SupId: $e');
      rethrow;
    }
  }

  // Update an existing supplier's data.
  // Automatically sets modification metadata (LastModifiedBy, LastModifiedByName, LastModifiedAt)
  // and preserves creation metadata from the original document.
  // Optional: Pass changes to log field-level history
  Future<void> updateSupplier(
    Supplier supplier, {
    List<FieldChange>? changes,
    String? reason,
    String? ipAddress,
  }) async {
    try {
      if (supplier.id != null) {
        // Fetch old supplier for audit and to preserve creation metadata
        final oldDoc = await _suppliersCollection.doc(supplier.id).get();
        final oldSupplier = oldDoc.data();

        // Set modification metadata and preserve creation metadata
        final currentUser = _auth.currentUser;
        final supplierWithMetadata = supplier.copyWith(
          // Preserve original creation metadata
          CreatedBy: oldSupplier?.CreatedBy ?? supplier.CreatedBy,
          CreatedByName: oldSupplier?.CreatedByName ?? supplier.CreatedByName,
          CreatedAt: oldSupplier?.CreatedAt ?? supplier.CreatedAt,
          // Set modification metadata
          LastModifiedBy: currentUser?.uid,
          LastModifiedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
          LastModifiedAt: DateTime.now(),
        );

        await _suppliersCollection.doc(supplier.id).set(supplierWithMetadata);

        // Log audit for status change (existing functionality)
        if (currentUser != null && oldSupplier?.Status != supplier.Status) {
          await _db.collection('audit_trails').add({
            'action': 'status_change',
            'supplierId': supplier.SupId,
            'oldStatus': oldSupplier?.Status,
            'newStatus': supplier.Status,
            'userUid': currentUser.uid,
            'userEmail': currentUser.email,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        // Create history entry if changes provided (new functionality)
        if (changes != null && changes.isNotEmpty && currentUser != null) {
          final history = SupplierHistory(
            supId: supplier.SupId,
            documentId: supplier.id!,
            timestamp: DateTime.now(),
            userId: currentUser.email ?? currentUser.uid,
            userName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
            changes: changes,
            ipAddress: ipAddress,
            reason: reason,
          );
          await addSupplierHistory(history);
        }
      }
    } catch (e) {
      logger.e('Error updating supplier: $e');
      rethrow;
    }
  }

  // Add a supplier history entry
  Future<void> addSupplierHistory(SupplierHistory history) async {
    try {
      await _supplierHistoryCollection.add(history);
      logger.i('Supplier history added for SupId: ${history.supId}, Changes: ${history.changes.length}');
    } catch (e) {
      logger.e('Error adding supplier history: $e');
      rethrow;
    }
  }

  // Get history for a specific supplier
  Future<List<SupplierHistory>> getSupplierHistory(int supId) async {
    try {
      final querySnapshot = await _supplierHistoryCollection
          .where('supId', isEqualTo: supId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      logger.e('Error fetching supplier history: $e');
      rethrow;
    }
  }

  // Stream all history (for admin view)
  Stream<List<SupplierHistory>> streamAllHistory() {
    return _supplierHistoryCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // This getter returns a collection reference for "Contracts" with a converter.
  CollectionReference<ContractInfo> get _contractsCollection {
    return _db.collection('Contracts').withConverter<ContractInfo>(
          fromFirestore: (snapshot, _) => ContractInfo.fromFirestore(snapshot),
          toFirestore: (contract, _) => contract.toMap(),
        );
  }

  // This getter returns a collection reference for "Banks" with a converter.
  CollectionReference<BankDetails> get _banksCollection {
    return _db.collection('Banks').withConverter<BankDetails>(
          fromFirestore: (snapshot, _) => BankDetails.fromFirestore(snapshot),
          toFirestore: (bank, _) => bank.toMap(),
        );
  }

  // This getter returns a collection reference for "CreditChecks" with a converter.
  CollectionReference<CreditCheck> get _creditChecksCollection {
    return _db.collection('CreditChecks').withConverter<CreditCheck>(
          fromFirestore: (snapshot, _) => CreditCheck.fromFirestore(snapshot),
          toFirestore: (creditCheck, _) => creditCheck.toMap(),
        );
  }


  // This getter returns a collection reference for "Smartphoneaccess" with a converter.
  CollectionReference<SmartphoneAccess> get _smartphoneaccessCollection {
    return _db.collection('Smartphoneaccess').withConverter<SmartphoneAccess>(
          fromFirestore: (snapshot, _) => SmartphoneAccess.fromFirestore(snapshot),
          toFirestore: (smartphoneAccess, _) => smartphoneAccess.toMap(),
        );
  }


  // This getter returns a collection reference for "Bids" with a converter.
  CollectionReference<Bid> get _bidsCollection {
    return _db.collection('Bids').withConverter<Bid>(
          fromFirestore: (snapshot, _) => Bid.fromFirestore(snapshot),
          toFirestore: (bid, _) => bid.toMap(),
        );
  }

  Future<List<BidFlow>> getBidFlowsBySupplier(int supId) async {
    final querySnapshot =
        await _db.collection('BidFlows').where('SupId', isEqualTo: supId).get();
    return querySnapshot.docs.map((doc) => BidFlow.fromFirestore(doc)).toList();
  }

  // Get contract information for a given SupId.
  Future<ContractInfo?> getContractInfo(int supId) async {
    final querySnapshot = await _contractsCollection
        .where('SupId', isEqualTo: supId)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty
        ? querySnapshot.docs.first.data()
        : null;
  }

  // Get bank details for a given SupId.
  Future<BankDetails?> getBankDetails(int supId) async {
    final querySnapshot =
        await _banksCollection.where('SupId', isEqualTo: supId).limit(1).get();
    return querySnapshot.docs.isNotEmpty
        ? querySnapshot.docs.first.data()
        : null;
  }

  // Get Smartphone Access for a given SupId.
  Future<SmartphoneAccess?> getSmartphoneAccess(int supId) async {
    final querySnapshot =
        await _smartphoneaccessCollection.where('SupId', isEqualTo: supId).limit(1).get();
    return querySnapshot.docs.isNotEmpty
        ? querySnapshot.docs.first.data()
        : null;
  }




  // Get credit check details for a given SupId.
  Future<CreditCheck?> getCreditCheck(int supId) async {
    try {
      final querySnapshot = await _creditChecksCollection
          .where('SupId', isEqualTo: supId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty
          ? querySnapshot.docs.first.data()
          : null;
    } catch (e) {
      logger.e('Error fetching credit check: $e');
      rethrow;
    }
  }

  Future<void> addCreditCheck(CreditCheck creditCheck) async {
    try {
      await _creditChecksCollection.add(creditCheck);
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _db.collection('audit_trails').add({
          'action': 'credit_check_added',
          'supplierId': creditCheck.supId,
          'newStatus': creditCheck.status,
          'userUid': currentUser.uid,
          'userEmail': currentUser.email,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      logger.e('Error adding credit check: $e');
      rethrow;
    }
  }

  // Update credit check status and log to audit_trails.
  Future<void> updateCreditCheck(
      CreditCheck creditCheck, String oldStatus) async {
    try {
      if (creditCheck.id != null) {
        await _creditChecksCollection.doc(creditCheck.id).set(creditCheck);
        // Log audit
        final currentUser = _auth.currentUser;
        if (currentUser != null && oldStatus != creditCheck.status) {
          await _db.collection('audit_trails').add({
            'action': 'credit_check_status_change',
            'supplierId': creditCheck.supId,
            'oldStatus': oldStatus,
            'newStatus': creditCheck.status,
            'userUid': currentUser.uid,
            'userEmail': currentUser.email,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      logger.e('Error updating credit check: $e');
      rethrow;
    }
  }

  // Collection reference for "Announcements" with converter
  CollectionReference<Announcement> get _announcementsCollection {
    return _db.collection('Announcements').withConverter<Announcement>(
          fromFirestore: (snapshot, _) => Announcement.fromFirestore(snapshot),
          toFirestore: (announcement, _) => announcement.toMap(),
        );
  }

  // Add a new announcement
  Future<void> addAnnouncement(Announcement announcement) async {
    try {
      await _announcementsCollection.add(announcement);
    } catch (e) {
      logger.e('Error adding announcement: $e');
      rethrow;
    }
  }

  // Stream all announcements
  Stream<List<Announcement>> streamAnnouncements() {
    return _announcementsCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Add a new bid
  Future<void> addBid(Bid bid) async {
    try {
      await _bidsCollection.add(bid);
    } catch (e) {
      logger.e('Error adding bid: $e');
      rethrow;
    }
  }

  // Stream all bids
  Stream<List<Bid>> streamBids() {
    return _bidsCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Add a new shipment
  Future<void> addShipment(Shipment shipment) async {
    try {
      await _shipmentsCollection.add(shipment);
    } catch (e) {
      logger.e('Error adding shipment: $e');
      rethrow;
    }
  }

  // Stream all shipments
  Stream<List<Shipment>> streamShipments() {
    return _shipmentsCollection.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<List<Bid>> getBidsBySupplier(int supId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Bids')
          .where('SupId', isEqualTo: supId)
          .get();
      return snapshot.docs.map((doc) => Bid.fromFirestore(doc)).toList();
    } catch (e) {
      logger.e('Error fetching bids for SupId: $supId: $e');
      throw Exception('Failed to fetch bids: $e');
    }
  }

  // Check if a user is logged in.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase Auth Error: ${e.message}');
      rethrow; // Let callers handle the error
    } catch (e) {
      logger.e('Error signing in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      logger.e('Error signing out: $e');
      rethrow;
    }
  }

  // Optional: Sign up (if needed for new users)
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      logger.e('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('Error creating user: $e');
      rethrow;
    }
  }
}
