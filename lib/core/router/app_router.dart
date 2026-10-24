import 'package:lengoal/core/core.dart';
import 'package:lengoal/core/router/app_page_transitions.dart';
import 'package:lengoal/core/router/go_router_refresh_stream.dart';
import 'package:lengoal/features/auth/auth.dart';
import 'package:lengoal/features/chats/chats.dart';
import 'package:lengoal/features/chats/presentation/models/chat_conversation.dart';
import 'package:lengoal/features/classes/classes.dart';
import 'package:lengoal/features/classes/presentation/models/class_detail.dart';
import 'package:lengoal/features/classes/presentation/models/class_quiz.dart';
import 'package:lengoal/features/classes/presentation/models/quiz_session.dart';
import 'package:lengoal/features/community/community.dart';
import 'package:lengoal/features/community/presentation/models/community_post.dart';
import 'package:lengoal/features/dashboard/dashboard.dart';
import 'package:lengoal/features/goal_setup/goal_setup.dart';
import 'package:lengoal/features/practice/practice.dart';
import 'package:lengoal/features/practice/presentation/models/practice_mock.dart';
import 'package:lengoal/features/practice/presentation/models/practice_subject.dart';
import 'package:lengoal/features/profile/profile.dart';

class AppRouter {
  new();

  static final AuthRepository _authRepository = getIt<AuthRepository>();

