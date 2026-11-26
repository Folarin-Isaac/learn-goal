import 'package:lengoal/core/utils/server_date.dart';
import 'package:lengoal/features/classes/data/models/class_session_model.dart';
import 'package:lengoal/features/classes/domain/entities/class_discount.dart';
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
    super.discount,
    super.numberOfSubscribers,
    super.isSubscriptionClosed,
    super.goalName,
    super.categoryName,
    super.guaranteeBadge,
    super.refundPolicyDescription,
    super.accessEndsAt,
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
    final discountDto = json['discount'] as Map<String, dynamic>?;
    final isDiscounted =
        discountDto?['isDiscounted'] as bool? ??
        json['isDiscounted'] as bool? ??
        false;
    final discountPrice =
        (discountDto?['discountPrice'] as num?)?.toDouble() ??
        (json['discountPrice'] as num?)?.toDouble();

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
      startDate: parseServerDate(json['startDate'] as String?),
      endDate: parseServerDate(json['endDate'] as String?),
      discountPrice: isDiscounted ? discountPrice : null,
      discount: isDiscounted && discountPrice != null
          ? _discountTerms(
              discountDto,
              null,
              flatPercentage: json['discountPercentage'],
              flatExpiry: json['earlyBirdExpiry'],
            )
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

  // subscribed-classes rows can carry isSubscribed: false, so callers
  // reading that endpoint pass forceSubscribed to trust the endpoint
  // over the flag.
  factory fromJson(Map<String, dynamic> json, {bool forceSubscribed = false}) {
    final goal = json['goal'] as Map<String, dynamic>?;
    final category = json['classCategory'] as Map<String, dynamic>?;
    final pricing = json['pricingModel'] as Map<String, dynamic>?;
    final discount = json['discount'] as Map<String, dynamic>?;
    final refund = json['refundPolicy'] as Map<String, dynamic>?;
    final outline = json['classOutline'] as List<dynamic>? ?? const [];
    final materials = json['classMaterials'] as List<dynamic>? ?? const [];

    final price = (json['pricePerLearner'] as num?)?.toDouble() ?? 0;
    final isDiscounted = discount?['isDiscounted'] as bool? ?? false;
    final discountPrice = (discount?['discountPrice'] as num?)?.toDouble();

    return LengoalClassModel(
      id: json['id'] as String,
      cohortName: json['cohortName'] as String? ?? '',
      educatorName: json['educatorName'] as String? ?? '',
      price: price,
      isFree: (pricing?['isFree'] as bool? ?? false) || price <= 0,
      isSubscribed: forceSubscribed || (json['isSubscribed'] as bool? ?? false),
      description: json['description'] as String?,
      educatorId: json['educatorId'] as String?,
      educatorImageUrl: json['educatorImageUrl'] as String?,
      educatorTierName: json['educatorTierName'] as String?,
      avatar: json['avatar'] as String?,
      useEducatorAsCoverImage:
          json['useEducatorAsCoverImage'] as bool? ?? false,
      bgColorKey: json['bgColorKey'] as String?,
      startDate: parseServerDate(json['classStartDate'] as String?),
      endDate: parseServerDate(json['classEndDate'] as String?),
      discountPrice: isDiscounted ? discountPrice : null,
      discount: isDiscounted && discountPrice != null
          ? _discountTerms(
              discount,
              pricing?['earlyBirdConditions'] as Map<String, dynamic>?,
            )
          : null,
      numberOfSubscribers: json['numberOfSubscribers'] as int? ?? 0,
      isSubscriptionClosed: json['isSubscriptionClosed'] as bool? ?? false,
      goalName: goal?['name'] as String?,
      categoryName: category?['name'] as String?,
      guaranteeBadge: json['guaranteeBadge'] as String?,
      refundPolicyDescription: refund?['policyDescription'] as String?,
      accessEndsAt: parseServerDate(
        json['postClassRestrictionDate'] as String?,
      ),
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

  // The server's ClassDiscountDto (`discount`) is preferred; it already
  // says whether the discount applies. pricingModel.earlyBirdConditions
  // (what the web reads) and the Landing flat fields fill any gaps. Only
  // called while the discount is active.
  static ClassDiscount? _discountTerms(
    Map<String, dynamic>? dto,
    Map<String, dynamic>? earlyBird, {
    Object? flatPercentage,
    Object? flatExpiry,
  }) {
    final percentage =
        (dto?['discountPercentage'] as num?)?.toDouble() ??
        (earlyBird?['discountPercentage'] as num?)?.toDouble() ??
        (flatPercentage as num?)?.toDouble();
    if (percentage == null || percentage <= 0) return null;
    final expiry =
        dto?['earlyBirdExpiry'] as String? ??
        earlyBird?['deadline'] as String? ??
        flatExpiry as String?;
    final byPeople =
        dto?['isNumberOfPeople'] as bool? ??
        earlyBird?['isNumberOfPeople'] as bool? ??
        false;
    final byDate =
        dto?['isTimePeriod'] as bool? ??
        earlyBird?['isTimePeriod'] as bool? ??
        expiry != null;
    final threshold =
        (dto?['thresholdValue'] as num?)?.toInt() ??
        (earlyBird?['thresholdValue'] as num?)?.toInt();
    return ClassDiscount(
      percentage: percentage,
      forFirstPeople: byPeople && threshold != null && threshold > 0
          ? threshold
          : null,
      validUntil: byDate ? parseServerDate(expiry) : null,
    );
  }
}
