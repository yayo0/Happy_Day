# 폰트 설치 가이드

이 폴더에는 앱에서 사용하는 커스텀 폰트들이 포함됩니다.

## 📁 필요한 폰트 파일들

### Pretendard 폰트
- `Pretendard-Regular.otf` - 기본 폰트
- `Pretendard-Medium.otf` - Medium (500)
- `Pretendard-SemiBold.otf` - SemiBold (600)
- `Pretendard-Bold.otf` - Bold (700)
- `Pretendard-Black.otf` - Black (900)

### Suite 폰트
- `SUITE-Regular.otf` - 기본 폰트
- `SUITE-Medium.otf` - Medium (500)
- `SUITE-SemiBold.otf` - SemiBold (600)
- `SUITE-Bold.otf` - Bold (700)
- `SUITE-ExtraBold.otf` - ExtraBold (800)
- `SUITE-Heavy.otf` - Heavy (900)

## 🚀 폰트 다운로드 방법

### 1. Pretendard 폰트
- **공식 사이트**: https://cactus.tistory.com/193
- **GitHub**: https://github.com/orioncactus/pretendard
- **CDN**: https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/

### 2. Suite 폰트
- **공식 사이트**: https://fonts.woff.org/woff2/SUITE
- **GitHub**: https://github.com/project-nerd/suite

## 📋 설치 단계

1. 위 링크에서 폰트 파일들을 다운로드
2. 이 폴더(`fonts/`)에 모든 폰트 파일을 복사
3. `flutter pub get` 실행하여 의존성 업데이트
4. 앱 재시작

## ⚠️ 주의사항

- 폰트 파일명이 정확히 일치해야 합니다
- 파일 확장자(.otf, .ttf)가 올바른지 확인하세요
- 폰트 파일이 손상되지 않았는지 확인하세요

## 🔧 문제 해결

### 폰트가 적용되지 않는 경우:
1. `flutter clean` 실행
2. `flutter pub get` 실행
3. 앱 완전 재시작
4. 폰트 파일 경로 확인

### 빌드 에러가 발생하는 경우:
1. 폰트 파일명 확인
2. `pubspec.yaml`의 폰트 설정 확인
3. 폰트 파일이 올바른 위치에 있는지 확인
