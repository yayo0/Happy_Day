import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';
import '../../interface/character.dart';
import 'widgets/funding_main_content.dart';
import 'widgets/guest_participation_content.dart';
import 'widgets/funding_complete_content.dart';
import 'widgets/toss_payment_screen.dart';

class FundingPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onClose;

  const FundingPage({super.key, required this.data, this.onClose});

  @override
  State<FundingPage> createState() => _FundingPageState();
}

class _FundingPageState extends State<FundingPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _selectedParticipant;
  late final AnimationController _popupController;
  bool _showExitConfirm = false;
  bool _showJoinConfirm = false;
  bool _showGuestForm = false;
  bool _isParticipateStep = false;
  bool _isAmountStep = false;
  bool _showPaymentConfirm = false;
  bool _isCompleteStep = false;
  bool _isMessageStep = false;
  bool _isCharacterStep = false;
  bool _isFinalStep = false;
  int? _selectedCharacterType;

  final TextEditingController _guestNameController = TextEditingController();
  final FocusNode _guestNameFocus = FocusNode();
  bool _isTypingName = false;
  final TextEditingController _guestAmountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isPrivateMessage = false;

  @override
  void initState() {
    super.initState();
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 0.8,
    );
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestNameFocus.dispose();
    _guestAmountController.dispose();
    _messageController.dispose();
    _popupController.dispose();
    super.dispose();
  }

  int _daysLeft(String endDateIso) {
    try {
      final end = DateTime.parse(endDateIso);
      final today = DateTime.now();
      return end
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;
    } catch (_) {
      return 0;
    }
  }

  void _navigateToTossPayment() {
    final userName = _guestNameController.text.trim();
    final text = _guestAmountController.text
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('원', '');
    final amount = int.tryParse(text) ?? 0;
    final targetName = widget.data['name'] as String? ?? '친구'; // 실제 펀딩 대상

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TossPaymentScreen(
          userName: userName,
          targetName: targetName, // 펀딩 대상 이름 추가
          amount: amount,
          onSuccess: () {
            // 결제 성공 시 완료 화면으로 이동
            Navigator.of(context).pop(); // 토스페이먼츠 화면 닫기
            setState(() {
              _isCompleteStep = true;
            });
          },
          onCancel: () {
            // 결제 취소 시 이전 화면으로 돌아가기
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final participants = (widget.data['paritcipants'] as List<dynamic>? ?? []);
    final daysLeft = _daysLeft(
      widget.data['endDate'] as String? ?? DateTime.now().toIso8601String(),
    );
    final String fundingType = (widget.data['type'] as String?) ?? '자유';
    final int totalPrice = (widget.data['price'] as int?) ?? 0;
    final int alreadyFunded = participants.fold<int>(
      0,
      (sum, p) =>
          sum + ((p as Map<String, dynamic>)['fundedAmount'] as int? ?? 0),
    );
    final int remainingAmount = (totalPrice - alreadyFunded).clamp(
      0,
      totalPrice,
    );
    final bool isLastContributor = remainingAmount <= 0;

    return Scaffold(
      backgroundColor: AppColors.gray00,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: 0,
              ),
              child: Column(
                crossAxisAlignment: (_isCompleteStep || _isParticipateStep)
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  // 상단 닫기 버튼 (우측 상단)
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const SizedBox(height: 60),
                      if ((_isParticipateStep ||
                              _isMessageStep ||
                              _isCharacterStep) &&
                          !_isFinalStep &&
                          !(_isCompleteStep &&
                              !_isMessageStep &&
                              !_isCharacterStep))
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_isCharacterStep) {
                                _isCharacterStep = false;
                              } else if (_isMessageStep) {
                                _isMessageStep = false;
                              } else if (_isParticipateStep) {
                                // 금액 단계에서 뒤로가기 시 이름 단계로
                                if (_isAmountStep) {
                                  _isAmountStep = false;
                                } else {
                                  // 이름 단계에서 뒤로가기 시 완전히 나가기
                                  _isParticipateStep = false;
                                  FocusScope.of(context).unfocus();
                                }
                              }
                            });
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: AppColors.textDark,
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_isFinalStep) {
                            Navigator.of(context).maybePop();
                          } else {
                            setState(() {
                              _showExitConfirm = true;
                            });
                          }
                        },
                        child: Icon(
                          Icons.close,
                          size: 22,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  // 본문: 기본 카드 or 참여 단계 폼
                  if (!_isParticipateStep)
                    FundingMainContent(
                      data: widget.data,
                      participants: participants,
                      daysLeft: daysLeft,
                      onAvatarTap: (p) {
                        setState(() {
                          _selectedParticipant = p;
                        });
                        _popupController.forward(from: 0.8);
                      },
                    ),

                  if (_isParticipateStep && !_isCompleteStep)
                    GuestParticipationContent(
                      data: widget.data,
                      nameController: _guestNameController,
                      nameFocus: _guestNameFocus,
                      isAmountStep: _isAmountStep,
                      amountController: _guestAmountController,
                      fundingType: fundingType,
                      totalPrice: totalPrice,
                      remainingAmount: remainingAmount,
                      isLastContributor: isLastContributor,
                    ),

                  if (_isCompleteStep)
                    FundingCompleteContent(
                      data: widget.data,
                      isMessageStep: _isMessageStep,
                      isCharacterStep: _isCharacterStep,
                      isFinalStep: _isFinalStep,
                      messageController: _messageController,
                      isPrivateMessage: _isPrivateMessage,
                      selectedCharacterType: _selectedCharacterType,
                      onPrivateToggle: (value) {
                        setState(() {
                          _isPrivateMessage = value;
                        });
                      },
                      onCharacterSelect: (type) {
                        setState(() {
                          _selectedCharacterType = type;
                        });
                      },
                      onExit: () {
                        Navigator.of(context).maybePop();
                      },
                    ),
                ],
              ),
            ),
          ),

          // 고정 하단 버튼 (최종 화면에서는 숨김)
          if (!_isFinalStep)
            Positioned(
              left: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20,
              right: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 20,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 32,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isFinalStep
                      ? null // 최종 화면에서는 하단 버튼이 나가기/공유하기로 분리됨
                      : _isCharacterStep
                      ? () {
                          if (_selectedCharacterType != null) {
                            setState(() {
                              _isFinalStep = true;
                            });
                          }
                        }
                      : _isMessageStep
                      ? () {
                          setState(() {
                            _isCharacterStep = true;
                          });
                        }
                      : _isCompleteStep
                      ? () {
                          setState(() {
                            _isMessageStep = true;
                          });
                        }
                      : _isParticipateStep
                      ? (() {
                          final hasName = _guestNameController.text
                              .trim()
                              .isNotEmpty;
                          if (!_isAmountStep) {
                            if (!hasName) return;
                            setState(() => _isAmountStep = true);
                            return;
                          }
                          // amount step
                          final text = _guestAmountController.text
                              .replaceAll(',', '')
                              .replaceAll(' ', '')
                              .replaceAll('원', '');
                          final amount = int.tryParse(text) ?? 0;
                          if (fundingType == '자유') {
                            if (remainingAmount > 0 &&
                                (amount <= 0 || amount > remainingAmount))
                              return;
                          } else {
                            if (amount <= 0) return;
                          }
                          // 결제 확인 바텀시트 표시
                          setState(() {
                            _showPaymentConfirm = true;
                          });
                        })
                      : () {
                          setState(() {
                            _showJoinConfirm = true;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCharacterStep
                        ? (_selectedCharacterType != null
                              ? AppColors.primaryBase
                              : AppColors.baseLight)
                        : _isMessageStep
                        ? AppColors.primaryBase
                        : _isCompleteStep
                        ? AppColors.primaryBase
                        : _isParticipateStep
                        ? (() {
                            if (!_isAmountStep) {
                              return _guestNameController.text.trim().isNotEmpty
                                  ? AppColors.primaryBase
                                  : AppColors.baseLight;
                            }
                            final text = _guestAmountController.text
                                .replaceAll(',', '')
                                .replaceAll(' ', '')
                                .replaceAll('원', '');
                            final amount = int.tryParse(text) ?? 0;
                            final valid = fundingType == '자유'
                                ? (remainingAmount > 0
                                      ? amount > 0 && amount <= remainingAmount
                                      : amount > 0)
                                : amount > 0;
                            return valid
                                ? AppColors.primaryBase
                                : AppColors.baseLight;
                          })()
                        : AppColors.primaryBase,
                    disabledBackgroundColor: AppColors.baseLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.circular(0)
                          : BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isCharacterStep
                        ? '다음'
                        : _isMessageStep
                        ? '다음'
                        : _isCompleteStep
                        ? '축하 메시지 남기러 가기'
                        : _isParticipateStep
                        ? (_isAmountStep
                              ? (isLastContributor ? '펀딩 완성' : '완료')
                              : '다음')
                        : '펀딩 참여하기',
                    style: AppTypography.button2.copyWith(
                      color: AppColors.baseWhite,
                    ),
                  ),
                ),
              ),
            ),

          if (_selectedParticipant != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _selectedParticipant = null),
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _popupController,
                      curve: Curves.easeOutBack,
                    ),
                    child: _LetterCard(
                      participant: _selectedParticipant!,
                      onClose: () =>
                          setState(() => _selectedParticipant = null),
                    ),
                  ),
                ),
              ),
            ),

          if (_showExitConfirm)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.center,
                child: _ExitConfirmDialog(
                  isCompleteStep: _isCompleteStep,
                  onStay: () => setState(() => _showExitConfirm = false),
                  onExit: () {
                    setState(() => _showExitConfirm = false);
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ),

          if (_showJoinConfirm)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.center,
                child: _JoinConfirmDialog(
                  onPrimary: () {
                    setState(() => _showJoinConfirm = false);
                    // TODO: 로그인/회원가입 화면으로 연결 시 여기에 라우팅 추가
                  },
                  onSecondary: () {
                    setState(() {
                      _showJoinConfirm = false;
                      _isParticipateStep = true;
                    });
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted)
                        FocusScope.of(context).requestFocus(_guestNameFocus);
                    });
                  },
                ),
              ),
            ),

          if (_showPaymentConfirm)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.bottomCenter,
                child: _PaymentConfirmBottomSheet(
                  targetName:
                      widget.data['name'] as String? ?? '친구', // 펀딩받는 사람 이름
                  amount: (() {
                    final text = _guestAmountController.text
                        .replaceAll(',', '')
                        .replaceAll(' ', '')
                        .replaceAll('원', '');
                    return int.tryParse(text) ?? 0;
                  })(),
                  onCancel: () => setState(() => _showPaymentConfirm = false),
                  onConfirm: () {
                    setState(() {
                      _showPaymentConfirm = false;
                    });
                    _navigateToTossPayment();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final Map<String, dynamic> participant;
  final VoidCallback? onClose;

  const _LetterCard({required this.participant, this.onClose});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> letter =
        (participant['letter'] as Map<String, dynamic>?) ?? {};
    final bool isPrivacy = letter['isPrivacy'] == true;
    final String content = (letter['content'] as String?) ?? '';
    final String name = (participant['name'] as String?) ?? '';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'From.',
                        style: AppTypography.suiteBody1.copyWith(
                          color: AppColors.textDarker,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        name,
                        style: AppTypography.suiteBody1.copyWith(
                          color: AppColors.primaryBase,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 160),
                    decoration: BoxDecoration(
                      color: AppColors.baseLighter,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isPrivacy ? '비밀 메시지입니다.' : content,
                      style: AppTypography.suiteBody1.copyWith(
                        color: AppColors.textDarker,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: AppColors.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExitConfirmDialog extends StatelessWidget {
  final VoidCallback onStay;
  final VoidCallback onExit;
  final bool isCompleteStep;

  const _ExitConfirmDialog({
    required this.onStay,
    required this.onExit,
    this.isCompleteStep = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                '정말 나가시겠어요?',
                style: AppTypography.title4.copyWith(
                  color: AppColors.textDarkest,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isCompleteStep
                    ? '이 화면을 나가면\n친구에게 메시지를 남길 수 없어요'
                    : '이 화면을 나가면\n선물 펀딩에 참여할 수 없어요',
                textAlign: TextAlign.center,
                style: AppTypography.body3.copyWith(color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.baseLighter,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '나갈래요',
                      style: AppTypography.button3.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onStay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBase,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCompleteStep ? '계속할게요' : '있을게요',
                      style: AppTypography.button3.copyWith(
                        color: AppColors.baseWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinConfirmDialog extends StatelessWidget {
  final VoidCallback onPrimary; // 로그인/회원가입
  final VoidCallback onSecondary; // 비회원으로 펀딩

  const _JoinConfirmDialog({
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                '회원이신가요?',
                style: AppTypography.title4.copyWith(
                  color: AppColors.textDarkest,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '회원이라면 로그인 해주세요',
                textAlign: TextAlign.center,
                style: AppTypography.body3.copyWith(color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 16),
            // 세로 정렬 버튼 2개
            ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBase,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                '로그인/회원가입',
                style: AppTypography.button3.copyWith(
                  color: AppColors.baseWhite,
                ),
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: onSecondary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.baseLighter,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                '비회원으로 펀딩',
                style: AppTypography.button3.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentConfirmBottomSheet extends StatelessWidget {
  final String targetName; // 펀딩받는 사람 이름
  final int amount;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _PaymentConfirmBottomSheet({
    required this.targetName,
    required this.amount,
    required this.onCancel,
    required this.onConfirm,
  });

  String _formatCurrency(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buffer.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.baseWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제하시겠습니까?',
              style: AppTypography.title1.copyWith(
                color: AppColors.textDarkest,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Text(
                    '$targetName님께',
                    style: AppTypography.title3.copyWith(
                      color: AppColors.textDarkest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.title3.copyWith(
                        color: AppColors.textDarkest,
                      ),
                      children: [
                        TextSpan(
                          text: '${_formatCurrency(amount)}원',
                          style: AppTypography.title1.copyWith(
                            color: AppColors.primaryBase,
                          ),
                        ),
                        const TextSpan(text: ' 펀딩하기'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'lib/feature/give_funding/asset/toss.png',
                width: 200,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '동의하면 토스페이먼츠로 이동합니다',
                style: AppTypography.title5.copyWith(color: AppColors.textDark),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLightest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '취소',
                        style: AppTypography.button2.copyWith(
                          color: AppColors.primaryBase,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBase,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '동의',
                        style: AppTypography.button2.copyWith(
                          color: AppColors.baseWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestFundingForm extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onClose;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final bool isTypingName;
  final ValueChanged<bool> onTypingChange;

  const _GuestFundingForm({
    required this.onBack,
    required this.onClose,
    required this.nameController,
    required this.nameFocusNode,
    required this.isTypingName,
    required this.onTypingChange,
  });

  @override
  State<_GuestFundingForm> createState() => _GuestFundingFormState();
}

class _GuestFundingFormState extends State<_GuestFundingForm> {
  bool get _hasName => widget.nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onNameChanged);
    widget.nameFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onNameChanged);
    widget.nameFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  void _onFocusChange() {
    widget.onTypingChange(widget.nameFocusNode.hasFocus);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
    );
    final bool isTyping = widget.isTypingName;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 카드 본문
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 24 + (isTyping ? 0 : 80)),
              width: 320,
              decoration: BoxDecoration(
                color: AppColors.baseWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // 상단 바
                  Padding(
                    padding: contentPadding,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onBack,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 제목/가이드
                  Padding(
                    padding: contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '생일선물 펀딩',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '차은우ㅇㅇ의 웃으면 안되는 생일파티',
                          style: AppTypography.title5.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '이름(닉네임)을 작성해주세요',
                          style: AppTypography.title1.copyWith(
                            color: AppColors.textDarker,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '친구에게 표시될 이름이에요 (최대 5글자)',
                          style: AppTypography.title5.copyWith(
                            color: AppColors.primaryBase,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 입력 필드
                  Padding(
                    padding: contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: widget.nameController,
                          focusNode: widget.nameFocusNode,
                          maxLength: 5,
                          decoration: const InputDecoration(
                            isDense: true,
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: (isTyping
                              ? AppTypography.title3.copyWith(
                                  color: AppColors.textDarkest,
                                )
                              : AppTypography.title3.copyWith(
                                  color: AppColors.textDark,
                                )),
                          cursorColor: AppColors.primaryLight,
                        ),
                        Container(
                          height: 1.5,
                          color: !_hasName
                              ? (isTyping
                                    ? AppColors.primaryLight
                                    : AppColors.textLightest)
                              : AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // 휴대폰 번호 입력 섹션
                  Opacity(
                    opacity: isTyping ? 0.3 : 1.0,
                    child: Padding(
                      padding: contentPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '휴대폰 번호를 입력해주세요 (선택)',
                            style: AppTypography.title3.copyWith(
                              color: AppColors.textDarker,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '친구에게 감사 메시지를 받을 수 있어요',
                            style: AppTypography.title5.copyWith(
                              color: AppColors.primaryBase.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            enabled: !isTyping,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: AppTypography.title3.copyWith(
                              color: AppColors.textDark,
                            ),
                            cursorColor: AppColors.primaryLight,
                          ),
                          Container(height: 1.5, color: AppColors.textLightest),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),

          // 하단 버튼: 키보드 위로 고정
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _hasName ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasName
                        ? AppColors.primaryBase
                        : AppColors.baseLight,
                    disabledBackgroundColor: AppColors.baseLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.circular(0)
                          : BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    '다음',
                    style: AppTypography.button2.copyWith(
                      color: AppColors.baseWhite,
                    ),
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
