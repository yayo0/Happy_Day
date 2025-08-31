import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';

class SpecialDaysSection extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final Function(Map<String, dynamic>) onGiftButtonTap;
  final VoidCallback? onRegisterTap;
  
  const SpecialDaysSection({
    super.key,
    required this.events,
    required this.onGiftButtonTap,
    this.onRegisterTap,
  });

  @override
  State<SpecialDaysSection> createState() => _SpecialDaysSectionState();
}

class _SpecialDaysSectionState extends State<SpecialDaysSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showBanner = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // 3초 후에 배너를 자연스럽게 사라지게 함
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _animationController.forward();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showBanner = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '특별한 날, 잊지 마세요!',
            style: AppTypography.title1.copyWith(
              color: AppColors.textDarkest,
            ),
          ),
          const SizedBox(height: 16),
          
          // 기념일 섹션 컨테이너
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.baseLighter,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.baseLightest,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 예정된 기념일 제목
                Text(
                  '예정된 기념일',
                  style: AppTypography.title5.copyWith(
                    color: AppColors.textDarker,
                  ),
                ),
                const SizedBox(height: 12),
                
                                                  // 기념일 목록 (가로 스크롤)
                 SizedBox(
                   height: 160,
                   child: Stack(
                     clipBehavior: Clip.none,
                                           children: [
                        ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // 기념일 등록 카드
                            GestureDetector(
                              onTap: widget.onRegisterTap,
                              child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.gray200,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'lib/feature/home/asset/addCalendar.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(AppColors.textLight, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '기념일 등록',
                                    style: AppTypography.caption2.copyWith(
                                      color: AppColors.textDarker,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              ),
                            ),
                            
                            // 등록된 기념일들
                            ...widget.events.map((event) => _buildEventCard(event)),
                          ],
                        ),
                        // 3초간 나타나는 파란색 말풍선 알림 (기념일 등록 카드 위에 떠있음)
                        if (_showBanner)
                          Positioned(
                            top: 0,
                            left: 20,
                            child: AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: CustomPaint(
                                    painter: SpeechBubblePainter(
                                      color: AppColors.notice,
                                      strokeColor: AppColors.notice,
                                      strokeWidth: 0,
                                    ),
                                    size: const Size(200, 40),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      width: 120,
      height: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.gray00,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          // 캐릭터 아바타 (40x40 원형)
          CharacterAvatar(
            characterType: (event['characterType'] ?? 1) as int,
            size: 40,
          ),
          
          // 이름과 이벤트 타입을 가로로 나란히 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: event['name'] as String,
                        style: AppTypography.subtitle1.copyWith(
                          color: AppColors.textDarkest,
                        ),
                      ),
                      const TextSpan(
                        text: '\u{200B}', // Zero-width space
                        style: TextStyle(
                          letterSpacing: 4.0,
                        ),
                      ),
                      TextSpan(
                        text: event['eventType'] as String,
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // 날짜
          Text(
            event['date'] as String,
            style: AppTypography.body4.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          
          // 선물하기 버튼
          GestureDetector(
            onTap: () {
              widget.onGiftButtonTap(event);
            },
            child: Container(
              width: 100,
              height: 32,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLightest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '선물하기',
                  style: AppTypography.button3.copyWith(
                    color: AppColors.primaryBase,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


 }

// 말풍선 모양을 그리는 CustomPainter
class SpeechBubblePainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  SpeechBubblePainter({
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
  });

    @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    
    // 말풍선 본체 (둥근 사각형)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 8),
      const Radius.circular(8),
    );
    path.addRRect(rect);
    
    // 말풍선 꼬리 (삼각형) - 좌측 하단에 위치
    path.moveTo(12, size.height - 8);
    path.lineTo(20, size.height);
    path.lineTo(28, size.height - 8);
    path.close();
    
    canvas.drawPath(path, paint);
    if (strokeWidth > 0) {
      canvas.drawPath(path, strokePaint);
    }
    
    // 텍스트 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: '선물을 까먹지 않도록 등록하세요!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - 8 - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
