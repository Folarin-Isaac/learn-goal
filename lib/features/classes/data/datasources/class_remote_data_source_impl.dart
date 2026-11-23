import 'package:dio/dio.dart';
import 'package:lengoal/core/error/exceptions.dart';
import 'package:lengoal/core/network/api_client.dart';
import 'package:lengoal/core/utils/server_date.dart';
import 'package:lengoal/features/classes/data/class_api_endpoints.dart';
import 'package:lengoal/features/classes/data/datasources/class_remote_data_source.dart';
import 'package:lengoal/features/classes/data/models/class_educator_model.dart';
import 'package:lengoal/features/classes/data/models/lengoal_class_model.dart';
import 'package:lengoal/features/classes/domain/entities/class_attendance.dart';
import 'package:lengoal/features/classes/domain/entities/class_referral.dart';
import 'package:lengoal/features/classes/domain/entities/class_replay.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_access.dart';
import 'package:lengoal/features/classes/domain/entities/live_class_status.dart';

class ClassRemoteDataSourceImpl implements ClassRemoteDataSource {
  new(this._apiClient, {this._liveKitUrl = ''});

  final ApiClient _apiClient;
  final String _liveKitUrl;

  // Lists are rendered in full rather than paginated, so one large page
  // covers them. Each class payload is heavy, hence smaller than the
  // goal-setup catalogue page.
  static const int _pageSize = 50;

  @override
  Future<List<LengoalClassModel>> getSubscribedClasses({
    String? searchTerm,
    String? goalId,
  }) {
    return _getList(
      ClassApiEndpoints.subscribedClasses,
      searchTerm,
      goalId: goalId,
      forceSubscribed: true,
    );
  }

