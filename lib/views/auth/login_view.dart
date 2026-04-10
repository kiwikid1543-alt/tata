// lib/views/auth/login_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/phone_number_formatter.dart';
import '../../notifier/auth_notifier.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // 인증 성공 시 홈으로 이동
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.step == AuthStep.success) {
        context.go('/home');
      } else if (next.step == AuthStep.onboardingNickname) {
        context.go('/nickname');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                '만나서 반가워요!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '전화번호로 간편하게 시작하세요.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              const SizedBox(height: 48),

              // 전화번호 입력 필드
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  PhoneNumberFormatter(),
                  LengthLimitingTextInputFormatter(13),
                ],
                enabled:
                    authState.step == AuthStep.initial ||
                    authState.step == AuthStep.error ||
                    authState.step == AuthStep.smsSent,
                decoration: const InputDecoration(
                  // hintText: '010-1234-5678',
                  prefixIcon: Icon(Icons.phone_android, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // OTP 입력 필드 (인증번호 요청 중이거나 발송된 경우 표시)
              if (authState.step == AuthStep.smsSent ||
                  authState.step == AuthStep.authenticating ||
                  (authState.step == AuthStep.error &&
                      authState.verificationId != null))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      autofocus: true, // 즉시 입력 가능하도록 포커스
                      decoration: const InputDecoration(
                        hintText: '인증번호 6자리 입력',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        counterText: '',
                      ),
                    ),
                    if (authState.step == AuthStep.error)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          '인증번호를 확인해주세요',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),

              const SizedBox(height: 16),

              // 버튼 영역
              // 아직 요청 전(initial/error)이면서 로딩 중이 아닐 때만 '발송' 버튼 노출
              if (authState.verificationId == null &&
                  authState.step != AuthStep.authenticating)
                ElevatedButton(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isNotEmpty) {
                      authNotifier.requestOtp(phone);
                    }
                  },
                  child: const Text('인증번호 받기'),
                )
              else
                // 인증번호 요청 중이거나 이미 발송된 경우
                ElevatedButton(
                  onPressed:
                      (authState.step == AuthStep.authenticating &&
                          authState.verificationId != null)
                      ? null // 실제 인증 확인 중일 때만 비활성화
                      : () {
                          final otp = _otpController.text.trim();
                          if (otp.length == 6) {
                            authNotifier.loginWithOtp(otp);
                          }
                        },
                  child:
                      (authState.step == AuthStep.authenticating &&
                          authState.verificationId != null)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('인증'),
                ),

              const SizedBox(height: 24),

              // 하단 안내
              Center(
                child: Text(
                  '인증번호가 오지 않나요? 다시 시도해 주세요.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
