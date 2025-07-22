// Custom exception classes for the MyMoney app
// This file defines specific exceptions for better error handling
library;

class AuthException implements Exception {
  const AuthException(this.message);
  
  final String message;
  
  @override
  String toString() => 'AuthException: $message';
}

class FirestoreException implements Exception {
  const FirestoreException(this.message);
  
  final String message;
  
  @override
  String toString() => 'FirestoreException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  
  final String message;
  
  @override
  String toString() => 'ValidationException: $message';
}

class NetworkException implements Exception {
  const NetworkException(this.message);
  
  final String message;
  
  @override
  String toString() => 'NetworkException: $message';
}
