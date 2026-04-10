import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/nickname_view.dart';
import '../../views/auth/qualification_view.dart';
import '../../views/auth/qualification_view.dart';
import '../../views/auth/recommended_center_view.dart';
import '../../views/home/home_view.dart';
import '../../views/splash/splash_view.dart';
import '../../notifier/auth_notifier.dart';

part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final listenable = RouterNotifier(ref);
  ref.onDispose(() => listenable.dispose());

  return GoRouter(
    initialLocation: '/', // 스플래시 처리를 위해 루트에서 시작
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final step = authState.step;
      final matchedLocation = state.matchedLocation;

      // 1. 초기 로딩 중에는 / (스플래시) 유지
      if (step == AuthStep.loading) {
        return matchedLocation == '/' ? null : '/';
      }

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
        if (matchedLocation != '/home') {
          return '/home';
        }
        return null;
      }

      // 4. 온보딩 단계 가드 (잘못된 접근 차단)
      final isOnboardingPath = matchedLocation == '/nickname' || 
                              matchedLocation == '/qualification' || 
                              matchedLocation == '/recommended-center';

      if (isOnboardingPath && isNotLoggedIn) {
        return '/login';
      }

      // 5. 이미 로그인된 유저의 단계별 강제 리다이렉트 (온보딩 필수 관문)
      if (step == AuthStep.onboardingNickname && matchedLocation != '/nickname') {
        return '/nickname';
      }
      if (step == AuthStep.onboardingQualification && matchedLocation != '/qualification') {
        return '/qualification';
      }
      if (step == AuthStep.onboardingRecommendation && matchedLocation != '/recommended-center') {
        return '/recommended-center';
      }

      return null;
    },
    routes: [
      // 스플래시 화면: 초기 세션 체크 시 보여짐
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      GoRoute(
        path: '/nickname',
        builder: (context, state) => const NicknameView(),
      ),
      GoRoute(
        path: '/qualification',
        builder: (context, state) => const QualificationView(),
      ),
      GoRoute(
        path: '/recommended-center',
        builder: (context, state) => const RecommendedCenterView(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeView()),
    ],
  );
}

/// AuthNotifier의 상태 변화를 GoRouter에 알리기 위한 리스너 클래스
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      // 상태(Step)가 변했을 때만 라우터에 알림 (불필요한 리다이렉트 방지)
      if (previous?.step != next.step) {
        notifyListeners();
      }
    });
  }
}
