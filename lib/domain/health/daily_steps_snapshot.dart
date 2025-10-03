import 'package:equatable/equatable.dart';

class DailyStepsSnapshot extends Equatable {
  const DailyStepsSnapshot({
    required this.date,
    required this.steps,
  });

  final DateTime date;
  final int steps;

  bool get hasMetTarget => steps >= 8000;

  @override
  List<Object?> get props => [date, steps];
}
