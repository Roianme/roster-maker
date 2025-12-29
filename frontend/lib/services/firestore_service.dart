import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue.dart';
import '../models/role.dart';
import '../models/staff.dart';
import '../models/availability.dart';
import '../models/template.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Venues
  Stream<List<Venue>> getVenues() {
    return _firestore
        .collection('venues')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Venue.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createVenue(Venue venue) async {
    await _firestore.collection('venues').add(venue.toFirestore());
  }

  Future<void> updateVenue(Venue venue) async {
    await _firestore
        .collection('venues')
        .doc(venue.id)
        .update(venue.toFirestore());
  }

  Future<void> deleteVenue(String id) async {
    await _firestore.collection('venues').doc(id).update({'active': false});
  }

  // Roles
  Stream<List<Role>> getRoles() {
    return _firestore
        .collection('roles')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Role.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createRole(Role role) async {
    await _firestore.collection('roles').add(role.toFirestore());
  }

  Future<void> updateRole(Role role) async {
    await _firestore.collection('roles').doc(role.id).update(role.toFirestore());
  }

  Future<void> deleteRole(String id) async {
    await _firestore.collection('roles').doc(id).update({'active': false});
  }

  // Staff
  Stream<List<Staff>> getStaff() {
    return _firestore
        .collection('staff')
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Staff.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createStaff(Staff staff) async {
    await _firestore.collection('staff').add(staff.toFirestore());
  }

  Future<void> updateStaff(Staff staff) async {
    await _firestore
        .collection('staff')
        .doc(staff.id)
        .update(staff.toFirestore());
  }

  Future<void> deleteStaff(String id) async {
    await _firestore.collection('staff').doc(id).update({'active': false});
  }

  // Availability
  Stream<List<Availability>> getAvailability(String staffId) {
    return _firestore
        .collection('availability')
        .where('staffId', isEqualTo: staffId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Availability.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createAvailability(Availability availability) async {
    await _firestore.collection('availability').add(availability.toFirestore());
  }

  Future<void> updateAvailability(Availability availability) async {
    await _firestore
        .collection('availability')
        .doc(availability.id)
        .update(availability.toFirestore());
  }

  // Templates
  Stream<List<WeekdayTemplate>> getTemplates(String venueId) {
    return _firestore
        .collection('templates')
        .where('venueId', isEqualTo: venueId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeekdayTemplate.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createTemplate(WeekdayTemplate template) async {
    await _firestore.collection('templates').add(template.toFirestore());
  }

  Future<void> updateTemplate(WeekdayTemplate template) async {
    await _firestore
        .collection('templates')
        .doc(template.id)
        .update(template.toFirestore());
  }

  Future<void> deleteTemplate(String id) async {
    await _firestore.collection('templates').doc(id).delete();
  }
}
