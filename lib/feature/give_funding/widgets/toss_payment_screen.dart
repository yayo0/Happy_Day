import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class TossPaymentScreen extends StatefulWidget {
  final String userName;
  final String targetName;
  final int amount;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const TossPaymentScreen({
    super.key,
    required this.userName,
    required this.targetName,
    required this.amount,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<TossPaymentScreen> createState() => _TossPaymentScreenState();
}

class _TossPaymentScreenState extends State<TossPaymentScreen> {
  late PaymentWidget paymentWidget;
  PaymentMethodWidgetControl? paymentMethodControl;
  bool _isLoading = false; // 토스 위젯은 바로 표시
  bool _isPaymentReady = false; // 결제 준비 완료 상태

  @override
  void initState() {
    super.initState();
    _initializePaymentWidget();
  }

  void _initializePaymentWidget() {
    // 토스페이먼츠 결제위젯 초기화 (v2.1.1)
    paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm", // 공식 문서의 테스트 키
      customerKey: "happy_day_customer_${DateTime.now().millisecondsSinceEpoch}",
    );
  }

  void _renderPaymentMethods() async {
    try {
      // 최소한의 지연만 두고 바로 렌더링 시도
      await Future.delayed(const Duration(milliseconds: 100));
      
      final control = await paymentWidget.renderPaymentMethods(
        selector: "payment-methods",
        amount: Amount(
          value: widget.amount,
          currency: Currency.KRW,
          country: "KR",
        ),
      );

      if (mounted) {
        setState(() {
          paymentMethodControl = control;
          _isPaymentReady = true; // 결제 준비 완료
        });
        print('결제 UI 렌더링 성공');
      }
    } catch (e) {
      print('결제 UI 렌더링 오류: $e');
      if (mounted) {
        setState(() {
          _isPaymentReady = false; // 결제는 준비되지 않음
        });
      }
    }
  }

  void _requestPayment() async {
    // 토스 결제 연결 임시 주석처리 - 테스트용으로 바로 완료화면으로 이동
    widget.onSuccess();
    
    /* 실제 토스 결제 로직 (임시 주석처리)
    if (paymentMethodControl == null) return;

    try {
      final orderId = "happy_day_order_${DateTime.now().millisecondsSinceEpoch}";
      
      final result = await paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: orderId,
          orderName: "${widget.targetName}님께 펀딩",
        ),
      );

      if (result.success != null) {
        // 결제 성공
        widget.onSuccess();
      } else if (result.fail != null) {
        // 결제 실패
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제에 실패했습니다: ${result.fail!.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('결제 요청 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('결제 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    */
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseWhite,
      appBar: AppBar(
        backgroundColor: AppColors.baseWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: widget.onCancel,
        ),
        title: Text(
          '결제하기',
          style: AppTypography.title4.copyWith(color: AppColors.textDarkest),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 결제 정보 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.baseLightest,
              border: Border(bottom: BorderSide(color: AppColors.baseLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '결제 정보',
                  style: AppTypography.title3.copyWith(color: AppColors.textDarkest),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '펀딩 대상',
                      style: AppTypography.body2.copyWith(color: AppColors.textDark),
                    ),
                    Text(
                      '${widget.targetName}님',
                      style: AppTypography.body2.copyWith(color: AppColors.textDarkest),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '결제 금액',
                      style: AppTypography.body2.copyWith(color: AppColors.textDark),
                    ),
                    Text(
                      '${_formatCurrency(widget.amount)}원',
                      style: AppTypography.title3.copyWith(color: AppColors.primaryBase),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 토스페이먼츠 결제 UI
          Expanded(
            child: Builder(
              builder: (context) {
                // PaymentMethodWidget이 빌드된 후 renderPaymentMethods 호출
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (paymentMethodControl == null) {
                    _renderPaymentMethods();
                  }
                });
                
                return PaymentMethodWidget(
                  paymentWidget: paymentWidget,
                  selector: "payment-methods",
                );
              },
            ),
          ),

          // 결제하기 버튼
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            decoration: BoxDecoration(
              color: AppColors.baseWhite,
              border: Border(top: BorderSide(color: AppColors.baseLight)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPaymentReady ? _requestPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPaymentReady ? AppColors.primaryBase : AppColors.baseLight,
                  disabledBackgroundColor: AppColors.baseLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isPaymentReady 
                      ? '${_formatCurrency(widget.amount)}원 결제하기'
                      : '결제 준비 중...',
                  style: AppTypography.button2.copyWith(
                    color: _isPaymentReady ? AppColors.baseWhite : AppColors.textLight,
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
