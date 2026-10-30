import 'package:equatable/equatable.dart';
import 'package:lengoal/features/classes/domain/entities/class_material_file.dart';
import 'package:lengoal/features/classes/domain/entities/class_review.dart';
import 'package:lengoal/features/classes/domain/entities/class_session.dart';

class LengoalClass extends Equatable {
  const new({
    required this.id,
    required this.cohortName,
    required this.educatorName,
    required this.price,
    required this.isFree,
    required this.isSubscribed,
    this.description,
    this.educatorId,
    this.educatorImageUrl,
    this.educatorTierName,
    this.avatar,
    this.useEducatorAsCoverImage = false,
    this.bgColorKey,
    this.startDate,
    this.endDate,
    this.discountPrice,
    this.numberOfSubscribers = 0,
    this.isSubscriptionClosed = false,
    this.goalName,
    this.categoryName,
    this.guaranteeBadge,
    this.refundPolicyDescription,
    this.sessions = const [],
    this.materials = const [],
  });

  final String id;
  final String cohortName;
  final String educatorName;
  final double price;
  final bool isFree;
  final bool isSubscribed;

  // HTML from the class editor, e.g. "<p>...</p>".
  final String? description;
  final String? educatorId;
  final String? educatorImageUrl;
  final String? educatorTierName;
  final String? avatar;
  final bool useEducatorAsCoverImage;
  final String? bgColorKey;
  final DateTime? startDate;
  final DateTime? endDate;

  // Set only while an early-bird discount is active.
  final double? discountPrice;
  final int numberOfSubscribers;
  final bool isSubscriptionClosed;
  final String? goalName;
  final String? categoryName;
  final String? guaranteeBadge;
  final String? refundPolicyDescription;
  final List<ClassSession> sessions;
  final List<ClassMaterialFile> materials;

  String? get coverImageUrl {
    final url = useEducatorAsCoverImage ? educatorImageUrl : avatar;
    return (url == null || url.isEmpty) ? null : url;
  }

  double get effectivePrice => discountPrice ?? price;

  List<ClassReview> get reviews => [
    for (final session in sessions) ...session.reviews,
  ];

  @override
  List<Object?> get props => [
    id,
    cohortName,
    educatorName,
    price,
    isFree,
    isSubscribed,
    description,
    educatorId,
    educatorImageUrl,
    educatorTierName,
    avatar,
    useEducatorAsCoverImage,
    bgColorKey,
    startDate,
    endDate,
    discountPrice,
    numberOfSubscribers,
    isSubscriptionClosed,
    goalName,
    categoryName,
    guaranteeBadge,
    refundPolicyDescription,
    sessions,
    materials,
  ];
}
