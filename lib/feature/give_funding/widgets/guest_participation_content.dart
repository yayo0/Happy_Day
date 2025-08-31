import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class GuestParticipationContent extends StatefulWidget {
  final Map<String, dynamic> data;
  final TextEditingController nameController;
  final FocusNode nameFocus;
  final bool isAmountStep;
  final TextEditingController? amountController;
  final String? fundingType; // 'N빵' | '자유'
  final int? totalPrice;
  final int? remainingAmount;
  final bool? isLastContributor;

  const GuestParticipationContent({
    super.key,
    required this.data,
    required this.nameController,
    required this.nameFocus,
    this.isAmountStep = false,
    this.amountController,
    this.fundingType,
    this.totalPrice,
    this.remainingAmount,
    this.isLastContributor,
  });

  @override
  State<GuestParticipationContent> createState() => _GuestParticipationContentState();
}

class _GuestParticipationContentState extends State<GuestParticipationContent> {
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = widget.amountController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.amountController == null) {
      _amountController.dispose();
    }
    super.dispose();
  }

  void _formatAmount(String value) {
    // 숫자만 추출
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (numbers.isEmpty) {
      return;
    }
    
    int amount = int.tryParse(numbers) ?? 0;
    
    // 최대 펀딩 가능한 금액 제한
    final maxAmount = widget.remainingAmount ?? 0;
    if (maxAmount > 0 && amount > maxAmount) {
      amount = maxAmount;
    }
    
    // 포맷된 숫자만 TextField에 표시 ("원"은 별도 Text 위젯에서 표시)
    final formatted = _formatCurrency(amount);
    
    if (formatted != value) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTyping = widget.nameFocus.hasFocus;
    final bool hasName = widget.nameController.text.trim().isNotEmpty;
    final double statusBar = MediaQuery.of(context).padding.top;
    const double topBarApprox = 60; // 상단바 대략 높이
    final double minBodyHeight = MediaQuery.of(context).size.height - statusBar - topBarApprox;

    return Container(
        width: double.infinity,
          constraints: BoxConstraints(minHeight: minBodyHeight < 0 ? 0 : minBodyHeight),
          decoration: BoxDecoration(
            color: AppColors.baseWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('생일선물 펀딩', style: AppTypography.caption1.copyWith(color: AppColors.primaryLight)),
              const SizedBox(height: 4),
              Text(
                '${widget.data['name'] as String? ?? '친구'}의 ${widget.data['fundingTitle'] as String? ?? ''}',
                style: AppTypography.title5.copyWith(color: AppColors.textDark),
              ),
              const SizedBox(height: 24),
              if (!widget.isAmountStep) ...[
                Text('이름(닉네임)을 작성해주세요', style: AppTypography.title1.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 8),
                Text('친구에게 표시될 이름이에요 (최대 5글자)', style: AppTypography.title5.copyWith(color: AppColors.primaryBase)),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.nameController,
                  focusNode: widget.nameFocus,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    isDense: true,
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: (isTyping
                      ? AppTypography.title3.copyWith(color: AppColors.textDarkest)
                      : AppTypography.title3.copyWith(color: AppColors.textDark)),
                  cursorColor: AppColors.primaryLight,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 1.5,
                  color: !hasName
                      ? (isTyping ? AppColors.primaryLight : AppColors.textLightest)
                      : AppColors.textLight,
                ),
                const SizedBox(height: 60),
                Opacity(
                  opacity: isTyping ? 0.3 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('휴대폰 번호를 입력해주세요 (선택)', style: AppTypography.title3.copyWith(color: AppColors.textDarker)),
                      const SizedBox(height: 6),
                      Text('친구에게 감사 메시지를 받을 수 있어요', style: AppTypography.title5.copyWith(color: AppColors.primaryBase.withOpacity(0.6))),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.title3.copyWith(color: AppColors.textDark),
                        cursorColor: AppColors.primaryLight,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 1.5,
                        color: AppColors.textLightest,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ] else ...[
                // 금액 입력 단계
                Text('펀딩할 금액을 알려주세요', style: AppTypography.title1.copyWith(color: AppColors.textDarker)),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final type = (widget.fundingType ?? '자유');
                  final remain = (widget.remainingAmount ?? 0);
                  final last = widget.isLastContributor == true;
                  final guide = last
                      ? '마지막 펀딩이에요! 펀딩을 완성해주세요'
                      : (type == 'N빵' ? 'N빵 펀딩은 금액이 정해져 있어요' : '최대 펀딩 가능한 금액은 ${_formatCurrency(remain)}원이에요');
                  return Text(guide, style: AppTypography.title5.copyWith(color: AppColors.primaryBase));
                }),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.title3.copyWith(color: AppColors.textDarkest),
                        cursorColor: AppColors.primaryLight,
                        onChanged: _formatAmount,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '원',
                      style: AppTypography.title3.copyWith(color: AppColors.textDarkest),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 2, color: AppColors.primaryBase),
                const SizedBox(height: 100),
              ],
            ],
          ),
        );
  }

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
}


