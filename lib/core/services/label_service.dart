import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/label_enums.dart';
import 'package:my_money/core/exceptions/app_exceptions.dart';
import 'package:my_money/core/models/label_model.dart';

class LabelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'labels';

  // Get labels for a specific user and type
  Stream<List<LabelModel>> getLabelsStream(String userId, {LabelType? type}) {
    Query query = _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('name');

    if (type != null) {
      query = query.where('type', isEqualTo: type.value);
    }

    return query.snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => LabelModel.fromDocument(doc)).toList());
  }

  // Get labels for a specific user and type (Future version)
  Future<List<LabelModel>> getLabels(String userId, {LabelType? type}) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('name');

      if (type != null) {
        query = query.where('type', isEqualTo: type.value);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => LabelModel.fromDocument(doc)).toList();
    } catch (e) {
      throw FirestoreException('Error fetching labels: $e');
    }
  }

  // Get labels by IDs
  Future<List<LabelModel>> getLabelsByIds(List<String> labelIds) async {
    if (labelIds.isEmpty) return [];

    try {
      final results = <LabelModel>[];
      
      // Firestore 'in' queries are limited to 10 items
      const batchSize = 10;
      for (int i = 0; i < labelIds.length; i += batchSize) {
        final batchIds = labelIds.skip(i).take(batchSize).toList();
        final snapshot = await _firestore
            .collection(_collectionName)
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        
        results.addAll(
          snapshot.docs.map((doc) => LabelModel.fromDocument(doc)).toList(),
        );
      }
      
      return results;
    } catch (e) {
      throw FirestoreException('Error fetching labels by IDs: $e');
    }
  }

  // Create a new label
  Future<LabelModel> createLabel({
    required String userId,
    required String name,
    required LabelType type,
    required LabelColor color,
    String? icon,
    String? description,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final now = DateTime.now();
      
      final label = LabelModel(
        id: docRef.id,
        name: name,
        type: type,
        color: color,
        userId: userId,
        icon: icon,
        description: description,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(label.toMap());
      return label;
    } catch (e) {
      throw FirestoreException('Error creating label: $e');
    }
  }

  // Update a label
  Future<void> updateLabel(LabelModel label) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(label.id)
          .update(label.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw FirestoreException('Error updating label: $e');
    }
  }

  // Delete a label (soft delete)
  Future<void> deleteLabel(String labelId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(labelId)
          .update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw FirestoreException('Error deleting label: $e');
    }
  }

  // Create default labels for a new user
  Future<void> createDefaultLabels(String userId) async {
    final defaultLabels = [
      // Income labels
      {'name': 'Salary', 'type': LabelType.income, 'color': LabelColor.green, 'icon': 'work'},
      {'name': 'Freelance', 'type': LabelType.income, 'color': LabelColor.blue, 'icon': 'work'},
      {'name': 'Business', 'type': LabelType.income, 'color': LabelColor.purple, 'icon': 'work'},
      {'name': 'Bonus', 'type': LabelType.income, 'color': LabelColor.yellow, 'icon': 'gift'},
      {'name': 'Investment Returns', 'type': LabelType.income, 'color': LabelColor.teal, 'icon': 'investment'},
      
      // Expense labels
      {'name': 'Food & Dining', 'type': LabelType.expense, 'color': LabelColor.orange, 'icon': 'food'},
      {'name': 'Transportation', 'type': LabelType.expense, 'color': LabelColor.blue, 'icon': 'transport'},
      {'name': 'Shopping', 'type': LabelType.expense, 'color': LabelColor.pink, 'icon': 'shopping'},
      {'name': 'Entertainment', 'type': LabelType.expense, 'color': LabelColor.purple, 'icon': 'entertainment'},
      {'name': 'Bills & Utilities', 'type': LabelType.expense, 'color': LabelColor.red, 'icon': 'bills'},
      {'name': 'Healthcare', 'type': LabelType.expense, 'color': LabelColor.red, 'icon': 'health'},
      {'name': 'Education', 'type': LabelType.expense, 'color': LabelColor.blue, 'icon': 'education'},
      {'name': 'Travel', 'type': LabelType.expense, 'color': LabelColor.cyan, 'icon': 'travel'},
      
      // Investment labels
      {'name': 'Stocks', 'type': LabelType.investment, 'color': LabelColor.green, 'icon': 'investment'},
      {'name': 'Crypto', 'type': LabelType.investment, 'color': LabelColor.orange, 'icon': 'investment'},
      {'name': 'Real Estate', 'type': LabelType.investment, 'color': LabelColor.teal, 'icon': 'home'},
      {'name': 'Savings Account', 'type': LabelType.investment, 'color': LabelColor.blue, 'icon': 'savings'},
    ];

    for (final labelData in defaultLabels) {
      await createLabel(
        userId: userId,
        name: labelData['name'] as String,
        type: labelData['type'] as LabelType,
        color: labelData['color'] as LabelColor,
        icon: labelData['icon'] as String?,
      );
    }
  }

  // Search labels by name
  Future<List<LabelModel>> searchLabels(String userId, String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .startAt([query])
          .endAt(['${query}\uf8ff'])
          .get();

      return snapshot.docs.map((doc) => LabelModel.fromDocument(doc)).toList();
    } catch (e) {
      throw FirestoreException('Error searching labels: $e');
    }
  }
}
