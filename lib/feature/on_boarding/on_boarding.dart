import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';
import '../funding/make.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final int _maxNicknameLength = 15;
  final int _maxBrandLength = 30;

  // 선택된 카테고리들
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedTastes = {};
  final Set<String> _selectedGiftFactors = {};

  // 카테고리 데이터
  final List<String> _categories = [
    '인테리어',
    '신발',
    '악세서리',
    '옷',
    '코스메틱',
    '가전',
    '잡화',
    '음식',
    '리빙',
    '전시',
    '취미',
  ];

  // 취향 데이터
  final List<String> _tastes = [
    '깔끔',
    '키치',
    '귀여운',
    '모던한',
    '실용적인',
    '브랜드/로고',
    '미니멀',
    '따듯한/감성적인',
    '환경',
    '취미',
    '전시',
  ];

  // 선물 고를 때 고려사항 데이터
  final List<String> _giftFactors = [
    '가격대',
    '센스/취향 맞춤',
    '실용성',
    '특별한 경험',
    '패키징',
    '기념일·상징적',
    '오래 지속되는',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  static const String _graphqlEndpoint = 'http://54.180.152.8/graphql/';

  Future<bool> _saveProfile() async {
    try {
      final uuid = context.read<UserSession>().uuid;
      if (uuid == null) return false;

      final nickname = _nicknameController.text.trim();
      final category = _selectedCategories.join(',');
      final taste = _selectedTastes.join(',');
      final importance = _selectedGiftFactors.join(',');
      final brand = _brandController.text.trim();

      // uuid로 사용자 id 조회
      final dio = Dio(
        BaseOptions(
          baseUrl: _graphqlEndpoint,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final q1 = {
        'query': r'query($uuid: String!) { user_by_uuid(uuid: $uuid) { id } }',
        'variables': {'uuid': uuid},
      };
      final res1 = await dio.post('', data: jsonEncode(q1));
      final Map<String, dynamic> data1 = res1.data is String
          ? json.decode(res1.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(res1.data as Map);
      final dynamic idRaw = data1['data']?['user_by_uuid']?['id'];
      int? userId;
      if (idRaw is int) {
        userId = idRaw;
      } else if (idRaw is String) {
        userId = int.tryParse(idRaw);
      }
      if (userId == null) return false;

      // 업데이트 뮤테이션
      final payload = {
        'query':
            r'mutation UpdateUser($id: Int!, $nick_name: String, $wish_category: String, $wish_taste: String, $wish_importance: String, $wish_brand: String) { update_user(id: $id, nick_name: $nick_name, wish_category: $wish_category, wish_taste: $wish_taste, wish_importance: $wish_importance, wish_brand: $wish_brand) { success error user { id } } }',
        'variables': {
          'id': userId,
          'nick_name': nickname.isEmpty ? null : nickname,
          'wish_category': category.isEmpty ? null : category,
          'wish_taste': taste.isEmpty ? null : taste,
          'wish_importance': importance.isEmpty ? null : importance,
          'wish_brand': brand.isEmpty ? null : brand,
        },
      };
      final res2 = await dio.post('', data: jsonEncode(payload));
      final Map<String, dynamic> data2 = res2.data is String
          ? json.decode(res2.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(res2.data as Map);
      final ok = data2['data']?['update_user']?['success'] == true;
      return ok;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 섹션
            _buildTopSection(),

            // 중앙 콘텐츠 섹션
            Expanded(child: _buildContentSection()),

            // 하단 버튼 섹션
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
      child: Column(
        children: [
          // 뒤로가기 버튼과 캐릭터 그룹 이미지를 같은 줄에 배치
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_currentStep > 0) {
                    // 첫 번째 단계가 아닌 경우 이전 단계로 이동
                    setState(() {
                      _currentStep--;
                    });
                  } else {
                    // 첫 번째 단계인 경우 이전 페이지로 이동
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // 최상단 중앙에 캐릭터 그룹 이미지 (완료 전까지만 표시)
              if (_currentStep < 5) ...[
                // const SizedBox(height: 30),
                Image.asset(
                  'assets/icons/group2.png',
                  height: 40,
                  width: 230,
                  fit: BoxFit.contain,
                ),
              ],
              const Spacer(),
              // 오른쪽 공간을 위한 더미 위젯
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 20),

          // 진행 상태 인디케이터 (1번 아래 줄에 배치, 왼쪽 정렬)
          if (_currentStep < 5)
            Row(
              children: List.generate(5, (index) {
                return Container(
                  width: index == _currentStep ? 32 : 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    shape: index == _currentStep
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    borderRadius: index == _currentStep
                        ? BorderRadius.circular(10)
                        : null,
                    color: index == _currentStep
                        ? AppColors.primary500
                        : Colors.transparent,
                    border: Border.all(
                      color: index == _currentStep
                          ? AppColors.primary500
                          : AppColors.gray300,
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    // 완료 화면인 경우
    if (_currentStep == 5) {
      return _buildCompletionScreen();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 제목 (heading2 사용)
          Text(
            _getStepTitle(_currentStep),
            style: AppTypography.heading2.copyWith(
              color: const Color(0xFF242221),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // 부제목 (title5 사용)
          Text(
            _getStepSubtitle(_currentStep),
            style: AppTypography.title5.copyWith(
              color: _getStepSubtitleColor(_currentStep),
            ),
          ),

          const SizedBox(height: 40),

          // 단계별 입력 필드
          _buildStepInput(_currentStep),
        ],
      ),
    );
  }

  // 완료 화면
  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outlined, size: 60, color: AppColors.success),
          const SizedBox(height: 16),
          Text(
            '맞춤 설정이 완료됐어요',
            style: AppTypography.suiteHeading1.copyWith(
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '앞으로 선물 고를 때 꼭 참고할게요',
            style: AppTypography.title4.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
      child: Column(
        children: [
          // 다음/완료/선물 보러 가기 버튼 (360x60 크기)
          SizedBox(
            width: 360,
            height: 60,
            child: ElevatedButton(
              onPressed: _isStepValid(_currentStep)
                  ? () {
                      // 다음 단계로 이동하거나 완료 처리
                      if (_currentStep < 4) {
                        setState(() {
                          _currentStep++;
                        });
                      } else if (_currentStep == 4) {
                        // 마지막 단계: 서버 저장 시도
                        _handleSave();
                      } else {
                        // 온보딩 완료 - MakeFundingScreen으로 이동
                        debugPrint('Onboarding: push MakeFundingScreen');
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) => const MakeFundingScreen(),
                            fullscreenDialog: false,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.gray00,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _getButtonText(_currentStep),
                style: AppTypography.button2.copyWith(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final ok = await _saveProfile();
    if (!mounted) return;
    if (ok) {
      setState(() {
        _currentStep = 5;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장에 실패했어요. 다시 시도해 주세요.')));
    }
  }

  // 단계별 제목 반환
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return '이름(닉네임)을 작성해주세요';
      case 1:
        return '요즘 관심 있는\n카테고리는 뭐에요?';
      case 2:
        return '취향을 알려주세요';
      case 3:
        return '선물을 고를 때,\n가장 먼저 떠올리는 건\n무엇인가요?';
      case 4:
        return '가장 자주 찾는\n브랜드를 알려주세요';
      default:
        return '이름(닉네임)을 작성해주세요';
    }
  }

  // 단계별 부제목 반환
  String _getStepSubtitle(int step) {
    switch (step) {
      case 0:
        return '친구들에게 표시될 이름이에요';
      case 1:
        return '3개 이상 선택해 주세요';
      case 2:
        return '3개 이상 선택해 주세요';
      case 3:
        return '2개 이상 선택해 주세요';
      case 4:
        return '애플/나이키/스타벅스 등 편하게 입력해 주세요';
      default:
        return '친구들에게 표시될 이름이에요';
    }
  }

  // 단계별 부제목 색상 반환
  Color _getStepSubtitleColor(int step) {
    switch (step) {
      case 0:
        return AppColors.primary500;
      case 1:
      case 2:
      case 3:
        return AppColors.primary500;
      case 4:
        return AppColors.primary500;
      default:
        return AppColors.primary500;
    }
  }

  // 단계별 입력 필드 구성
  Widget _buildStepInput(int step) {
    switch (step) {
      case 0:
        return _buildNicknameInput();
      case 1:
        return _buildCategorySelection();
      case 2:
        return _buildTasteSelection();
      case 3:
        return _buildGiftFactorSelection();
      case 4:
        return _buildBrandInput();
      default:
        return _buildNicknameInput();
    }
  }

  // 닉네임 입력 필드
  Widget _buildNicknameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 입력 필드와 글자 수를 같은 줄에 배치
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nicknameController,
                style: AppTypography.title4.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: '닉네임 입력',
                  hintStyle: AppTypography.body1.copyWith(
                    color: AppColors.gray400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  counterText: '', // maxLength 카운터 숨기기
                ),
                onChanged: (value) {
                  setState(() {});
                },
                maxLength: _maxNicknameLength,
              ),
            ),
            Text(
              '(${_nicknameController.text.length}/$_maxNicknameLength)',
              style: AppTypography.caption1.copyWith(color: AppColors.gray400),
            ),
          ],
        ),

        // 밑줄
        Container(height: 1, color: AppColors.primary500),
      ],
    );
  }

  // 카테고리 선택
  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((category) {
            bool isSelected = _selectedCategories.contains(category);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(category);
                  } else {
                    _selectedCategories.add(category);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 14,
                  right: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF242221) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF242221)
                        : AppColors.gray300,
                  ),
                ),
                child: Text(
                  category,
                  style: AppTypography.body3.copyWith(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '(${_selectedCategories.length}/3)',
            style: AppTypography.caption1.copyWith(color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  // 취향 선택
  Widget _buildTasteSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _tastes.map((taste) {
            bool isSelected = _selectedTastes.contains(taste);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTastes.remove(taste);
                  } else {
                    _selectedTastes.add(taste);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 14,
                  right: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF242221) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF242221)
                        : AppColors.gray300,
                  ),
                ),
                child: Text(
                  taste,
                  style: AppTypography.body3.copyWith(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '(${_selectedTastes.length}/3)',
            style: AppTypography.caption1.copyWith(color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  // 선물 고를 때 고려사항 선택
  Widget _buildGiftFactorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _giftFactors.map((factor) {
            bool isSelected = _selectedGiftFactors.contains(factor);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGiftFactors.remove(factor);
                  } else {
                    _selectedGiftFactors.add(factor);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 14,
                  right: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF242221) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF242221)
                        : AppColors.gray300,
                  ),
                ),
                child: Text(
                  factor,
                  style: AppTypography.body3.copyWith(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '(${_selectedGiftFactors.length}/2)',
            style: AppTypography.caption1.copyWith(color: AppColors.textLight),
          ),
        ),
      ],
    );
  }

  // 브랜드 입력 필드
  Widget _buildBrandInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 입력 필드와 글자 수를 같은 줄에 배치
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _brandController,
                style: AppTypography.title4.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: '브랜드명을 입력해 주세요',
                  hintStyle: AppTypography.body1.copyWith(
                    color: AppColors.gray400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  counterText: '', // maxLength 카운터 숨기기
                ),
                onChanged: (value) {
                  setState(() {});
                },
                maxLength: _maxBrandLength,
              ),
            ),
            Text(
              '(${_brandController.text.length}/$_maxBrandLength)',
              style: AppTypography.caption1.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),

        // 밑줄
        Container(height: 1, color: AppColors.gray300),
      ],
    );
  }

  // 단계별 유효성 검사
  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _nicknameController.text.isNotEmpty;
      case 1:
        return _selectedCategories.length >= 3;
      case 2:
        return _selectedTastes.length >= 3;
      case 3:
        return _selectedGiftFactors.length >= 2;
      case 4:
        return _brandController.text.isNotEmpty;
      case 5:
        return true; // 완료 화면에서는 항상 활성화
      default:
        return false;
    }
  }

  // 버튼 텍스트 반환
  String _getButtonText(int step) {
    switch (step) {
      case 0:
      case 1:
      case 2:
      case 3:
        return '다음';
      case 4:
        return '완료';
      case 5:
        return '선물 보러 가기';
      default:
        return '다음';
    }
  }
}