  // With a goal, QueryClassesForALearner returns that goal's approved
  // classes with a reliable isSubscribed. If the goal has none yet, fall
  // back to the learner landing feed (GetAllClasses is admin-only): the
  // goal's category narrows it, falling back to the full feed when that
  // category is empty too, and classes for the goal itself are ranked
  // first, so the section never goes empty.
  @override
  Future<List<LengoalClassModel>> getRecommendedClasses({
    String? categoryId,
    String? goalName,
    String? goalId,
    int? pageSize,
  }) async {
    if (goalId != null && goalId.isNotEmpty) {
      final forGoal = await _getApprovedForGoal(
        goalId,
        page: 1,
        pageSize: pageSize ?? _pageSize,
      );
      if (forGoal.items.isNotEmpty) return forGoal.items;
    }
    var classes = await _getLandingList(
      ClassApiEndpoints.recommendedClasses,
      pageSize: pageSize,
      extraParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'CategoryId': categoryId,
      },
    );
    if (classes.isEmpty && categoryId != null && categoryId.isNotEmpty) {
      classes = await _getLandingList(
        ClassApiEndpoints.recommendedClasses,
        pageSize: pageSize,
      );
    }
    final target = goalName?.trim().toLowerCase();
    if (target == null || target.isEmpty) return classes;
    bool matches(LengoalClassModel c) =>
        c.goalName?.trim().toLowerCase() == target;
    return [...classes.where(matches), ...classes.where((c) => !matches(c))];
  }

  // One page of the learner landing feed, for infinite scroll. The feed's
  // envelope reports hasNextPage; if it's ever missing, a full page is
  // taken to mean there may be more.
  @override
  Future<({List<LengoalClassModel> items, bool hasMore})>
  getRecommendedClassesPage({
    required int page,
    required int pageSize,
    String? categoryId,
    String? goalId,
  }) {
    if (goalId != null && goalId.isNotEmpty) {
      return _getApprovedForGoal(goalId, page: page, pageSize: pageSize);
    }
    return _getLandingPage(
      ClassApiEndpoints.recommendedClasses,
      page: page,
      pageSize: pageSize,
      extraParameters: {
        if (categoryId != null && categoryId.isNotEmpty)
          'CategoryId': categoryId,
      },
    );
  }

  @override
  Future<({List<LengoalClassModel> items, bool hasMore})> searchClasses(
    String searchTerm, {
    required int page,
    required int pageSize,
  }) {
    return _getLandingPage(
      ClassApiEndpoints.searchClasses,
      page: page,
      pageSize: pageSize,
      extraParameters: {'SearchTerm': searchTerm},
    );
  }

  // approvalStatus: 1 = Draft, 2 = Pending, 3 = Approved (confirmed with
  // the backend). The filter is sent as a parameter and re-applied here in
  // case the server ignores it. Classes that have already ended are
  // dropped, since a learner can't join them.
  static const int _approvedStatus = 3;

  Future<({List<LengoalClassModel> items, bool hasMore})> _getApprovedForGoal(
    String goalId, {
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.queryClassesForLearner,
        queryParameters: {
          'PageSize': pageSize,
          'PageNumber': page,
          'GoalId': goalId,
          'ApprovalStatus': _approvedStatus,
        },
      );
      final body = _checkSucceeded(response.data!);
      final rows = _unwrapList(body);
      final now = DateTime.now();
      final items = rows
          .where(
            (json) =>
                int.tryParse('${json['approvalStatus']}') == _approvedStatus,
          )
          .map(LengoalClassModel.fromJson)
          .where((c) => c.endDate == null || c.endDate!.isAfter(now))
          .toList();
      final hasNext = body['hasNextPage'];
      return (
        items: items,
        hasMore: hasNext is bool ? hasNext : rows.length >= pageSize,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<({List<LengoalClassModel> items, bool hasMore})> _getLandingPage(
    String path, {
    required int page,
    required int pageSize,
    Map<String, dynamic> extraParameters = const {},
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'PageSize': pageSize,
          'PageNumber': page,
          ...extraParameters,
        },
      );
      final body = _checkSucceeded(response.data!);
      final items = _unwrapList(body)
          .map(LengoalClassModel.fromLandingJson)
          .toList();
      final hasNext = body['hasNextPage'];
      return (
        items: items,
        hasMore: hasNext is bool ? hasNext : items.length >= pageSize,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<List<LengoalClassModel>> _getLandingList(
    String path, {
    int? pageSize,
    Map<String, dynamic> extraParameters = const {},
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'PageSize': pageSize ?? _pageSize,
          'PageNumber': 1,
          ...extraParameters,
        },
      );
      return _unwrapList(response.data!)
          .map(LengoalClassModel.fromLandingJson)
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<List<LengoalClassModel>> getSavedClasses({String? searchTerm}) {
    return _getList(ClassApiEndpoints.savedClasses, searchTerm);
  }

  @override
  Future<LengoalClassModel> getClass(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.classById(id),
      );
      return LengoalClassModel.fromJson(_unwrapObject(response.data!));
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> saveClass(String classId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ClassApiEndpoints.saveClass,
        data: {
          'classId': [classId],
        },
      );
      _checkSucceeded(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> unsaveClass(String classId) async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        ClassApiEndpoints.unsaveClass,
        data: {
          'classId': [classId],
        },
      );
      _checkSucceeded(response.data!);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<List<ClassEducatorModel>> getClassEducators(String classId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.classEducators(classId),
      );
      return _unwrapList(response.data!)
          .map(ClassEducatorModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<ClassReplay> getClassReplay(String classOutlineId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.classReplay,
        queryParameters: {'ClassOutlineId': classOutlineId},
      );
      final data = _unwrapObject(response.data!);
      final fileUrl = _nonEmpty(data['recordFileUrl']);
      final streamId = _nonEmpty(data['streamId']);
      if (fileUrl == null && streamId == null) {
        throw ServerException('This replay is not available yet.');
      }
      // streamId is a Mux playback ID: the web player loads this exact
      // manifest (confirmed from its network log), and it serves
      // adaptive quality, which suits mobile data better than the MP4.
      return ClassReplay(
        streamUrl: streamId == null
            ? null
            : ClassApiEndpoints.replayStream(streamId),
        fileUrl: fileUrl,
        posterUrl: streamId == null
            ? null
            : ClassApiEndpoints.replayPoster(streamId),
        topic: _nonEmpty(data['topic']),
        startDate: parseServerDate(data['startDate'] as String?),
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Unlike GetClassReferral, `data` here is the bare link string, with
  // the code carried in its `ref` query parameter.
  @override
  Future<ClassReferral> generateClassReferral(String classId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ClassApiEndpoints.generateReferral(classId),
      );
      final link = _checkSucceeded(response.data!)['data'];
      if (link is! String || link.isEmpty) {
        throw ServerException('Could not create a share link.');
      }
      return ClassReferral(
        referralCode: Uri.tryParse(link)?.queryParameters['ref'] ?? '',
        referralLink: link,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<ClassAttendance> getClassAttendance(String classId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.learnerAttendance(classId),
      );
      final data = _unwrapObject(response.data!);
      return ClassAttendance(
        totalSessions: (data['totalSessions'] as num?)?.toInt() ?? 0,
        attendedSessions: (data['attendedSessions'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // The web also sends userId, but the API spec's LiveKitQuery only has
  // classOutlineId (plus guest fields); the server identifies the learner
  // from the bearer token. `data` is the LiveKit access token.
  @override
  Future<LiveClassAccess> joinLiveClass(String classOutlineId) async {
    if (_liveKitUrl.isEmpty) {
      throw ServerException('Live classes are not available yet.');
    }
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ClassApiEndpoints.joinLiveClass,
        data: {'classOutlineId': classOutlineId},
      );
      final token = _nonEmpty(_checkSucceeded(response.data!)['data']);
      if (token == null) {
        throw ServerException('Could not join this class. Try again.');
      }
      return LiveClassAccess(serverUrl: _liveKitUrl, token: token);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<LiveClassStatus> getLiveClassStatus(String classOutlineId) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ClassApiEndpoints.liveClassStatus,
        queryParameters: {'classOutlineId': classOutlineId},
      );
      final data = _unwrapObject(response.data!);
      return LiveClassStatus(
        isRecording: data['isRecording'] == true,
        participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  String? _nonEmpty(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, dynamic> _unwrapObject(Map<String, dynamic> body) {
    final data = _checkSucceeded(body)['data'];
    if (data is! Map<String, dynamic>) {
      throw ServerException();
    }
    return data;
  }

  Future<List<LengoalClassModel>> _getList(
    String path,
    String? searchTerm, {
    String? goalId,
    bool forceSubscribed = false,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'PageSize': _pageSize,
          'PageNumber': 1,
          if (searchTerm != null && searchTerm.isNotEmpty)
            'SearchTerm': searchTerm,
          if (goalId != null && goalId.isNotEmpty) 'GoalId': goalId,
        },
      );
      return _unwrapList(response.data!)
          .map(
            (json) => LengoalClassModel.fromJson(
              json,
              forceSubscribed: forceSubscribed,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  // Envelopes differ per endpoint: subscribed-classes returns
  // { data: [...] }, saved classes adds paging fields alongside, and
  // GetAllClasses nests a second envelope at data.data. Unwrap until a
  // list turns up, checking `succeeded` at each level since failures can
  // arrive as HTTP 200.
  List<Map<String, dynamic>> _unwrapList(Map<String, dynamic> body) {
    final data = _checkSucceeded(body)['data'];
    if (data is Map<String, dynamic>) return _unwrapList(data);
    return (data as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _checkSucceeded(Map<String, dynamic> body) {
    if (body['succeeded'] == false) {
      throw ServerException(
        body['message'] as String? ?? 'Something went wrong. Please try again.',
      );
    }
    return body;
  }

  Exception _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException();
    }
    if (e.response?.statusCode == 401) {
      return UnauthorizedException();
    }
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? data['message'] as String?
        : null;
    return ServerException(
      message ?? 'Something went wrong. Please try again.',
      e.response?.statusCode,
    );
  }
}
