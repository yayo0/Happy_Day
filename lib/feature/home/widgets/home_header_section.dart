import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class HomeHeaderSection extends StatefulWidget {
  final bool hasRegisteredEvents;
  final String? currentMode;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onHomeTap;
  
  const HomeHeaderSection({
    super.key,
    required this.hasRegisteredEvents,
    this.currentMode,
    this.onCalendarTap,
    this.onHomeTap,
  });

  @override
  State<HomeHeaderSection> createState() => _HomeHeaderSectionState();
}

class _HomeHeaderSectionState extends State<HomeHeaderSection> {
  bool _showNotification = false;

  @override
  void initState() {
    super.initState();
    // 2초 후에 알림 표시
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showNotification = true;
        });
        // 3초 후에 알림 숨김
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showNotification = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSpecialMode = widget.currentMode == 'gift_browse' || 
                          widget.currentMode == 'wishlist' || 
                          widget.currentMode == 'more';
    
    String _getHeaderTitle() {
      switch (widget.currentMode) {
        case 'gift_browse':
          return '선물 둘러보기';
        case 'wishlist':
          return '위시리스트';
        case 'more':
          return '더보기';
        default:
          return '';
      }
    }
    
    return Container(
      height: 60, // 명시적 높이 지정
      color: widget.currentMode == 'more' ? AppColors.baseLightest : AppColors.gray00,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 중앙 텍스트 (전체 헤더 기준 완전 중앙)
          if (isSpecialMode) ...[
            Positioned.fill(
              child: Center(
                child: Text(
                  _getHeaderTitle(),
                  style: AppTypography.title4.copyWith(
                    color: AppColors.textDarker,
                  ),
                ),
              ),
            ),
          ],
          
          // 로고 (좌측 절대 위치)
          Positioned(
            left: 20,
            top: 5,
            child: GestureDetector(
              onTap: widget.onHomeTap,
              child: Image.asset(
                'lib/interface/asset/happy_day_logo.png',
                width: 40,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    '해피데이',
                    style: AppTypography.heading2.copyWith(
                      color: AppColors.textDarkest,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 우측 아이콘들
          if (isSpecialMode) ...[
            // 선물 둘러보기 모드일 때만 돋보기 아이콘
            if (widget.currentMode == 'gift_browse') ...[
              Positioned(
                right: 20,
                top: 18,
                child: Icon(
                  Icons.search,
                  color: AppColors.textDark,
                  size: 24,
                ),
              ),
            ],
          ] else ...[
            // 등록된 기념일이 없을 때만 캘린더 아이콘 표시
            if (!widget.hasRegisteredEvents) ...[
              Positioned(
                right: 20,
                top: 10,
                child: GestureDetector(
                  onTap: widget.onCalendarTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'lib/feature/home/asset/addCalendar.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(AppColors.primaryBase, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
          
          // 알림 메시지 (위에 떠있는 느낌) - 홈 모드에서만
          if (!isSpecialMode && !widget.hasRegisteredEvents && _showNotification) ...[
            Positioned(
              top: 0,
              right: 80,
              child: AnimatedOpacity(
                opacity: _showNotification ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: CustomPaint(
                  painter: HomeHeaderSpeechBubblePainter(
                    color: AppColors.notice,
                    strokeColor: AppColors.notice,
                    strokeWidth: 0,
                  ),
                  size: const Size(280, 40),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 말풍선 모양을 그리는 CustomPainter (우측 변에 붙은 꼬리)
class HomeHeaderSpeechBubblePainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  HomeHeaderSpeechBubblePainter({
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
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    path.addRRect(rect);
    
    // 말풍선 꼬리 (삼각형) - 우측 변에 붙어서 우측을 향함
    path.moveTo(size.width, size.height / 2 - 6);
    path.lineTo(size.width + 8, size.height / 2);
    path.lineTo(size.width, size.height / 2 + 6);
    path.close();
    
    canvas.drawPath(path, paint);
    if (strokeWidth > 0) {
      canvas.drawPath(path, strokePaint);
    }
    
    // 텍스트 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: '선물을 까먹지 않도록 캘린더에 등록하세요!',
        style: AppTypography.body4.copyWith(
          color: AppColors.textWhite,
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
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
