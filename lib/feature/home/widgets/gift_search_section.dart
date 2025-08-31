import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class GiftSearchSection extends StatelessWidget {
  final VoidCallback onSearchTap;
  
  const GiftSearchSection({
    super.key,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '다양한 선물들을 더 보고싶다면',
                style: AppTypography.title2.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 더보기 기능 구현
                },
                child: Text(
                  '더보기 >',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.textLighter,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '카테고리별로 딱 맞는 선물을 찾아보세요',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 33),
          
          // 카테고리 필터
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryFilter(
                icon: Icons.attach_money,
                label: '가격대별',
                onTap: () {
                  // TODO: 가격대별 필터 구현
                },
              ),
              _buildCategoryFilter(
                icon: Icons.celebration,
                label: '상황별',
                onTap: () {
                  // TODO: 상황별 필터 구현
                },
              ),
              _buildCategoryFilter(
                icon: Icons.wc,
                label: '성별',
                onTap: () {
                  // TODO: 성별 필터 구현
                },
              ),
              _buildCategoryFilter(
                icon: Icons.stroller,
                label: '나이별',
                onTap: () {
                  // TODO: 나이별 필터 구현
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 검색바
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.baseLighter,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '선물 검색',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.baseBase,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.search,
                      color: AppColors.textDarker,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            child: Icon(
              icon,
              color: AppColors.primaryBase,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textDarker,
            ),
          ),
        ],
      ),
    );
  }
}
