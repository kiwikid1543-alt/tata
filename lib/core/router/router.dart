import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/nickname_view.dart';
import '../../views/auth/qualification_view.dart';
import '../../views/home/home_view.dart';
import '../../notifier/auth_notifier.dart';

part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    // initialLocation을 '/'로 설정하고 스플래시를 처리할 수 있게 함
    initialLocation: '/login',
    // GoRouter 객체 재생성을 감지하기 위해 authState를 watch하지만,
    // redirect 내부에서 최신 상태를 기반으로 판단하므로 안정적입니다.
    redirect: (context, state) {
      final step = authState.step;
      final matchedLocation = state.matchedLocation;

      // 1. 초기 로딩 중에는 리다이렉트 하지 않음 (스플래시 화면 유지 등을 위해)
      if (step == AuthStep.loading) return null;

      // 2. 로그인이 안 된 상태
      final isNotLoggedIn = step == AuthStep.initial || step == AuthStep.error;
      if (isNotLoggedIn) {
        if (matchedLocation != '/login' && matchedLocation != '/signup') {
          return '/login';
        }
        return null;
      }

      // 3. 로그인이 된 상태 (성공 단계)
      if (step == AuthStep.success) {
        if (matchedLocation == '/login' || matchedLocation == '/signup') {
          return '/home';
        }
        return null;
      }

      // 4. 온보딩 단계 강제 리다이렉트
      if (step == AuthStep.onboardingNickname) {
        if (matchedLocation != '/nickname') return '/nickname';
      }
      if (step == AuthStep.onboardingQualification) {
        if (matchedLocation != '/qualification') return '/qualification';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
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
