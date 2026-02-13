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
import 'package:gemini001/models/credit_check_history.dart';
import 'package:gemini001/models/contract_history.dart';
import 'package:gemini001/models/bank_history.dart';
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

  // This getter returns a collection reference for "CreditCheckHistory" with a converter.
  CollectionReference<CreditCheckHistory> get _creditCheckHistoryCollection {
    return _db.collection('CreditCheckHistory').withConverter<CreditCheckHistory>(
          fromFirestore: (snapshot, _) => CreditCheckHistory.fromFirestore(snapshot),
          toFirestore: (history, _) => history.toMap(),
        );
  }

  // This getter returns a collection reference for "ContractHistory" with a converter.
  CollectionReference<ContractHistory> get _contractHistoryCollection {
    return _db.collection('ContractHistory').withConverter<ContractHistory>(
          fromFirestore: (snapshot, _) => ContractHistory.fromFirestore(snapshot),
          toFirestore: (history, _) => history.toMap(),
        );
  }

  // This getter returns a collection reference for "BankHistory" with a converter.
  CollectionReference<BankHistory> get _bankHistoryCollection {
    return _db.collection('BankHistory').withConverter<BankHistory>(
          fromFirestore: (snapshot, _) => BankHistory.fromFirestore(snapshot),
          toFirestore: (history, _) => history.toMap(),
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

  // Add a new contract
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addContractInfo(ContractInfo contractInfo) async {
    try {
      final currentUser = _auth.currentUser;
      final contractWithMetadata = contractInfo.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName:
            currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _contractsCollection.add(contractWithMetadata);
      if (currentUser != null) {
        await _db.collection('audit_trails').add({
          'action': 'contract_added',
          'supplierId': contractInfo.SupId,
          'contractNo': contractInfo.ContractNo,
          'userUid': currentUser.uid,
          'userEmail': currentUser.email,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      logger.e('Error adding contract: $e');
      rethrow;
    }
  }

  // Update contract info and log to audit_trails.
  // Automatically sets modification metadata (LastModifiedBy, LastModifiedByName, LastModifiedAt)
  // and preserves creation metadata from the original document.
  // Optional: Pass changes to log field-level history
  Future<void> updateContractInfo(
    ContractInfo contractInfo, {
    List<FieldChange>? changes,
    String? reason,
    String? ipAddress,
  }) async {
    try {
      if (contractInfo.id != null) {
        // Fetch old contract to preserve creation metadata
        final oldDoc = await _contractsCollection.doc(contractInfo.id).get();
        final oldContract = oldDoc.data();

        final currentUser = _auth.currentUser;
        final contractWithMetadata = contractInfo.copyWith(
          // Preserve original creation metadata
          CreatedBy: oldContract?.CreatedBy ?? contractInfo.CreatedBy,
          CreatedByName: oldContract?.CreatedByName ?? contractInfo.CreatedByName,
          CreatedAt: oldContract?.CreatedAt ?? contractInfo.CreatedAt,
          // Set modification metadata
          LastModifiedBy: currentUser?.uid,
          LastModifiedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
          LastModifiedAt: DateTime.now(),
        );
        await _contractsCollection.doc(contractInfo.id).set(contractWithMetadata);

        // Log audit for contract update
        if (currentUser != null) {
          await _db.collection('audit_trails').add({
            'action': 'contract_updated',
            'supplierId': contractInfo.SupId,
            'contractNo': contractInfo.ContractNo,
            'userUid': currentUser.uid,
            'userEmail': currentUser.email,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        // Create history entry if changes provided
        if (changes != null && changes.isNotEmpty && currentUser != null) {
          final history = ContractHistory(
            supId: contractInfo.SupId,
            documentId: contractInfo.id!,
            timestamp: DateTime.now(),
            userId: currentUser.email ?? currentUser.uid,
            userName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
            changes: changes,
            ipAddress: ipAddress,
            reason: reason,
          );
          await addContractHistory(history);
        }
      }
    } catch (e) {
      logger.e('Error updating contract: $e');
      rethrow;
    }
  }

  // Add contract history entry
  Future<void> addContractHistory(ContractHistory history) async {
    try {
      await _contractHistoryCollection.add(history);
      logger.i('Contract history entry added for document: ${history.documentId}');
    } catch (e) {
      logger.e('Error adding contract history: $e');
      rethrow;
    }
  }

  // Get contract history for a specific contract document
  Future<List<ContractHistory>> getContractHistory(String documentId) async {
    try {
      final querySnapshot = await _contractHistoryCollection
          .where('documentId', isEqualTo: documentId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      logger.e('Error fetching contract history: $e');
      rethrow;
    }
  }

  // Get bank details for a given SupId.
  Future<BankDetails?> getBankDetails(int supId) async {
    final querySnapshot =
        await _banksCollection.where('SupId', isEqualTo: supId).limit(1).get();
    return querySnapshot.docs.isNotEmpty
        ? querySnapshot.docs.first.data()
        : null;
  }

  // Add new bank details
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addBankDetails(BankDetails bankDetails) async {
    try {
      final currentUser = _auth.currentUser;
      final bankWithMetadata = bankDetails.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName:
            currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _banksCollection.add(bankWithMetadata);
      if (currentUser != null) {
        await _db.collection('audit_trails').add({
          'action': 'bank_details_added',
          'supplierId': bankDetails.SupId,
          'bankName': bankDetails.BankName,
          'userUid': currentUser.uid,
          'userEmail': currentUser.email,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      logger.e('Error adding bank details: $e');
      rethrow;
    }
  }

  // Update bank details and log to audit_trails.
  // Automatically sets modification metadata (LastModifiedBy, LastModifiedByName, LastModifiedAt)
  // and preserves creation metadata from the original document.
  // Optional: Pass changes to log field-level history
  Future<void> updateBankDetails(
    BankDetails bankDetails, {
    List<FieldChange>? changes,
    String? reason,
    String? ipAddress,
  }) async {
    try {
      if (bankDetails.id != null) {
        // Fetch old bank details to preserve creation metadata
        final oldDoc = await _banksCollection.doc(bankDetails.id).get();
        final oldBankDetails = oldDoc.data();

        final currentUser = _auth.currentUser;
        final bankWithMetadata = bankDetails.copyWith(
          // Preserve original creation metadata
          CreatedBy: oldBankDetails?.CreatedBy ?? bankDetails.CreatedBy,
          CreatedByName: oldBankDetails?.CreatedByName ?? bankDetails.CreatedByName,
          CreatedAt: oldBankDetails?.CreatedAt ?? bankDetails.CreatedAt,
          // Set modification metadata
          LastModifiedBy: currentUser?.uid,
          LastModifiedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
          LastModifiedAt: DateTime.now(),
        );
        await _banksCollection.doc(bankDetails.id).set(bankWithMetadata);

        // Log audit for bank details update
        if (currentUser != null) {
          await _db.collection('audit_trails').add({
            'action': 'bank_details_updated',
            'supplierId': bankDetails.SupId,
            'bankName': bankDetails.BankName,
            'userUid': currentUser.uid,
            'userEmail': currentUser.email,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        // Create history entry if changes provided
        if (changes != null && changes.isNotEmpty && currentUser != null) {
          final history = BankHistory(
            supId: bankDetails.SupId,
            documentId: bankDetails.id!,
            timestamp: DateTime.now(),
            userId: currentUser.email ?? currentUser.uid,
            userName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
            changes: changes,
            ipAddress: ipAddress,
            reason: reason,
          );
          await addBankHistory(history);
        }
      }
    } catch (e) {
      logger.e('Error updating bank details: $e');
      rethrow;
    }
  }

  // Add bank history entry
  Future<void> addBankHistory(BankHistory history) async {
    try {
      await _bankHistoryCollection.add(history);
      logger.i('Bank history entry added for document: ${history.documentId}');
    } catch (e) {
      logger.e('Error adding bank history: $e');
      rethrow;
    }
  }

  // Get bank history for a specific bank document
  Future<List<BankHistory>> getBankHistory(String documentId) async {
    try {
      final querySnapshot = await _bankHistoryCollection
          .where('documentId', isEqualTo: documentId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      logger.e('Error fetching bank history: $e');
      rethrow;
    }
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

  // Add a new credit check
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addCreditCheck(CreditCheck creditCheck) async {
    try {
      final currentUser = _auth.currentUser;
      final creditCheckWithMetadata = creditCheck.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _creditChecksCollection.add(creditCheckWithMetadata);
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

  // Update credit check and log to audit_trails.
  // Automatically sets modification metadata (LastModifiedBy, LastModifiedByName, LastModifiedAt)
  // and preserves creation metadata from the original document.
  // Optional: Pass changes to log field-level history
  Future<void> updateCreditCheck(
    CreditCheck creditCheck, {
    String? oldStatus,
    List<FieldChange>? changes,
    String? reason,
    String? ipAddress,
  }) async {
    try {
      if (creditCheck.id != null) {
        // Fetch old credit check to preserve creation metadata
        final oldDoc = await _creditChecksCollection.doc(creditCheck.id).get();
        final oldCreditCheck = oldDoc.data();

        final currentUser = _auth.currentUser;
        final creditCheckWithMetadata = creditCheck.copyWith(
          // Preserve original creation metadata
          CreatedBy: oldCreditCheck?.CreatedBy ?? creditCheck.CreatedBy,
          CreatedByName: oldCreditCheck?.CreatedByName ?? creditCheck.CreatedByName,
          CreatedAt: oldCreditCheck?.CreatedAt ?? creditCheck.CreatedAt,
          // Set modification metadata
          LastModifiedBy: currentUser?.uid,
          LastModifiedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
          LastModifiedAt: DateTime.now(),
        );
        await _creditChecksCollection.doc(creditCheck.id).set(creditCheckWithMetadata);

        // Log audit for status change
        final effectiveOldStatus = oldStatus ?? oldCreditCheck?.status;
        if (currentUser != null && effectiveOldStatus != null && effectiveOldStatus != creditCheck.status) {
          await _db.collection('audit_trails').add({
            'action': 'credit_check_status_change',
            'supplierId': creditCheck.supId,
            'oldStatus': effectiveOldStatus,
            'newStatus': creditCheck.status,
            'userUid': currentUser.uid,
            'userEmail': currentUser.email,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        // Create history entry if changes provided
        if (changes != null && changes.isNotEmpty && currentUser != null) {
          final history = CreditCheckHistory(
            supId: creditCheck.supId,
            documentId: creditCheck.id!,
            timestamp: DateTime.now(),
            userId: currentUser.email ?? currentUser.uid,
            userName: currentUser.displayName ?? currentUser.email ?? 'Unknown User',
            changes: changes,
            ipAddress: ipAddress,
            reason: reason,
          );
          await addCreditCheckHistory(history);
        }
      }
    } catch (e) {
      logger.e('Error updating credit check: $e');
      rethrow;
    }
  }

  // Add a credit check history entry
  Future<void> addCreditCheckHistory(CreditCheckHistory history) async {
    try {
      await _creditCheckHistoryCollection.add(history);
      logger.i('Credit check history added for SupId: ${history.supId}, Changes: ${history.changes.length}');
    } catch (e) {
      logger.e('Error adding credit check history: $e');
      rethrow;
    }
  }

  // Get history for a specific credit check
  Future<List<CreditCheckHistory>> getCreditCheckHistory(int supId) async {
    try {
      final querySnapshot = await _creditCheckHistoryCollection
          .where('supId', isEqualTo: supId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      logger.e('Error fetching credit check history: $e');
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
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addAnnouncement(Announcement announcement) async {
    try {
      final currentUser = _auth.currentUser;
      final announcementWithMetadata = announcement.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _announcementsCollection.add(announcementWithMetadata);
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
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addBid(Bid bid) async {
    try {
      final currentUser = _auth.currentUser;
      final bidWithMetadata = bid.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _bidsCollection.add(bidWithMetadata);
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
  // Automatically sets creation metadata (CreatedBy, CreatedByName, CreatedAt)
  Future<void> addShipment(Shipment shipment) async {
    try {
      final currentUser = _auth.currentUser;
      final shipmentWithMetadata = shipment.copyWith(
        CreatedBy: currentUser?.uid,
        CreatedByName: currentUser?.displayName ?? currentUser?.email ?? 'Unknown',
        CreatedAt: DateTime.now(),
      );
      await _shipmentsCollection.add(shipmentWithMetadata);
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
