import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart';

class FirestoreHelper {
  static final FirestoreHelper _instance = FirestoreHelper._internal();
  factory FirestoreHelper() => _instance;
  FirestoreHelper._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Collection references with converters ---

  CollectionReference<Supplier> get _suppliersCollection {
    return _db.collection('Suppliers').withConverter<Supplier>(
          fromFirestore: (snapshot, _) => Supplier.fromFirestore(snapshot),
          toFirestore: (supplier, _) => supplier.toMap(),
        );
  }

  CollectionReference<Announcement> get _announcementsCollection {
    return _db.collection('Announcements').withConverter<Announcement>(
          fromFirestore: (snapshot, _) => Announcement.fromFirestore(snapshot),
          toFirestore: (announcement, _) => announcement.toMap(),
        );
  }

  CollectionReference<Bid> get _bidsCollection {
    return _db.collection('Bids').withConverter<Bid>(
          fromFirestore: (snapshot, _) => Bid.fromFirestore(snapshot),
          toFirestore: (bid, _) => bid.toMap(),
        );
  }

  CollectionReference<Shipment> get _shipmentsCollection {
    return _db.collection('Shipments').withConverter<Shipment>(
          fromFirestore: (snapshot, _) => Shipment.fromFirestore(snapshot),
          toFirestore: (shipment, _) => shipment.toMap(),
        );
  }

  CollectionReference<CreditCheck> get _creditChecksCollection {
    return _db.collection('CreditChecks').withConverter<CreditCheck>(
          fromFirestore: (snapshot, _) => CreditCheck.fromFirestore(snapshot),
          toFirestore: (creditCheck, _) => creditCheck.toMap(),
        );
  }

  CollectionReference<ContractInfo> get _contractsCollection {
    return _db.collection('Contracts').withConverter<ContractInfo>(
          fromFirestore: (snapshot, _) => ContractInfo.fromFirestore(snapshot),
          toFirestore: (contract, _) => contract.toMap(),
        );
  }

  CollectionReference<BankDetails> get _banksCollection {
    return _db.collection('Banks').withConverter<BankDetails>(
          fromFirestore: (snapshot, _) => BankDetails.fromFirestore(snapshot),
          toFirestore: (bank, _) => bank.toMap(),
        );
  }

  // --- Supplier profile ---

  Future<Supplier?> getSupplierBySupId(int supId) async {
    final snapshot =
        await _suppliersCollection.where('SupId', isEqualTo: supId).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // --- Announcements ---

  Stream<List<Announcement>> streamAnnouncements() {
    return _announcementsCollection
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- Bids ---

  Stream<List<Bid>> streamBidsForSupplier(int supId) {
    return _bidsCollection
        .where('SupId', isEqualTo: supId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> submitBid(Bid bid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();

    final bidWithMeta = bid.copyWith(
      CreatedBy: currentUser?.email ?? '',
      CreatedByName: currentUser?.displayName ?? currentUser?.email ?? '',
      CreatedAt: now,
      LastModifiedBy: currentUser?.email ?? '',
      LastModifiedByName: currentUser?.displayName ?? currentUser?.email ?? '',
      LastModifiedAt: now,
    );

    await _bidsCollection.add(bidWithMeta);
  }

  // --- Shipments ---

  Stream<List<Shipment>> streamShipmentsForSupplier(int supId) {
    return _shipmentsCollection
        .where('SupId', isEqualTo: supId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addShipment(Shipment shipment) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();

    final shipmentWithMeta = shipment.copyWith(
      CreatedBy: currentUser?.email ?? '',
      CreatedByName: currentUser?.displayName ?? currentUser?.email ?? '',
      CreatedAt: now,
      LastModifiedBy: currentUser?.email ?? '',
      LastModifiedByName: currentUser?.displayName ?? currentUser?.email ?? '',
      LastModifiedAt: now,
    );

    await _shipmentsCollection.add(shipmentWithMeta);
  }

  // --- Credit check ---

  Future<CreditCheck?> getCreditCheckForSupplier(int supId) async {
    final snapshot = await _creditChecksCollection
        .where('SupId', isEqualTo: supId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // --- Contract ---

  Future<ContractInfo?> getContractForSupplier(int supId) async {
    final snapshot = await _contractsCollection
        .where('SupId', isEqualTo: supId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  // --- Bank details ---

  Future<List<BankDetails>> getBankDetailsForSupplier(int supId) async {
    final snapshot =
        await _banksCollection.where('SupId', isEqualTo: supId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // --- Auth ---

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
