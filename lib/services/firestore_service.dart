import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan.dart';

class FirestoreService {
  final CollectionReference plansCollection = 
      FirebaseFirestore.instance.collection('plans');

  // Get all plans
  Stream<List<Plan>> getPlans() {
    return plansCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Plan.fromFirestore(doc))
            .toList());
  }

  // Add a new plan
  Future<DocumentReference> addPlan(Plan plan) {
    return plansCollection.add(plan.toMap());
  }

  // Update a plan
  Future<void> updatePlan(Plan plan) {
    return plansCollection.doc(plan.id).update(plan.toMap());
  }

  // Delete a plan
  Future<void> deletePlan(String planId) {
    return plansCollection.doc(planId).delete();
  }
}
