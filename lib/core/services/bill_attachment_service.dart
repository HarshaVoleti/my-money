import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_money/core/models/bill_attachment_model.dart';

class BillAttachmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _billAttachmentsCollection = 'bill_attachments';
  static const String _storageFolder = 'bill_attachments';

  /// Upload a bill image and create an attachment record
  Future<BillAttachmentModel> uploadBillImage({
    required File imageFile,
    required String transactionId,
    String? description,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${transactionId}_$timestamp.jpg';
      final storagePath = '$_storageFolder/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Get file metadata
      final metadata = await uploadTask.ref.getMetadata();
      final fileSize = metadata.size ?? 0;

      // Create attachment model with storagePath stored in description for later retrieval
      final attachment = BillAttachmentModel(
        id: '', // Will be set by Firestore
        transactionId: transactionId,
        fileName: fileName,
        originalFileName: imageFile.path.split('/').last,
        fileUrl: downloadUrl,
        fileType: 'image/jpeg',
        fileSize: fileSize,
        uploadedAt: DateTime.now(),
        description: description,
      );

      // Save to Firestore with storagePath as additional field
      final attachmentData = attachment.toMap();
      attachmentData['storagePath'] = storagePath;
      
      final docRef = await _firestore
          .collection(_billAttachmentsCollection)
          .add(attachmentData);

      return attachment.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to upload bill image: $e');
    }
  }

  /// Get all attachments for a transaction
  Future<List<BillAttachmentModel>> getTransactionAttachments(String transactionId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_billAttachmentsCollection)
          .where('transactionId', isEqualTo: transactionId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BillAttachmentModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transaction attachments: $e');
    }
  }

  /// Get attachment by ID
  Future<BillAttachmentModel?> getAttachmentById(String attachmentId) async {
    try {
      final doc = await _firestore
          .collection(_billAttachmentsCollection)
          .doc(attachmentId)
          .get();

      if (doc.exists) {
        return BillAttachmentModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get attachment: $e');
    }
  }

  /// Update attachment description
  Future<void> updateAttachmentDescription(String attachmentId, String description) async {
    try {
      await _firestore
          .collection(_billAttachmentsCollection)
          .doc(attachmentId)
          .update({'description': description});
    } catch (e) {
      throw Exception('Failed to update attachment description: $e');
    }
  }

  /// Delete an attachment
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      // Get attachment document to get storage path
      final doc = await _firestore
          .collection(_billAttachmentsCollection)
          .doc(attachmentId)
          .get();
          
      if (!doc.exists) {
        throw Exception('Attachment not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final storagePath = data['storagePath'] as String?;

      // Delete from Firebase Storage if path exists
      if (storagePath != null) {
        await _storage.ref().child(storagePath).delete();
      }

      // Delete from Firestore
      await _firestore
          .collection(_billAttachmentsCollection)
          .doc(attachmentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete attachment: $e');
    }
  }

  /// Delete all attachments for a transaction
  Future<void> deleteTransactionAttachments(String transactionId) async {
    try {
      final attachments = await getTransactionAttachments(transactionId);
      
      for (final attachment in attachments) {
        await deleteAttachment(attachment.id);
      }
    } catch (e) {
      throw Exception('Failed to delete transaction attachments: $e');
    }
  }

  /// Stream attachments for a transaction
  Stream<List<BillAttachmentModel>> streamTransactionAttachments(String transactionId) {
    return _firestore
        .collection(_billAttachmentsCollection)
        .where('transactionId', isEqualTo: transactionId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BillAttachmentModel.fromDocument(doc))
            .toList());
  }

  /// Get total storage size used by all attachments
  Future<int> getTotalStorageSize() async {
    try {
      final querySnapshot = await _firestore
          .collection(_billAttachmentsCollection)
          .get();

      int totalSize = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalSize += (data['fileSize'] as int? ?? 0);
      }
      return totalSize;
    } catch (e) {
      throw Exception('Failed to get total storage size: $e');
    }
  }

  /// Clean up orphaned attachments (attachments without corresponding transactions)
  Future<List<String>> cleanupOrphanedAttachments() async {
    try {
      final attachments = await _firestore
          .collection(_billAttachmentsCollection)
          .get();

      final orphanedIds = <String>[];

      for (final doc in attachments.docs) {
        final attachment = BillAttachmentModel.fromDocument(doc);
        
        // Check if transaction still exists
        final transactionDoc = await _firestore
            .collection('transactions')
            .doc(attachment.transactionId)
            .get();

        if (!transactionDoc.exists) {
          orphanedIds.add(attachment.id);
          await deleteAttachment(attachment.id);
        }
      }

      return orphanedIds;
    } catch (e) {
      throw Exception('Failed to cleanup orphaned attachments: $e');
    }
  }
}
