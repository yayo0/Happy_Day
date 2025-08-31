import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';

class FundingCompleteContent extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isMessageStep;
  final bool isCharacterStep;
  final bool isFinalStep;
  final TextEditingController? messageController;
  final bool? isPrivateMessage;
  final int? selectedCharacterType;
  final ValueChanged<bool>? onPrivateToggle;
  final ValueChanged<int>? onCharacterSelect;
  final VoidCallback? onExit;

  const FundingCompleteContent({
    super.key,
    required this.data,
    this.isMessageStep = false,
    this.isCharacterStep = false,
    this.isFinalStep = false,
    this.messageController,
    this.isPrivateMessage,
    this.selectedCharacterType,
    this.onPrivateToggle,
    this.onCharacterSelect,
    this.onExit,
  });

  @override
  State<FundingCompleteContent> createState() => _FundingCompleteContentState();
}

class _FundingCompleteContentState extends State<FundingCompleteContent> {
  bool _showTooltip = false;

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;
    const double topBarApprox = 60; // 상단바 대략 높이
    final double minBodyHeight = MediaQuery.of(context).size.height - statusBar - topBarApprox;

    return Container(
        width: double.infinity,
        height: widget.isFinalStep ? minBodyHeight : null,
          constraints: widget.isFinalStep ? null : BoxConstraints(minHeight: minBodyHeight < 0 ? 0 : minBodyHeight),
          decoration: BoxDecoration(
            color: AppColors.baseWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          child: widget.isFinalStep
              ? _buildFinalStep()
              : widget.isCharacterStep 
                  ? _buildCharacterStep() 
                  : widget.isMessageStep 
                      ? _buildMessageStep() 
                      : _buildCompleteStep(),
        );
  }

