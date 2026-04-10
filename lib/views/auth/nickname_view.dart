import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifier/auth_notifier.dart';

class NicknameView extends ConsumerStatefulWidget {
  const NicknameView({super.key});

  @override
  ConsumerState<NicknameView> createState() => _NicknameViewState();
}

class _NicknameViewState extends ConsumerState<NicknameView> {
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 상태 리슨: 자격 확인 단계로 넘어갔을 때 이동
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.step == AuthStep.onboardingQualification) {
        context.push('/qualification');
      }
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Step Indicator
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '닉네임을 설정해주세요',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '다른 사용자들에게 표시될 이름입니다.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              TextField(
                controller: _nicknameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '닉네임 (2~10자)',
                ),
              ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  final nickname = _nicknameController.text.trim();
                  if (nickname.length >= 2) {
                    authNotifier.setNickname(nickname);
                  }
                },
                child: const Text('다음으로'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
