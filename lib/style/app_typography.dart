import 'package:flutter/material.dart';

/// 앱에서 사용하는 타이포그래피 시스템
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // Main Headings (대제목(표제)) - Pretendard 폰트
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold (700)
    height: 1.3, // 130%
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold (700)
    height: 1.3, // 130%
  );

  // Sub-items Titles (하위 항목의 제목) - Pretendard 폰트
  static const TextStyle title1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.2, // 140%
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22,
    fontWeight: FontWeight.w700, // Bold (700)
    height: 1.2, // 140%
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.3, // 140%
  );

  static const TextStyle title4 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.4, // 140%
  );

  static const TextStyle title5 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium (500)
    height: 1.4, // 140%
  );

  // Subtitles, Auxiliary to Titles (부가 제목, Title의 보조) - Pretendard 폰트
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium (500)
    height: 1.4, // 140%
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.4, // 140%    
  );

  // Body Content (본문 내용(간단한 내용~ 장문글)) - Pretendard 폰트
  static const TextStyle body1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium (500)
    height: 1.4, // 140%
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular (400)
    height: 1.4, // 140%
  );

  static const TextStyle body3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium (500)
    height: 1.4, // 140%
  );

  static const TextStyle body4 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular (400)
    height: 1.4, // 140%
  );

  // Captions (부가 설명) - Pretendard 폰트
  static const TextStyle caption1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 13,
    fontWeight: FontWeight.w400, // Regular (400)
    height: 1.5, // 150%
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular (400)
    height: 1.5, // 150%
  );

  // Button Text (버튼 텍스트) - Pretendard 폰트
  static const TextStyle button1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.0, // 100%
  );

  static const TextStyle button2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.0, // 100%
  );

  static const TextStyle button3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.0, // 100%
  );

    static const TextStyle button4 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500, // SemiBold (500)
    height: 1.0, // 100%
  );


  // Suite 폰트를 사용하는 스타일들
  static const TextStyle suiteHeading1 = TextStyle(
    fontFamily: 'Suite',
    fontSize: 32,
    fontWeight: FontWeight.w800, // ExtraBold (800)
    height: 1.3,
  );

  static const TextStyle suiteTitle = TextStyle(
    fontFamily: 'Suite',
    fontSize: 28,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.4,
  );
  
  static const TextStyle suiteTitle1 = TextStyle(
    fontFamily: 'Suite',
    fontSize: 26,
    fontWeight: FontWeight.w600, // SemiBold (600)
    height: 1.3,
  );
  
  static const TextStyle suiteBody1 = TextStyle(
    fontFamily: 'Suite',
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium (500)
    height: 1.3,
  );
  
  // Helper methods for creating variants
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

