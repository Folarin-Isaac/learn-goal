import 'package:lengoal/features/classes/data/models/class_session_model.dart';
import 'package:lengoal/features/classes/domain/entities/class_material_file.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

class LengoalClassModel extends LengoalClass {
  const new({
    required super.id,
    required super.cohortName,
    required super.educatorName,
    required super.price,
    required super.isFree,
    required super.isSubscribed,
    super.description,
    super.educatorId,
    super.educatorImageUrl,
    super.educatorTierName,
    super.avatar,
    super.useEducatorAsCoverImage,
    super.bgColorKey,
    super.startDate,
    super.endDate,
    super.discountPrice,
    super.numberOfSubscribers,
    super.isSubscriptionClosed,
    super.goalName,
    super.categoryName,
    super.guaranteeBadge,
    super.refundPolicyDescription,
    super.sessions,
    super.materials,
  });

  // LandingClassDto from /Landing/learner/* — a slimmer card shape with
  // different field names and no materials; GetClass fills those in on
  // the details page.
  factory fromLandingJson(Map<String, dynamic> json) {
    final refund = json['refundPolicy'] as Map<String, dynamic>?;
    final outline = json['classOutline'] as List<dynamic>? ?? const [];
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final isDiscounted = json['isDiscounted'] as bool? ?? false;

    return LengoalClassModel(
      id: json['classId'] as String,
      cohortName: json['cohortName'] as String? ?? '',
      educatorName: json['educatorName'] as String? ?? '',
      price: price,
      isFree: price <= 0,
      isSubscribed: json['enrollmentStatus'] as bool? ?? false,
      description: json['description'] as String?,
      educatorId: json['educatorId'] as String?,
      educatorImageUrl: json['educatorProfilePicture'] as String?,
      educatorTierName: json['educatorTierName'] as String?,
      avatar: json['cohortThumbnail'] as String?,
      useEducatorAsCoverImage:
          json['useEducatorAsCoverImage'] as bool? ?? false,
      bgColorKey: json['bgColorKey'] as String?,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
      discountPrice: isDiscounted
          ? (json['discountPrice'] as num?)?.toDouble()
          : null,
      numberOfSubscribers: json['subscribedLearnersCount'] as int? ?? 0,
      goalName: json['goal'] as String?,
      categoryName: json['category'] as String?,
      guaranteeBadge: refund?['guaranteeBadge'] as String?,
      refundPolicyDescription: refund?['policyDescription'] as String?,
      sessions: outline
          .cast<Map<String, dynamic>>()
          .where((session) => session['isDeleted'] != true)
          .map(ClassSessionModel.fromJson)
          .toList(),
    );
  }

  factory fromJson(Map<String, dynamic> json) {
    final goal = json['goal'] as Map<String, dynamic>?;
    final category = json['classCategory'] as Map<String, dynamic>?;
    final pricing = json['pricingModel'] as Map<String, dynamic>?;
    final discount = json['discount'] as Map<String, dynamic>?;
    final refund = json['refundPolicy'] as Map<String, dynamic>?;
    final outline = json['classOutline'] as List<dynamic>? ?? const [];
    final materials = json['classMaterials'] as List<dynamic>? ?? const [];

    final price = (json['pricePerLearner'] as num?)?.toDouble() ?? 0;
    final isDiscounted = discount?['isDiscounted'] as bool? ?? false;

    return LengoalClassModel(
      id: json['id'] as String,
      cohortName: json['cohortName'] as String? ?? '',
      educatorName: json['educatorName'] as String? ?? '',
      price: price,
      isFree: (pricing?['isFree'] as bool? ?? false) || price <= 0,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      description: json['description'] as String?,
      educatorId: json['educatorId'] as String?,
      educatorImageUrl: json['educatorImageUrl'] as String?,
      educatorTierName: json['educatorTierName'] as String?,
      avatar: json['avatar'] as String?,
      useEducatorAsCoverImage:
          json['useEducatorAsCoverImage'] as bool? ?? false,
      bgColorKey: json['bgColorKey'] as String?,
      startDate: DateTime.tryParse(json['classStartDate'] as String? ?? ''),
      endDate: DateTime.tryParse(json['classEndDate'] as String? ?? ''),
      discountPrice: isDiscounted
          ? (discount?['discountPrice'] as num?)?.toDouble()
          : null,
      numberOfSubscribers: json['numberOfSubscribers'] as int? ?? 0,
      isSubscriptionClosed: json['isSubscriptionClosed'] as bool? ?? false,
      goalName: goal?['name'] as String?,
      categoryName: category?['name'] as String?,
      guaranteeBadge: json['guaranteeBadge'] as String?,
      refundPolicyDescription: refund?['policyDescription'] as String?,
      sessions: outline
          .cast<Map<String, dynamic>>()
          .where((session) => session['isDeleted'] != true)
          .map(ClassSessionModel.fromJson)
          .toList(),
      materials: materials
          .cast<Map<String, dynamic>>()
          .where((material) => material['isDeleted'] != true)
          .map(
            (material) => ClassMaterialFile(
              id: material['id'] as String? ?? '',
              name: material['classMaterialName'] as String? ?? '',
              url: material['classMaterialUrl'] as String? ?? '',
              type: material['classMaterialType'] as int? ?? 0,
            ),
          )
          .toList(),
    );
  }
}
