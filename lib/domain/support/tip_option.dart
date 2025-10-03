import 'package:equatable/equatable.dart';

class TipOption extends Equatable {
  const TipOption({
    required this.id,
    required this.label,
    required this.amount,
  });

  final String id;
  final String label;
  final int amount;

  @override
  List<Object?> get props => [id, label, amount];
}