  Widget _buildCompleteStep() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 GIF
        Positioned.fill(
          child: Image.asset(
            'lib/feature/give_funding/asset/complete.gif',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // GIF 로드 실패 시 기본 배경색
              print('GIF 로드 실패: $error');
              return Container(
                color: AppColors.baseWhite,
              );
            },
          ),
        ),

        // 기존 내용
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 첫 번째 섹션: 펀딩 제목 + 펀딩 완료
            Column(
              children: [
                Text(
                  '${widget.data['name'] as String? ?? '친구'}의 ${widget.data['fundingTitle'] as String? ?? ''}',
                  style: AppTypography.title4.copyWith(color: AppColors.textDarkest),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '펀딩 완료',
                  style: AppTypography.suiteHeading1.copyWith(color: AppColors.primaryBase),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 75),
            // 두 번째 섹션: 선물 이미지
            Image.asset(
              'lib/feature/give_funding/asset/gift.png',
              width: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.baseLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    size: 80,
                    color: AppColors.primaryBase,
                  ),
                );
              },
            ),
            const SizedBox(height: 140),
            // 세 번째 섹션: 축하 메시지
            Text(
              '축하메시지로\n마음도 함께 전해 보아요',
              style: AppTypography.title4.copyWith(color: AppColors.textDarker),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageStep() {
    final messageLength = widget.messageController?.text.length ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '축하 메시지 작성 중',
          style: AppTypography.caption1.copyWith(color: AppColors.primaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.data['name'] as String? ?? '친구'}의 ${widget.data['fundingTitle'] as String? ?? ''}',
          style: AppTypography.title5.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 25),
        Text(
          '친구에게 남길 메시지를 작성해주세요',
          style: AppTypography.title1.copyWith(color: AppColors.textDarker),
        ),
        const SizedBox(height: 8),
        Text(
          '100자 이내',
          style: AppTypography.title5.copyWith(color: AppColors.primaryBase),
        ),
        const SizedBox(height: 16),
        
        // 메시지 입력창
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.baseLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              TextField(
                controller: widget.messageController,
                maxLength: 100,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: '메시지를 입력해주세요',
                  hintStyle: AppTypography.body1.copyWith(color: AppColors.textLightest),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '',
                ),
                style: AppTypography.body1.copyWith(
                  color: AppColors.textDarkest,
                ),
                onChanged: (value) => setState(() {}),
              ),
              // 글자 수 표시
              Positioned(
                bottom: 8,
                right: 12,
                child: Text(
                  '($messageLength/100)',
                  style: AppTypography.caption2.copyWith(color: AppColors.textDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 비밀 메시지 토글
        Row(
          children: [
            // 말풍선 (비밀메시지가 on일 때만 표시)
            if (widget.isPrivateMessage ?? false)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CustomPaint(
                    painter: _TooltipPainter(),
                    size: const Size(200, 32),
                  ),
                ),
              )
            else
              const Spacer(),
            
            // 우측 정렬된 비밀메시지 섹션
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '비밀메시지',
                  style: AppTypography.subtitle2.copyWith(color: AppColors.textDarkest),
                ),
                const SizedBox(height: 8),
                _CustomToggle(
                  value: widget.isPrivateMessage ?? false,
                  onChanged: widget.onPrivateToggle,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCharacterStep() {
    // 더미 캐릭터 데이터
    final characters = [
      {'type': 1, 'name': '펭기'},
      {'type': 2, 'name': '모모'},
      {'type': 3, 'name': '포코'},
      {'type': 4, 'name': '리리'},
      {'type': 5, 'name': '바니'},
      {'type': 6, 'name': '차차'},
      {'type': 7, 'name': '우우'},
      {'type': 8, 'name': '뽀뽀'},
      {'type': 9, 'name': '밍밍'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '축하 메시지 작성 중',
          style: AppTypography.caption1.copyWith(color: AppColors.primaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.data['name'] as String? ?? '친구'}의 ${widget.data['fundingTitle'] as String? ?? ''}',
          style: AppTypography.title5.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 25),
        Text(
          '몬스터를 선택해주세요',
          style: AppTypography.title1.copyWith(color: AppColors.textDarker),
        ),
        const SizedBox(height: 8),
        Text(
          '펀딩을 완료하면 나타나는 몬스터에요',
          style: AppTypography.title5.copyWith(color: AppColors.primaryBase),
        ),
        const SizedBox(height: 24),
        
        // 캐릭터 선택 리스트
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              final type = character['type'] as int;
              final name = character['name'] as String;
              final isSelected = widget.selectedCharacterType == type;
              
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 12,
                  right: index == characters.length - 1 ? 0 : 0,
                ),
                child: GestureDetector(
                  onTap: () => widget.onCharacterSelect?.call(type),
                  child: Container(
                    width: 170,
                    decoration: BoxDecoration(
                      color: AppColors.baseLightest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBase : AppColors.textLightest,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: CharacterAvatar(
                                  characterType: type,
                                  size: 110,
                                  showBackground: false,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  name,
                                  style: AppTypography.caption1.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBase,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFinalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '축하 메시지 작성 중',
          style: AppTypography.caption1.copyWith(color: AppColors.primaryLight),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.data['name'] as String? ?? '친구'}의 ${widget.data['fundingTitle'] as String? ?? ''}',
          style: AppTypography.title5.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 48),
        Text(
          '축하 메시지로\n마음까지 전해졌어요!',
          style: AppTypography.heading2.copyWith(color: AppColors.textDarker),
        ),
        const SizedBox(height: 8),
        Text(
          '다른 친구들에게도 공유해 주세요',
          style: AppTypography.title5.copyWith(color: AppColors.primaryBase),
        ),
        const SizedBox(height: 60),
        
        // 완료 이미지
        Center(
          child: Image.asset(
            'lib/feature/give_funding/asset/finished.png',
            width: 300,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.baseLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.celebration,
                  size: 80,
                  color: AppColors.primaryBase,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 70),
        
        // 링크 공유 컴포넌트
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.baseLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'https://www.google.com/funding/abc123',
                  style: AppTypography.body2.copyWith(color: AppColors.textLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // TODO: 링크 복사 기능 구현
                },
                child: Icon(
                  Icons.copy,
                  color: AppColors.primaryBase,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        
        // 공간을 채워서 버튼을 아래쪽으로 밀어냄
        const Spacer(),
        
        // 나가기/공유하기 버튼
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLightest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    '나가기',
                    style: AppTypography.button2.copyWith(color: AppColors.primaryBase),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 공유하기 기능 구현
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBase,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        color: AppColors.baseWhite,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '공유하기',
                        style: AppTypography.button2.copyWith(color: AppColors.baseWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _TooltipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.notice
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 말풍선 본체 (둥근 사각형)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    path.addRRect(rect);
    
    // 말풍선 꼬리 (삼각형) - 우측 변에서 우측으로 향함
    final tailY = size.height / 2;
    path.moveTo(size.width, tailY - 6);
    path.lineTo(size.width + 8, tailY);
    path.lineTo(size.width, tailY + 6);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 텍스트 그리기
    final textPainter = TextPainter(
      text: TextSpan(
        text: '비밀 메시지는 선물 받는 친구에게만 보여요',
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

class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _CustomToggle({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: SizedBox(
        width: 44,
        height: 24, // 원 크기는 24이므로 전체 높이를 24로 설정
        child: Stack(
          children: [
            // 배경 바
            Positioned(
              top: 4, // 원과 중앙 정렬을 위해 상단 여백
              left: 0,
              right: 0,
              child: Container(
                height: 16, // 바의 높이만 줄임
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: value ? AppColors.primaryLighter : AppColors.baseLight,
                ),
              ),
            ),
            // 애니메이션되는 원
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? 20 : 0, // 44 - 24 = 20
              top: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBase,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
