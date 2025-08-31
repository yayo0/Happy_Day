import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';

class FundingMainContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<dynamic> participants;
  final int daysLeft;
  final ValueChanged<Map<String, dynamic>> onAvatarTap;

  const FundingMainContent({
    super.key,
    required this.data,
    required this.participants,
    required this.daysLeft,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryLightest,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('생일선물 펀딩', style: AppTypography.caption2.copyWith(color: AppColors.primaryBase)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${data['name'] as String? ?? '친구'}의\n',
                      style: AppTypography.suiteHeading1.copyWith(color: AppColors.textDarker),
                    ),
                    TextSpan(
                      text: data['fundingTitle'] as String? ?? '',
                      style: AppTypography.suiteHeading1.copyWith(color: AppColors.textDarker),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '펀딩에 초대 받았어요! 함께 선물을 준비해 봐요',
                style: AppTypography.title5.copyWith(color: AppColors.primaryBase),
              ),
              const SizedBox(height: 80),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final p in participants)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => onAvatarTap(p as Map<String, dynamic>),
                              child: CharacterAvatar(
                                characterType: ((p as Map<String, dynamic>)['characterType'] ?? 1) as int,
                                size: 70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.baseWhite,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                ((p as Map<String, dynamic>)['name'] ?? '') as String,
                                style: AppTypography.caption2.copyWith(color: AppColors.primaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '${participants.length}명의 친구가 펀딩에 참여했어요',
                  style: AppTypography.caption1.copyWith(color: AppColors.primaryBase),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '${data['name'] ?? ''}가 받을 선물은', style: AppTypography.title1.copyWith(color: AppColors.textDarker)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: data['product'] as String? ?? '', style: AppTypography.title1.copyWith(color: AppColors.primaryBase)),
              TextSpan(text: ' 네요', style: AppTypography.title1.copyWith(color: AppColors.textDarker)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: '모두 공평하게 N빵!\n', style: AppTypography.body1.copyWith(color: AppColors.textDark)),
              TextSpan(text: '선물 완성까지 ', style: AppTypography.body1.copyWith(color: AppColors.textDark)),
              TextSpan(text: '$daysLeft일', style: AppTypography.body1.copyWith(color: AppColors.primaryBase)),
              TextSpan(text: ' 남았어요', style: AppTypography.body1.copyWith(color: AppColors.textDark)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 185),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.baseLighter,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    data['productImage'] as String? ?? 'https://picsum.photos/185/185',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 185,
                        height: 185,
                        color: AppColors.gray00,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textLight,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}


