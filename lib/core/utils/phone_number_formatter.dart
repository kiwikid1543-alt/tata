import 'package:flutter/services.dart';

/// 한국 전화번호 형식(010-XXXX-XXXX)으로 자동 포맷팅하고
/// 삭제 시 하이픈을 무시하고 숫자를 지울 수 있도록 돕는 포매터입니다.
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    var oldText = oldValue.text;

    // 1. 삭제(Backspace) 동작인지 확인
    final isDeleting = newText.length < oldText.length;

    // 2. 삭제 시 '-'를 건너뛰고 앞의 숫자까지 지우는 로직
    if (isDeleting) {
      // 현재 삭제된 위치가 '-' 바로 뒤인 경우
      // 예: '010-' 에서 백스페이스를 눌러 '010'이 된 경우 -> '01'이 되어야 함
      if (oldValue.selection.start > 0 && 
          oldText[oldValue.selection.start - 1] == '-') {
        // 하이픈 앞의 숫자까지 지워진 새로운 텍스트 생성
        final leftPart = oldText.substring(0, oldValue.selection.start - 2);
        final rightPart = oldText.substring(oldValue.selection.start);
        newText = leftPart + rightPart;
        
        // 커서 위치 재계산
        final newCursorPosition = oldValue.selection.start - 2;
        
        // 다시 포맷팅을 적용하기 위해 recursive하게 처리하지 않고
        // 여기서 숫자만 뽑아서 아래 로직으로 전달
        final digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');
        return _applyFormat(digitsOnly, newCursorPosition);
      }
    }

    // 3. 입력 시 숫자만 추출하여 포맷 적용
    final digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');
    return _applyFormat(digitsOnly, newValue.selection.start);
  }

  TextEditingValue _applyFormat(String digits, int baseOffset) {
    String formatted = '';
    int cursorPosition = baseOffset;

    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 7) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else if (digits.length <= 11) {
      formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    } else {
      // 최대 11자 초과 시 잘라냄 (010-XXXX-XXXX)
      final truncated = digits.substring(0, 11);
      formatted = '${truncated.substring(0, 3)}-${truncated.substring(3, 7)}-${truncated.substring(7)}';
    }

    // 커서 위치 조정 로직
    // 입력/삭제에 따라 문자열 길이가 변하므로, 하이픈 개수 변화를 고려해 커서 위치 결정
    // 단순히 formatted.length를 사용하는 대신, 원본 숫자들이 위치한 상대적 위치를 계산하는 것이 정확하지만
    // 여기서는 단순화하여 끝에 오도록 하거나 입력 문자열 길이에 맞춤
    
    // 현재 구현에서는 사용자가 중간을 수정하는 경우를 고려하여 
    // digits 문자열에서 커서가 어디쯤 있었는지를 추적해야 함.
    // 하지만 일반적인 전화번호 입력(끝에서 계속 입력/삭제) 상황에서는 아래로 충분함.
    
    int finalOffset = formatted.length;
    
    // 사용자가 중간에서 지우거나 입력하는 경우를 위한 보정 (선택 사항)
    // 여기서는 간단하게 항상 끝으로 보냄 (대부분의 앱 동작 방식)
    // 만약 중간 수정을 완벽히 구현하려면 추가 로직이 필요함.

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: finalOffset),
    );
  }
}
