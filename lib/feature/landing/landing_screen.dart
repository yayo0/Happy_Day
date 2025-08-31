import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';
import '../on_boarding/on_boarding.dart';

import '../../main.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _showLogin = false;
  bool _loading = false;

  static const String _graphqlEndpoint = 'http://54.180.152.8/graphql/';

  Future<String?> _createKakaoTempUser() async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: _graphqlEndpoint,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final payload = {
        'query':
            'mutation { create_kakao_temp_user { success error user { id uuid } } }',
      };
      final res = await dio.post('', data: jsonEncode(payload));
      final Map<String, dynamic> data = res.data is String
          ? json.decode(res.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(res.data as Map);
      if (data['errors'] != null) {
        return null;
      }
      final Map<String, dynamic>? result =
          data['data']?['create_kakao_temp_user'] as Map<String, dynamic>?;
      if (result == null || result['success'] != true) {
        return null;
      }
      final Map<String, dynamic>? user =
          result['user'] as Map<String, dynamic>?;
      return user?['uuid'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _showLogin = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Happy Day!',
              style: AppTypography.suiteHeading1.copyWith(
                color: AppColors.primaryBase,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '같이 만들어 나가볼까요?',
              style: AppTypography.title3.copyWith(
                color: AppColors.textDarkest,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/icons/main2.png',
                width: 120,
                height: 147,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _showLogin ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 95,
                              height: 1,
                              color: AppColors.textLighter,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '간편 로그인으로 시작해요',
                          style: AppTypography.caption2.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 95,
                              height: 1,
                              color: AppColors.textLighter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 360,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() => _loading = true);
                              final uuid = await _createKakaoTempUser();
                              setState(() => _loading = false);
                              if (uuid != null) {
                                context.read<UserSession>().setUuid(uuid);
                                if (!mounted) return;
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginSuccessScreen(),
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('로그인에 실패했어요')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDDC3F),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFFFDDC3F),
                        disabledForegroundColor: Colors.black,
                        overlayColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: Image.asset(
                              'assets/icons/kakao.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _loading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  '카카오로 계속하기',
                                  style: AppTypography.button1.copyWith(
                                    color: Colors.black,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 로그인 성공 화면 (랜딩 → 카카오 로그인 성공 후 진입)
class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({super.key});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(builder: (context) => const MonsterIntroScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outlined,
                size: 60,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                '로그인에 성공했어요',
                style: AppTypography.suiteHeading1.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '이제부터 맞춤 선물을 찾아봐요',
                style: AppTypography.title4.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 로그인 후 소개 화면
class MonsterIntroScreen extends StatelessWidget {
  const MonsterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 4),
              Center(
                child: SizedBox(
                  width: 340,
                  height: 115,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/icons/6.png',
                          height: 92,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/icons/3.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/icons/4.png',
                          height: 84,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/icons/2.png',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/icons/7.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '위시가 모이면\n몬스터가 태어나요!',
                  style: AppTypography.suiteHeading1.copyWith(
                    color: AppColors.primaryBase,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 360,
                  height: 155,
                  padding: const EdgeInsets.fromLTRB(24, 17, 24, 17),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '처음에는 손톱만큼 작지만, 친구들이 함께할수록 쑥쑥 자라는 몬스터들. 응원의 말, 참여하는 손길이 더해질 때마다 몬스터는 힘을 얻어요. 목표가 채워지는 순간, 여러분의 마음이 몬스터로 바뀌어 눈앞에 나타난답니다. \n\n이제, 귀여운 몬스터들을 만나러 가 볼까요? ',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.textDarkest,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 360,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '시작할래요',
                    style: AppTypography.button2.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