  static final GoRouter router = GoRouter(
    navigatorKey: AppSnackbar.navigatorKey,
    initialLocation: RoutePaths.login,
    refreshListenable: GoRouterRefreshStream(_authRepository.authStatusStream),
    redirect: (context, state) {
      final status = _authRepository.currentAuthStatus;
      // Every route reachable while signed out: the register/OTP
      // flow plus the forgot-password flow.
      final isPublicRoute =
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.otpVerify ||
          state.matchedLocation == RoutePaths.emailConfirmed ||
          state.matchedLocation == RoutePaths.forgotPassword ||
          state.matchedLocation == RoutePaths.resetPasswordSent ||
          state.matchedLocation == RoutePaths.resetPassword ||
          state.matchedLocation == RoutePaths.resetPasswordSuccess;

      if (status == AuthStatus.authenticated && isPublicRoute) {
        // `first=true` tells GoalCategoryPage this is forced first-login,
        // not a voluntary push — redirects can't pass `extra`.
        return _authRepository.needsGoalSetup
            ? '${RoutePaths.goalCategory}?first=true'
            : RoutePaths.dashboard;
      }
      if (status == AuthStatus.unauthenticated && !isPublicRoute) {
        return RoutePaths.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) =>
            AppPageTransitions.build(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        pageBuilder: (context, state) =>
            AppPageTransitions.build(state: state, child: const RegisterPage()),
      ),
      GoRoute(
        path: RoutePaths.otpVerify,
        name: RouteNames.otpVerify,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: OtpVerificationPage(email: state.extra! as String),
        ),
      ),
      GoRoute(
        path: RoutePaths.emailConfirmed,
        name: RouteNames.emailConfirmed,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: EmailConfirmedPage(email: state.extra! as String),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.resetPasswordSent,
        name: RouteNames.resetPasswordSent,
        pageBuilder: (context, state) {
          final args = state.extra! as ({String email, String token});
          return AppPageTransitions.build(
            state: state,
            child: ResetPasswordSentPage(email: args.email, token: args.token),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.resetPassword,
        name: RouteNames.resetPassword,
        pageBuilder: (context, state) {
          final args = state.extra! as ({String email, String token});
          return AppPageTransitions.build(
            state: state,
            child: ResetPasswordPage(email: args.email, token: args.token),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.resetPasswordSuccess,
        name: RouteNames.resetPasswordSuccess,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const ResetPasswordSuccessPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.myClasses,
        name: RouteNames.myClasses,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const MyClassesPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.recommendedClasses,
        name: RouteNames.recommendedClasses,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const RecommendedClassesPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.calendar,
        name: RouteNames.calendar,
        pageBuilder: (context, state) =>
            AppPageTransitions.build(state: state, child: const CalendarPage()),
      ),
      GoRoute(
        path: RoutePaths.classesHub,
        name: RouteNames.classesHub,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const MyClassesHubPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.classDetails,
        name: RouteNames.classDetails,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: ClassDetailsPage(detail: state.extra! as ClassDetail),
        ),
      ),
      GoRoute(
        path: RoutePaths.quizIntro,
        name: RouteNames.quizIntro,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: QuizIntroPage(quiz: state.extra! as ClassQuiz),
        ),
      ),
      GoRoute(
        path: RoutePaths.quizTaking,
        name: RouteNames.quizTaking,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: QuizTakingPage(session: state.extra! as QuizSession),
        ),
      ),
      GoRoute(
        path: RoutePaths.quizResults,
        name: RouteNames.quizResults,
        pageBuilder: (context, state) {
          final args =
              state.extra! as ({QuizSession session, Map<int, int> answers});
          return AppPageTransitions.build(
            state: state,
            child: QuizResultsPage(
              session: args.session,
              answers: args.answers,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.quizReview,
        name: RouteNames.quizReview,
        pageBuilder: (context, state) {
          final args =
              state.extra!
                  as ({
                    QuizSession session,
                    Map<int, int> answers,
                    int startIndex,
                  });
          return AppPageTransitions.build(
            state: state,
            child: QuizReviewPage(
              session: args.session,
              answers: args.answers,
              startIndex: args.startIndex,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.payment,
        name: RouteNames.payment,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: PaymentPage(detail: state.extra! as ClassDetail),
        ),
      ),
      GoRoute(
        path: RoutePaths.paymentSuccess,
        name: RouteNames.paymentSuccess,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: PaymentSuccessPage(detail: state.extra! as ClassDetail),
        ),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        pageBuilder: (context, state) =>
            AppPageTransitions.build(state: state, child: const ProfilePage()),
      ),
      GoRoute(
        path: RoutePaths.updateProfile,
        name: RouteNames.updateProfile,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: UpdateProfilePage(profile: state.extra! as LearnerProfile),
        ),
      ),
      GoRoute(
        path: RoutePaths.support,
        name: RouteNames.support,
        pageBuilder: (context, state) =>
            AppPageTransitions.build(state: state, child: const SupportPage()),
      ),
      GoRoute(
        path: RoutePaths.subscriptionHistory,
        name: RouteNames.subscriptionHistory,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const SubscriptionHistoryPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.practice,
        name: RouteNames.practice,
        pageBuilder: (context, state) =>
            AppPageTransitions.build(state: state, child: const PracticePage()),
      ),
      GoRoute(
        path: RoutePaths.practiceTopic,
        name: RouteNames.practiceTopic,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: PracticeTopicPage(topic: state.extra! as PracticeTopic),
        ),
      ),
      GoRoute(
        path: RoutePaths.practiceMockDetail,
        name: RouteNames.practiceMockDetail,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: PracticeMockDetailPage(mock: state.extra! as PracticeMock),
        ),
      ),
      GoRoute(
        path: RoutePaths.practiceMockIntro,
        name: RouteNames.practiceMockIntro,
        pageBuilder: (context, state) {
          final args =
              state.extra! as ({PracticeMock mock, PracticeTopic topic});
          return AppPageTransitions.build(
            state: state,
            child: PracticeMockIntroPage(mock: args.mock, topic: args.topic),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.practiceSession,
        name: RouteNames.practiceSession,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: PracticeSessionPage(topic: state.extra! as PracticeTopic),
        ),
      ),
      GoRoute(
        path: RoutePaths.practiceReview,
        name: RouteNames.practiceReview,
        pageBuilder: (context, state) {
          final args = state.extra! as ({PracticeTopic topic, int startIndex});
          return AppPageTransitions.build(
            state: state,
            child: PracticeReviewPage(
              topic: args.topic,
              startIndex: args.startIndex,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.community,
        name: RouteNames.community,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const CommunityPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.communityPostDetail,
        name: RouteNames.communityPostDetail,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: CommunityPostDetailPage(post: state.extra! as CommunityPost),
        ),
      ),
      GoRoute(
        path: RoutePaths.chats,
        name: RouteNames.chats,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: const ChatsListPage(),
        ),
      ),
      GoRoute(
        path: RoutePaths.chatThread,
        name: RouteNames.chatThread,
        pageBuilder: (context, state) => AppPageTransitions.build(
          state: state,
          child: ChatThreadPage(conversation: state.extra! as ChatConversation),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            // Kicks off the study-fields fetch immediately — nothing else
            // triggers it, so without this the field list sits on its
            // loading skeleton forever (GoalSetupStarted is otherwise only
            // re-dispatched by the error view's "Retry" button).
            create: (_) =>
                getIt<GoalSetupBloc>()..add(const GoalSetupStarted()),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: RoutePaths.goalCategory,
            name: RouteNames.goalCategory,
            pageBuilder: (context, state) => AppPageTransitions.build(
              state: state,
              child: const GoalCategoryPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.goalExam,
            name: RouteNames.goalExam,
            pageBuilder: (context, state) => AppPageTransitions.build(
              state: state,
              child: const GoalExamPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.goalStage,
            name: RouteNames.goalStage,
            pageBuilder: (context, state) => AppPageTransitions.build(
              state: state,
              child: const GoalStagePage(),
            ),
          ),
        ],
      ),
    ],
  );
}
