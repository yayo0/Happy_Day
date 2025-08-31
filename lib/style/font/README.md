# 폰트 시스템 가이드

이 폴더에는 앱에서 사용하는 커스텀 폰트들이 포함됩니다.

## 📁 폰트 구조

```
lib/style/font/
├── pretendard/           # Pretendard 폰트 패밀리
│   ├── Pretendard-Thin.otf          # 100 (Thin)
│   ├── Pretendard-ExtraLight.otf    # 200 (ExtraLight)
│   ├── Pretendard-Light.otf         # 300 (Light)
│   ├── Pretendard-Regular.otf       # 400 (Regular)
│   ├── Pretendard-Medium.otf        # 500 (Medium)
│   ├── Pretendard-SemiBold.otf      # 600 (SemiBold)
│   ├── Pretendard-Bold.otf          # 700 (Bold)
│   ├── Pretendard-ExtraBold.otf     # 800 (ExtraBold)
│   └── Pretendard-Black.otf         # 900 (Black)
└── suite/                # Suite 폰트 패밀리
    ├── SUITE-Light.ttf               # 300 (Light)
    ├── SUITE-Regular.ttf             # 400 (Regular)
    ├── SUITE-Medium.ttf              # 500 (Medium)
    ├── SUITE-SemiBold.ttf            # 600 (SemiBold)
    ├── SUITE-Bold.ttf                # 700 (Bold)
    ├── SUITE-ExtraBold.ttf           # 800 (ExtraBold)
    └── SUITE-Heavy.ttf               # 900 (Heavy)
```

## 🎨 폰트 사용법

### Pretendard 폰트 (기본)
```dart
// 제목
AppTypography.heading1      // 32px, Black (900)
AppTypography.heading2      // 28px, Bold (700)
AppTypography.title1        // 24px, SemiBold (600)

// 본문
AppTypography.body1         // 16px, Medium (500)
AppTypography.body2         // 16px, Regular (400)

// 버튼
AppTypography.button1       // 20px, SemiBold (600)
AppTypography.button2       // 16px, SemiBold (600)
```

### Suite 폰트 (특별)
```dart
// 특별한 제목
AppTypography.suiteHeading1 // 32px, Heavy (900)
AppTypography.suiteTitle1   // 26px, SemiBold (600)
AppTypography.suiteBody1    // 18px, Medium (500)

// 추가 스타일
AppTypography.suiteLight    // 16px, Light (300)
AppTypography.suiteRegular  // 16px, Regular (400)
AppTypography.suiteExtraBold // 20px, ExtraBold (800)
```

## 🔧 폰트 가중치 매핑

### Pretendard
- **100**: Thin
- **200**: ExtraLight
- **300**: Light
- **400**: Regular
- **500**: Medium
- **600**: SemiBold
- **700**: Bold
- **800**: ExtraBold
- **900**: Black

### Suite
- **300**: Light
- **400**: Regular
- **500**: Medium
- **600**: SemiBold
- **700**: Bold
- **800**: ExtraBold
- **900**: Heavy

## ⚠️ 주의사항

- 폰트 파일명이 정확히 일치해야 합니다
- `pubspec.yaml`의 경로가 올바른지 확인하세요
- 폰트 파일이 손상되지 않았는지 확인하세요

## 🚀 적용 확인

1. `flutter clean` 실행
2. `flutter pub get` 실행
3. 앱 재시작
4. 폰트가 제대로 적용되었는지 확인

## 💡 팁

- 폰트 가중치를 변경하려면 `AppTypography.withWeight()` 메서드 사용
- 색상을 변경하려면 `AppTypography.withColor()` 메서드 사용
- 크기를 변경하려면 `AppTypography.withSize()` 메서드 사용
