import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/signup_view.dart';
import '../../views/auth/nickname_view.dart';
import '../../views/auth/qualification_view.dart';
import '../../views/home/home_view.dart';
import '../../notifier/auth_notifier.dart';

part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final step = authState.step;
      final loggingIn = state.matchedLocation == '/login';

      // 1. 초기 로딩 중에는 리다이렉트하지 않음
      if (step == AuthStep.loading) return null;

      // 2. 로그인이 안 된 상태
      final isNotLoggedIn = step == AuthStep.initial || step == AuthStep.error;
      if (isNotLoggedIn) {
        // 로그인 페이지가 아닌 곳에 있다면 로그인 페이지로 이동 ㄴ
        return loggingIn ? null : '/login';
      }

      // 3. 로그인이 된 상태 (성공 단계)
      if (step == AuthStep.success) {
        // 로그인 페이지에 있다면 홈으로 이동
        return loggingIn ? '/home' : null;
      }

      // 4. 온보딩 중인 경우 (강제로 해당 페이지에 머물게 하거나 리다이렉트)
      if (step == AuthStep.onboardingNickname &&
          state.matchedLocation != '/nickname') {
        return '/nickname';
      }
      if (step == AuthStep.onboardingQualification &&
          state.matchedLocation != '/qualification') {
        return '/qualification';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpView()),
      GoRoute(
        path: '/nickname',
        builder: (context, state) => const NicknameView(),
      ),
      GoRoute(
        path: '/qualification',
        builder: (context, state) => const QualificationView(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeView()),
    ],
  );
}
