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

              // 에러 메시지 표시
              if (authState.step == AuthStep.error)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authState.errorMessage ?? '오류가 발생했습니다.',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // 전화번호 입력 필드
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  PhoneNumberFormatter(),
                  LengthLimitingTextInputFormatter(13),
                ],
                enabled: authState.step == AuthStep.initial ||
                    authState.step == AuthStep.error,
                decoration: const InputDecoration(
                  hintText: '010-1234-5678',
                  prefixIcon: Icon(Icons.phone_android, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // OTP 입력 필드 (인증번호 발송된 경우만 표시)
              if (authState.step == AuthStep.smsSent ||
                  authState.step == AuthStep.authenticating)
                Column(
                  children: [
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: '인증번호 6자리 입력',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

              const SizedBox(height: 16),

              // 버튼 영역
              if (authState.step == AuthStep.initial ||
                  authState.step == AuthStep.error)
                ElevatedButton(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isNotEmpty) {
                      authNotifier.requestOtp(phone);
                    }
                  },
                  child: authState.step == AuthStep.authenticating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('인증번호 받기'),
                )
              else if (authState.step == AuthStep.smsSent ||
                  authState.step == AuthStep.authenticating)
                ElevatedButton(
                  onPressed: authState.step == AuthStep.authenticating
                      ? null
                      : () {
                          final otp = _otpController.text.trim();
                          if (otp.length == 6) {
                            authNotifier.loginWithOtp(otp);
                          }
                        },
                  child: authState.step == AuthStep.authenticating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('로그인'),
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
