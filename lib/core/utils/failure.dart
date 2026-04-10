// lib/core/utils/failure.dart

class Failure {
  final String message;
  final dynamic originalError;

  const Failure(this.message, {this.originalError});

  @override
  String toString() => 'Failure: $message';
}
