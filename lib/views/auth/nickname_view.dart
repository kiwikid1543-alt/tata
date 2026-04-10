import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tata/core/theme/app_theme.dart';
import '../../core/utils/app_snackbar.dart';
import '../../notifier/auth_notifier.dart';

class NicknameView extends ConsumerStatefulWidget {
  const NicknameView({super.key});

  @override
  ConsumerState<NicknameView> createState() => _NicknameViewState();
}

class _NicknameViewState extends ConsumerState<NicknameView> {
  final _nicknameController = TextEditingController();
  String _statusMessage = '';
  Color _statusColor = Colors.grey;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateNickname);
  }

  void _validateNickname() {
    final text = _nicknameController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _statusMessage = '';
        _isValid = false;
      } else if (text.length < 2 || text.length > 10) {
        _statusMessage = '2글자에서 10글자 사이로 입력해주세요';
        _statusColor = Colors.red;
        _isValid = false;
      } else if (text == 'admin' || text == 'test') {
        // 데모용 중복 검사 시뮬레이션
        _statusMessage = '이미 사용 중인 닉네임입니다';
        _statusColor = Colors.red;
        _isValid = false;
      } else {
        _statusMessage = '사용 가능한 닉네임입니다';
        _statusColor = AppTheme.primaryColor; // AppTheme.accentColor 가이드 참고
        _isValid = true;
      }
    });
  }

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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        //   onPressed: () => context.pop(),
        // ),
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
                decoration: const InputDecoration(hintText: '닉네임 (2~10자)'),
              ),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  final nickname = _nicknameController.text.trim();
                  if (nickname.length < 2 || nickname.length > 10) {
                    AppSnackBar.show(
                      context,
                      message: '2글자에서 10글자 사이로 입력해주세요',
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  if (!_isValid) {
                    AppSnackBar.show(
                      context,
                      message: '닉네임을 다시 확인해주세요',
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  authNotifier.setNickname(nickname);
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
