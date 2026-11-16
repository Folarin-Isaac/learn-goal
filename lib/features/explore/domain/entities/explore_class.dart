import 'package:equatable/equatable.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

// The landing feed's card fields that LengoalClass doesn't carry.
class ExploreClass extends Equatable {
  const new({
    required this.lengoalClass,
    this.completion,
    this.enrollmentLimit = 0,
    this.availableSlots = 0,
  });

  final LengoalClass lengoalClass;

  // 0–1, or null when the feed didn't send it.
  final double? completion;
  final int enrollmentLimit;
  final int availableSlots;

  String? get tag {
    final goal = lengoalClass.goalName?.trim();
    if (goal != null && goal.isNotEmpty) return goal;
    final category = lengoalClass.categoryName?.trim();
    return (category == null || category.isEmpty) ? null : category;
  }

  int get filledSlots {
    if (enrollmentLimit <= 0) return lengoalClass.numberOfSubscribers;
    return (enrollmentLimit - availableSlots).clamp(0, enrollmentLimit);
  }

  @override
  List<Object?> get props => [
    lengoalClass,
    completion,
    enrollmentLimit,
    availableSlots,
  ];
}
