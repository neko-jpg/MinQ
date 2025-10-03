import 'package:equatable/equatable.dart';

class SupportMessage extends Equatable {
  const SupportMessage({
    required this.role,
    required this.content,
  });

  final String role;
  final String content;

  bool get isUser => role == 'user';

  @override
  List<Object?> get props => [role, content];
}
