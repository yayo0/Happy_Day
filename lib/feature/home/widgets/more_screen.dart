import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback onBack;
  
  const MoreScreen({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.baseLightest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const SizedBox(height: 24),
          
          // 프로필 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '프로필',
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 프로필 섹션
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.baseWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // 캐릭터 아바타
                const CharacterAvatar(
                  characterType: 1,
                  size: 60,
                  backgroundColor: AppColors.primaryLighter,
                ),
                const SizedBox(width: 16),
                
                // 중앙 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '김세원',
                        style: AppTypography.title3.copyWith(
                          color: AppColors.textDarkest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '생일',
                            style: AppTypography.subtitle2.copyWith(
                              color: AppColors.textLighter,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '12월 12일',
                            style: AppTypography.subtitle2.copyWith(
                              color: AppColors.textDarker,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 수정 아이콘
                Icon(
                  Icons.border_color,
                  color: AppColors.textLightest,
                  size: 20,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 메뉴 목록 (배경색 제거)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildMenuItemWithIcon('내가 받은 선물', _buildGiftSvgIcon()),
                _buildDivider(),
                _buildMenuItemWithIcon('내가 준 선물', _buildGivePngIcon()),
                _buildDivider(),
                _buildMenuItemWithIcon('기념일 정리함', Icon(Icons.edit_calendar, color: AppColors.textDark, size: 20)),
                _buildDivider(),
                _buildMenuItemWithIcon('친구 목록 관리', Icon(Icons.group, color: AppColors.textDark, size: 20)),
                _buildDivider(),
                _buildMenuItemWithIcon('환불 관리', Icon(Icons.credit_card, color: AppColors.textDark, size: 20)),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 로그아웃
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.baseWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '로그아웃',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.logout,
                  color: AppColors.textDark,
                  size: 16,
                ),
                const Spacer(),
              ],
            ),
          ),
          
          const SizedBox(height: 100), // 하단 여백
          ],
        ),
      ),
    );
  }
  
  Widget _buildMenuItemWithIcon(String title, Widget icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTypography.body2.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
         
        ],
      ),
    );
  }

  Widget _buildGiftSvgIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: SvgPicture.asset(
        'lib/feature/home/asset/gift.svg',
        colorFilter: ColorFilter.mode(
          AppColors.textDark,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildGivePngIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: Image.asset(
        'lib/feature/home/asset/give.png',
        color: AppColors.textDark,
        colorBlendMode: BlendMode.srcIn,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.card_giftcard,
            color: AppColors.textDark,
            size: 20,
          );
        },
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.baseLighter,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
