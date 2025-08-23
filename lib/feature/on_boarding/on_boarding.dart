import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final TextEditingController _nicknameController = TextEditingController();
  final int _maxLength = 15;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
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
            Expanded(
              child: _buildContentSection(),
            ),
            
            // 하단 버튼 섹션
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 뒤로가기 버튼과 진행 인디케이터
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // 진행 상태 인디케이터
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
          
          const SizedBox(height: 20),
          
          // 몬스터 아이콘들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMonsterIcon('👹', isActive: _currentStep == 0),
              _buildMonsterIcon('🎉', isActive: _currentStep == 1),
              _buildMonsterIcon('👾', isActive: _currentStep == 2),
              _buildMonsterIcon('🦅', isActive: _currentStep == 3),
              _buildMonsterIcon('🦷', isActive: _currentStep == 4),
              _buildMonsterIcon('👁️', isActive: _currentStep == 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonsterIcon(String emoji, {required bool isActive}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary100 : AppColors.gray200,
        borderRadius: BorderRadius.circular(20),
        border: isActive 
            ? Border.all(color: AppColors.primary500, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 20,
            color: isActive ? AppColors.primary500 : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 제목
          Text(
            _getStepTitle(_currentStep),
            style: AppTypography.heading1.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 부제목
          Text(
            _getStepSubtitle(_currentStep),
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.primary500,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // 단계별 입력 필드
          _buildStepInput(_currentStep),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 다음 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isStepValid(_currentStep) ? () {
                // 다음 단계로 이동하거나 완료 처리
                if (_currentStep < 4) {
                  setState(() {
                    _currentStep++;
                  });
                  // 다음 단계로 이동할 때마다 입력 필드 초기화
                  _nicknameController.clear();
                } else {
                  // 온보딩 완료
                  Navigator.pop(context);
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.gray00,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep < 4 ? '다음' : '완료',
                style: AppTypography.button1.copyWith(
                  color: AppColors.gray00,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 단계별 제목 반환
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return '이름(닉네임)을 작성해주세요';
      case 1:
        return '생년월일을 입력해주세요';
      case 2:
        return '성별을 선택해주세요';
      case 3:
        return '관심사를 선택해주세요';
      case 4:
        return '프로필 사진을 설정해주세요';
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
        return '생일 축하 메시지를 받을 수 있어요';
      case 2:
        return '맞춤형 선물 추천을 위해 필요해요';
      case 3:
        return '더 정확한 선물을 추천해드릴게요';
      case 4:
        return '프로필을 완성해보세요';
      default:
        return '친구들에게 표시될 이름이에요';
    }
  }

  // 단계별 입력 필드 구성
  Widget _buildStepInput(int step) {
    switch (step) {
      case 0:
        return _buildNicknameInput();
      case 1:
        return _buildBirthdayInput();
      case 2:
        return _buildGenderSelection();
      case 3:
        return _buildInterestSelection();
      case 4:
        return _buildProfilePhotoInput();
      default:
        return _buildNicknameInput();
    }
  }

  // 닉네임 입력 필드
  Widget _buildNicknameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nicknameController,
          style: AppTypography.body1.copyWith(
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: '닉네임 입력',
            hintStyle: AppTypography.body1.copyWith(
              color: AppColors.gray400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixText: '(${_nicknameController.text.length}/$_maxLength)',
            suffixStyle: AppTypography.caption1.copyWith(
              color: AppColors.gray400,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
          maxLength: _maxLength,
        ),
        
        // 밑줄
        Container(
          height: 1,
          color: AppColors.gray300,
        ),
      ],
    );
  }

  // 생년월일 입력 필드
  Widget _buildBirthdayInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nicknameController,
          style: AppTypography.body1.copyWith(
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            hintStyle: AppTypography.body1.copyWith(
              color: AppColors.gray400,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
        
        // 밑줄
        Container(
          height: 1,
          color: AppColors.gray300,
        ),
      ],
    );
  }

  // 성별 선택
  Widget _buildGenderSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildGenderOption('남성', '👨'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGenderOption('여성', '👩'),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String emoji) {
    bool isSelected = _nicknameController.text == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _nicknameController.text = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.gray300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: isSelected ? AppColors.primary500 : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 관심사 선택
  Widget _buildInterestSelection() {
    final interests = ['패션', '뷰티', '스포츠', '게임', '독서', '음악'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: interests.map((interest) {
        bool isSelected = _nicknameController.text.contains(interest);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _nicknameController.text = _nicknameController.text
                    .replaceAll('$interest,', '')
                    .replaceAll(',$interest', '')
                    .replaceAll(interest, '');
              } else {
                if (_nicknameController.text.isNotEmpty) {
                  _nicknameController.text += ',$interest';
                } else {
                  _nicknameController.text = interest;
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary500 : AppColors.gray100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary500 : AppColors.gray300,
              ),
            ),
            child: Text(
              interest,
              style: AppTypography.body3.copyWith(
                color: isSelected ? AppColors.gray00 : AppColors.textLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 프로필 사진 입력
  Widget _buildProfilePhotoInput() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gray300, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.add_a_photo,
              size: 48,
              color: AppColors.gray400,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '프로필 사진을 선택해주세요',
          style: AppTypography.body1.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  // 단계별 유효성 검사
  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return _nicknameController.text.isNotEmpty;
      case 1:
        return _nicknameController.text.isNotEmpty && 
               _nicknameController.text.length >= 8; // YYYY-MM-DD 형식
      case 2:
        return _nicknameController.text.isNotEmpty;
      case 3:
        return _nicknameController.text.isNotEmpty;
      case 4:
        return true; // 프로필 사진은 선택사항
      default:
        return false;
    }
  }
}
