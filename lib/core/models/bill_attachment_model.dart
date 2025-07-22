import 'package:cloud_firestore/cloud_firestore.dart';

class BillAttachmentModel {
  final String id;
  final String transactionId;
  final String fileName;
  final String originalFileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String? description;
  final DateTime uploadedAt;

  const BillAttachmentModel({
    required this.id,
    required this.transactionId,
    required this.fileName,
    required this.originalFileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    this.description,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'description': description,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory BillAttachmentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillAttachmentModel(
      id: doc.id,
      transactionId: data['transactionId']?.toString() ?? '',
      fileName: data['fileName']?.toString() ?? '',
      originalFileName: data['originalFileName']?.toString() ?? '',
      fileUrl: data['fileUrl']?.toString() ?? '',
      fileType: data['fileType']?.toString() ?? '',
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      description: data['description']?.toString(),
      uploadedAt: DateTime.parse(
        data['uploadedAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory BillAttachmentModel.fromMap(Map<String, dynamic> data) {
    return BillAttachmentModel(
      id: data['id']?.toString() ?? '',
      transactionId: data['transactionId']?.toString() ?? '',
      fileName: data['fileName']?.toString() ?? '',
      originalFileName: data['originalFileName']?.toString() ?? '',
      fileUrl: data['fileUrl']?.toString() ?? '',
      fileType: data['fileType']?.toString() ?? '',
      fileSize: (data['fileSize'] as num?)?.toInt() ?? 0,
      description: data['description']?.toString(),
      uploadedAt: DateTime.parse(
        data['uploadedAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  BillAttachmentModel copyWith({
    String? id,
    String? transactionId,
    String? fileName,
    String? originalFileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? description,
    DateTime? uploadedAt,
  }) {
    return BillAttachmentModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      description: description ?? this.description,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  bool get isImage {
    return fileType.startsWith('image/');
  }

  bool get isPdf {
    return fileType == 'application/pdf';
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  @override
  String toString() {
    return 'BillAttachmentModel(id: $id, fileName: $fileName, fileType: $fileType, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillAttachmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
