import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';
import 'kpostal_screen.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'dart:math';

class MakeFundingScreen extends StatefulWidget {
  const MakeFundingScreen({super.key});

  @override
  State<MakeFundingScreen> createState() => _MakeFundingScreenState();
}

class _MakeFundingScreenState extends State<MakeFundingScreen> {
  int _currentStep = 0;
  bool _isEditing = false;
  String? _selectedGiftType; // 'person' 또는 'group'
  String? _selectedFundingType; // 'n_way' 또는 'free'
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _manualPriceController = TextEditingController();
  final TextEditingController _participantCountController =
      TextEditingController();

  // 새로운 step들을 위한 상태 변수들
  final TextEditingController _fundingNameController = TextEditingController();
  final TextEditingController _fundingDescriptionController =
      TextEditingController();
  XFile? _selectedImage;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _currentMonth = DateTime.now();
  static const String _graphqlEndpoint = 'http://54.180.152.8/graphql/';
  Future<void> _submitFunding() async {
    try {
      final uuid = context.read<UserSession>().uuid;
      if (uuid == null) return;

      final dio = Dio(
        BaseOptions(
          baseUrl: _graphqlEndpoint,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      // 1) uuid -> user id
      final qUser = {
        'query': r'query($uuid: String!) { user_by_uuid(uuid: $uuid) { id } }',
        'variables': {'uuid': uuid},
      };
      final resUser = await dio.post('', data: jsonEncode(qUser));
      final Map<String, dynamic> dataUser = resUser.data is String
          ? json.decode(resUser.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(resUser.data as Map);
      final dynamic idRaw = dataUser['data']?['user_by_uuid']?['id'];
      int? userId;
      if (idRaw is int)
        userId = idRaw;
      else if (idRaw is String)
        userId = int.tryParse(idRaw);
      if (userId == null) return;

      // 2) 선택된 배송지 ID 가져오기
      int? addressId;
      if (_selectedDeliveryAddress != null) {
        final selectedAddress = _deliveryAddresses.firstWhere(
          (addr) => addr['name'] == _selectedDeliveryAddress,
          orElse: () => {},
        );
        if (selectedAddress.isNotEmpty && selectedAddress['id'] != null) {
          addressId = int.tryParse(selectedAddress['id']!);
        }
      }

      if (addressId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('배송지를 선택해 주세요')));
        return;
      }

      // 3) 펀딩 생성
      final isNWay = _selectedFundingType == 'n_way';
      final payload = {
        'query':
            r'mutation($user_id: Int!, $address_id: Int!, $target: String!, $item: String!, $funding_name: String!, $funding_amount: Int!, $funding_start_date: Date!, $funding_end_date: Date!, $funding_type: String!, $funding_status: String, $funding_description: String!, $minimum_amount: Int, $funding_people_number: Int) { create_funding(user_id: $user_id, address_id: $address_id, target: $target, item: $item, funding_name: $funding_name, funding_amount: $funding_amount, funding_start_date: $funding_start_date, funding_end_date: $funding_end_date, funding_type: $funding_type, funding_status: $funding_status, funding_description: $funding_description, minimum_amount: $minimum_amount, funding_people_number: $funding_people_number) { success error funding { id } } }',
        'variables': {
          'user_id': userId,
          'address_id': addressId,
          'target': _selectedGiftType == 'person' ? '본인' : '친구',
          'item': _linkController.text.isNotEmpty ? '링크상품' : '직접입력',
          'funding_name': _fundingNameController.text,
          'funding_amount':
              int.tryParse(_getFinalPrice().replaceAll(',', '')) ?? 0,
          'funding_start_date': _startDate != null
              ? _startDate!.toIso8601String().split('T').first
              : DateTime.now().toIso8601String().split('T').first,
          'funding_end_date': _endDate != null
              ? _endDate!.toIso8601String().split('T').first
              : DateTime.now().toIso8601String().split('T').first,
          'funding_type': isNWay ? 'N빵' : '자유',
          'funding_status': 'ready',
          'funding_description': _fundingDescriptionController.text,
          'minimum_amount': isNWay ? null : 3000,
          'funding_people_number': isNWay
              ? int.tryParse(_participantCountController.text)
              : null,
        },
      };
      final res = await dio.post('', data: jsonEncode(payload));
      final Map<String, dynamic> data = res.data is String
          ? json.decode(res.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(res.data as Map);
      final ok = data['data']?['create_funding']?['success'] == true;
      if (!mounted) return;
      if (ok) {
        setState(() {
          _currentStep = 8;
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('펀딩 저장에 실패했어요. 다시 시도해 주세요.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류가 발생했어요: $e')));
    }
  }

  // 배송지 관련 상태 변수들
  @override
  void initState() {
    super.initState();
    debugPrint(
      'MakeFundingScreen initState, _currentStep=' + _currentStep.toString(),
    );
  }

  String? _selectedDeliveryAddress;
  final List<Map<String, String>> _deliveryAddresses = [];

  // 가격 측정 관련 상태
  bool _isPriceMeasuring = false;
  bool _isPriceMeasured = false;
  bool _isPriceConfirmed = false;
  bool _isCrawlingFailed = false;
  bool _showManualPriceModal = false;
  String _measuredPrice = '89,000';
  String _manualPrice = '';
  String _selectedProductName = ''; // 선택된 상품명

  // 가격과 상품명 매핑 데이터
  final Map<String, String> _priceProductMapping = {
    '80000': '나이키 반팔',
    '15000': '나이키 양말',
    '12000': '나이키 헤어밴드',
    '50000': '스타벅스 5만원권',
    '60000': '아디다스 반바지',
    '70000': '아디다스 반팔',
    '30000': '나이키 양말',
    '65000': '칼하트 모자',
    '10000': '스타벅스 1만원권',
    '100000': '에어팟 1',
  };

  // 새 배송지 추가를 위한 컨트롤러들
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    debugPrint('MakeFundingScreen dispose');
    debugPrintStack(label: 'MakeFundingScreen dispose stack');
    _linkController.dispose();
    _manualPriceController.dispose();
    _participantCountController.dispose();
    _fundingNameController.dispose();
    _fundingDescriptionController.dispose();
    _recipientController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentStep == 7
          ? AppColors.primaryLightest
          : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 섹션
                _currentStep == 8
                    ? _buildCompletionTopSection()
                    : _buildTopSection(),

                // 중앙 콘텐츠 섹션
                Expanded(child: _buildContentSection()),

                // 하단 버튼 섹션
                _currentStep == 8
                    ? const SizedBox.shrink()
                    : _buildBottomSection(),
              ],
            ),

            // 모달 오버레이
            if ((_isPriceMeasured && !_isPriceConfirmed) ||
                _showManualPriceModal)
              _buildPriceModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      color: _currentStep == 7 ? AppColors.primaryLightest : Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 20),
        child: Row(
          children: [
            // 뒤로가기 버튼
            IconButton(
              onPressed: () {
                debugPrint(
                  'TopBack pressed, _currentStep=' + _currentStep.toString(),
                );
                if (_currentStep > 0) {
                  setState(() {
                    if (_currentStep == 7) {
                      _currentStep = 5;
                    } else {
                      _currentStep--;
                    }
                    debugPrint(
                      'TopBack setState -> _currentStep=' +
                          _currentStep.toString(),
                    );
                  });
                } else {
                  debugPrint('TopBack will pop from MakeFundingScreen');
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textDark,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),

            // 가운데 현재 스텝 디버그 표시
            Expanded(child: Center()),

            // 오른쪽 X 버튼
            IconButton(
              onPressed: () {
                debugPrint(
                  'TopRight X pressed, will pop from MakeFundingScreen',
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: const Icon(
                Icons.close,
                color: AppColors.textDark,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionTopSection() {
    return Container(
      color: AppColors.baseWhite,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 20),
        child: Row(
          children: [
            // 왼쪽 빈 공간 (뒤로가기 버튼 자리)
            const SizedBox(width: 48),

            // 가운데 빈 공간
            const Expanded(child: SizedBox()),

            // 오른쪽 X 버튼만
            IconButton(
              onPressed: () {
                debugPrint(
                  'Completion X pressed, will pop from MakeFundingScreen',
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: const Icon(
                Icons.close,
                color: AppColors.textDark,
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    debugPrint('Build Content for _currentStep=' + _currentStep.toString());
    // step 7에 도달할 때마다 편집 모드 초기화
    if (_currentStep == 7 && _isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isEditing = false;
          debugPrint('Step 7: _isEditing reset to false');
        });
      });
    }

    switch (_currentStep) {
      case 0:
        return _buildGiftTypeSelection();
      case 1:
        return _buildItemSelection();
      case 2:
        return _buildFundingTypeSelection();
      case 3:
        return _buildFundingInfoInput();
      case 4:
        return _buildDateSelection();
      case 5:
        return _buildDeliveryAddressSelection();
      case 6:
        return _buildAddNewDeliveryAddress();
      case 7:
        return _buildReviewStep();
      case 8:
        return _buildCompletionStep();
      default:
        return _buildGiftTypeSelection();
    }
  }

  // 첫 번째 step: 선물 유형 선택
  Widget _buildGiftTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 질문
          Text(
            '누가 받는 선물인가요?',
            style: AppTypography.heading2.copyWith(
              color: const Color(0xFF242221),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // 주황색 설명
          Text(
            '수령자를 선택해 주세요',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.primary500,
            ),
          ),

          const Spacer(),

          // 선물 유형 선택 카드들
          Row(
            children: [
              // 개인 선물 카드
              Expanded(
                child: _buildGiftTypeCard(
                  'person',
                  '제가 받는\n선물이에요',
                  isSelected: _selectedGiftType == 'person',
                ),
              ),

              const SizedBox(width: 16),

              // 그룹 선물 카드
              Expanded(
                child: _buildGiftTypeCard(
                  'group',
                  '친구에게 주는\n선물이에요',
                  isSelected: _selectedGiftType == 'group',
                ),
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // 선물 유형 카드
  Widget _buildGiftTypeCard(
    String type,
    String label, {
    required bool isSelected,
  }) {
    String imagePath = isSelected
        ? 'assets/icons/${type}-select.png'
        : 'assets/icons/$type.png';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGiftType = type;
          debugPrint(
            'GiftType selected -> ' +
                type +
                ', _currentStep=' +
                _currentStep.toString(),
          );
        });
      },
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLightest : AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : AppColors.gray300,
            width: isSelected ? 2 : 0.1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTypography.button2.copyWith(
                color: isSelected ? AppColors.primary500 : AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 세 번째 step: 펀딩 방식 선택
  Widget _buildFundingTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 질문
          Text(
            '펀딩 방식을 선택해 주세요',
            style: AppTypography.heading2.copyWith(
              color: const Color(0xFF242221),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // 주황색 설명
          Text(
            '어떤 방식으로 펀딩을 진행할까요?',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.primary500,
            ),
          ),

          // 펀딩 방식 선택 전: 상하 중앙정렬 유지
          if (_selectedFundingType == null) ...[
            const Spacer(),
            Row(
              children: [
                // N빵 펀딩 카드
                Expanded(
                  child: _buildFundingTypeCard(
                    'n_way',
                    'N빵 펀딩',
                    '참여 인원 모두\n같은 금액으로 펀딩해요',
                    isSelected: _selectedFundingType == 'n_way',
                  ),
                ),

                const SizedBox(width: 16),

                // 자유 펀딩 카드
                Expanded(
                  child: _buildFundingTypeCard(
                    'free',
                    '자유 펀딩',
                    '참여 인원 각자\n원하는 금액으로 펀딩해요',
                    isSelected: _selectedFundingType == 'free',
                  ),
                ),
              ],
            ),
            // N빵 펀딩 선택 시 참여 인원 수 입력
          ] else ...[
            const SizedBox(height: 24),
            Row(
              children: [
                // N빵 펀딩 카드
                Expanded(
                  child: _buildFundingTypeCard(
                    'n_way',
                    'N빵 펀딩',
                    '참여 인원 모두\n같은 금액으로 펀딩해요',
                    isSelected: _selectedFundingType == 'n_way',
                  ),
                ),

                const SizedBox(width: 16),

                // 자유 펀딩 카드
                Expanded(
                  child: _buildFundingTypeCard(
                    'free',
                    '자유 펀딩',
                    '참여 인원 각자\n원하는 금액으로 펀딩해요',
                    isSelected: _selectedFundingType == 'free',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // N빵 펀딩 선택 시 참여 인원 수 입력
          ],
          if (_selectedFundingType == 'n_way') ...[
            const SizedBox(height: 24),
            Text(
              '참여 인원 수를 설정해 주세요',
              style: AppTypography.heading2.copyWith(
                color: const Color(0xFF242221),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 360,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.baseLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _participantCountController,
                keyboardType: TextInputType.number,
                style: AppTypography.title5.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'N 명이 참여해요',
                  hintStyle: AppTypography.subtitle2.copyWith(
                    color: AppColors.gray500,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            if (_participantCountController.text.isNotEmpty) ...[
              const SizedBox(height: 140),
              Align(
                alignment: Alignment.bottomCenter,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '인당 펀딩 금액은\n',
                        style: AppTypography.title3.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '${_calculatePerPersonAmount()}원',
                        style: AppTypography.title3.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      TextSpan(
                        text: ' 이에요',
                        style: AppTypography.title3.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],

          // 자유 펀딩 선택 시 최소 금액 안내
          if (_selectedFundingType == 'free') ...[
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '*인당 펀딩 최소 금액은 ',
                    style: AppTypography.title5.copyWith(color: Colors.black),
                  ),
                  TextSpan(
                    text: '3,000원',
                    style: AppTypography.title5.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                  TextSpan(
                    text: ' 이에요',
                    style: AppTypography.title5.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 아무것도 선택되지 않은 경우에만 Spacer 사용
            const Spacer(),
          ],
        ],
      ),
    );
  }

  // 펀딩 방식 카드
  Widget _buildFundingTypeCard(
    String type,
    String title,
    String description, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFundingType = type;
          debugPrint('FundingType selected -> ' + type);
        });
      },
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLightest
              : AppColors.baseLightest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.gray300,
            width: isSelected ? 2 : 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF141414).withOpacity(0.08),
              offset: const Offset(0, 1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF141414).withOpacity(0.08),
              offset: const Offset(0, 0),
              blurRadius: 1,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTypography.title4.copyWith(color: AppColors.primary500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: AppTypography.caption1.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 두 번째 step: 물건 펀딩 링크 입력
  Widget _buildItemSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 질문
          Text(
            '어떤 물건을 펀딩할까요?',
            style: AppTypography.heading2.copyWith(
              color: const Color(0xFF242221),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          // 주황색 설명
          Text(
            '다양한 방법 중에 선택해요',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.primary500,
            ),
          ),

          const SizedBox(height: 40),

          // 링크 입력 섹션
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '링크 붙여넣기',
                style: AppTypography.title4.copyWith(
                  color: const Color(0xFF242221),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 360,
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.baseLighter,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _linkController,
                  style: AppTypography.title5.copyWith(
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: '구매 링크를 붙여넣어 주세요',
                    hintStyle: AppTypography.subtitle2.copyWith(
                      color: AppColors.gray500,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 링크 변경 시 기존 측정 상태 초기화
                      _isPriceMeasuring = false;
                      _isPriceMeasured = false;
                      _isPriceConfirmed = false;
                      _isCrawlingFailed = false;
                      _showManualPriceModal = false;
                      _manualPrice = '';
                    });
                    // 값이 존재하면 즉시 재측정 시작
                    if (value.isNotEmpty) {
                      _startPriceMeasurement();
                    }
                  },
                  onTapOutside: (event) {
                    if (_linkController.text.isNotEmpty &&
                        !_isPriceMeasured &&
                        !_isCrawlingFailed) {
                      _startPriceMeasurement();
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 구매 링크를 붙여넣어 주세요',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 대안 선택 옵션들
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlternativeOption('위시에서 고를래요 →'),
              const SizedBox(height: 16),
              _buildAlternativeOption('큐레이션 둘러볼래요 →'),
            ],
          ),

          // 가격 측정 결과 섹션
          if (_isPriceMeasuring || _isPriceMeasured || _isCrawlingFailed) ...[
            const SizedBox(height: 40),
            Text(
              '선물 최종 금액이에요',
              style: AppTypography.heading2.copyWith(
                color: const Color(0xFF242221),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            if (_isPriceMeasuring) ...[
              Text(
                '링크 내 가격 측정 중...',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textLighter,
                ),
              ),
            ] else if (_isCrawlingFailed && !_isPriceConfirmed) ...[
              // 크롤링 실패 시 수동 가격 입력
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '*가격 측정이 안 돼요 직접 입력해 주세요',
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.baseLighter,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _manualPriceController,
                          keyboardType: TextInputType.number,
                          style: AppTypography.title5.copyWith(
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: '가격 입력',
                            hintStyle: AppTypography.subtitle2.copyWith(
                              color: AppColors.gray500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _manualPrice = value;
                            });
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 9,
                          child: SizedBox(
                            width: 80,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: _manualPrice.isNotEmpty
                                  ? _confirmManualPrice
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _manualPrice.isNotEmpty
                                    ? AppColors.primaryLightest
                                    : AppColors.baseLightest,
                                foregroundColor: _manualPrice.isNotEmpty
                                    ? AppColors.primaryBase
                                    : AppColors.textLighter,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: _manualPrice.isNotEmpty
                                        ? AppColors.primaryLight
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                '입력 완료',
                                style: AppTypography.button4.copyWith(
                                  color: _manualPrice.isNotEmpty
                                      ? AppColors.primaryBase
                                      : AppColors.textLighter,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else if (_isPriceConfirmed) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${_getFinalPrice()}원',
                          style: AppTypography.title3.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                        TextSpan(
                          text: '으로 측정되었어요',
                          style: AppTypography.body1.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _handlePriceIncorrect,
                      child: Text(
                        '혹시 측정이 잘못되었나요?',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.textDark,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  // 가격 측정 시작
  void _startPriceMeasurement() {
    setState(() {
      _isPriceMeasuring = true;
      debugPrint('Price measurement started, link=' + _linkController.text);
    });

    // 1초 후 가격 측정 완료
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // 무작위로 상품 선택
        final random = Random();
        final productKeys = _priceProductMapping.keys.toList();
        final randomKey = productKeys[random.nextInt(productKeys.length)];
        final selectedPrice = randomKey;
        final selectedProduct = _priceProductMapping[randomKey]!;

        setState(() {
          _isPriceMeasuring = false;
          _isPriceMeasured = true;
          _measuredPrice = selectedPrice;
          _selectedProductName = selectedProduct;
          debugPrint(
            'Price measurement finished, measuredPrice=$selectedPrice, product=$selectedProduct',
          );
        });
      }
    });
  }

  // 가격 측정 확인
  void _confirmPrice() {
    setState(() {
      _isPriceConfirmed = true;
      // 모달을 닫기 위해 상태 업데이트
      if (_isCrawlingFailed) {
        // 수동 입력의 경우 모달을 닫고 가격 측정 완료 상태로 변경
        _showManualPriceModal = false;
        // 수동 입력 완료 시에도 가격 측정이 완료된 것으로 처리
        _isPriceMeasured = true;
      }
    });
  }

  // 수동 가격 입력 확인
  void _confirmManualPrice() {
    setState(() {
      _isPriceConfirmed = true;
      _measuredPrice = _manualPrice;
      // 수동 입력 완료 시 모달 표시
      _showManualPriceModal = true;
      debugPrint('Manual price confirmed, price=' + _manualPrice);
    });
  }

  // 가격이 잘못 측정되었을 때 처리
  void _handlePriceIncorrect() {
    setState(() {
      _isCrawlingFailed = true;
      _isPriceMeasured = false;
      _isPriceConfirmed = false;
      _showManualPriceModal = false;
      _manualPrice = '';
      _manualPriceController.clear();
      debugPrint('Price incorrect clicked, switch to manual input');
    });
  }

  // 원금 반환
  String _getBasePrice() {
    if (_isCrawlingFailed && _manualPrice.isNotEmpty) {
      return _manualPrice;
    }
    return _measuredPrice;
  }

  // 최종 가격 반환 (원금의 1.01배 - 1% 수수료)
  String _getFinalPrice() {
    String basePrice = _getBasePrice();

    // 쉼표 제거하고 숫자로 변환
    String cleanPrice = basePrice.replaceAll(',', '');
    double? price = double.tryParse(cleanPrice);

    if (price != null) {
      // 1.01배 계산 후 쉼표 포함하여 반환
      double finalPrice = price * 1.01;
      return _formatNumberWithCommas(finalPrice.toInt().toString());
    }

    return basePrice;
  }

  // 인당 펀딩 금액 계산
  String _calculatePerPersonAmount() {
    if (_participantCountController.text.isEmpty) return '';

    String finalPrice = _getFinalPrice();
    String cleanPrice = finalPrice.replaceAll(',', '');
    double? price = double.tryParse(cleanPrice);
    int? participantCount = int.tryParse(_participantCountController.text);

    if (price != null && participantCount != null && participantCount > 0) {
      // 최종 금액을 참여 인원으로 나누고 반올림
      double perPersonAmount = price / participantCount;
      return _formatNumberWithCommas(perPersonAmount.round().toString());
    }

    return '';
  }

  // 숫자에 3자리마다 쉼표 추가하는 헬퍼 메서드
  String _formatNumberWithCommas(String number) {
    if (number.isEmpty) return number;

    // 숫자가 아닌 문자 제거
    String cleanNumber = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.isEmpty) return number;

    // 3자리마다 쉼표 추가
    final result = StringBuffer();
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && (cleanNumber.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(cleanNumber[i]);
    }

    return result.toString();
  }

  // 가격 측정 모달
  Widget _buildPriceModal() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0x80000000),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 제목과 가격
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '선물 최종 금액은\n',
                      style: AppTypography.heading2.copyWith(
                        color: const Color(0xFF242221),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '${_getFinalPrice()}원',
                      style: AppTypography.title3.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '으로 측정되었어요',
                      style: AppTypography.body1.copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 설명 텍스트
              Text(
                '원금과 수수료를 분리해 보여드려요.\n최종 결제금액을 투명하게 확인하세요.',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textLighter,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 원금 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '원금',
                    style: AppTypography.body1.copyWith(color: Colors.black),
                  ),
                  Text(
                    '${_getBasePrice()}원',
                    style: AppTypography.body1.copyWith(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 최종 결제 금액 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '최종 결제 금액',
                        style: AppTypography.body1.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '총 ${_getFinalPrice()}원',
                        style: AppTypography.body1.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(수수료율·부가세 포함)',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 수수료 안내
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '① ',
                    style: AppTypography.caption1.copyWith(color: Colors.blue),
                  ),
                  Expanded(
                    child: Text(
                      '수수료란? 결제 대행 및 서비스 운영에 필요한 비용입니다.',
                      style: AppTypography.caption1.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 확인했어요 버튼
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _confirmPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '확인했어요',
                    style: AppTypography.button2.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 대안 선택 옵션
  Widget _buildAlternativeOption(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: 해당 기능 구현
      },
      child: Container(
        padding: const EdgeInsets.only(top: 4, bottom: 4, left: 12, right: 12),
        width: 180,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primaryLightest,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTypography.button3.copyWith(color: AppColors.primaryBase),
        ),
      ),
    );
  }

  // 네 번째 step: 펀딩 정보 입력
  Widget _buildFundingInfoInput() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 펀딩 이름 입력
            Text(
              '펀딩의 이름을 지어 주세요',
              style: AppTypography.heading2.copyWith(
                color: const Color(0xFF242221),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '누구에게 주는지, 어떤 선물인지 알릴 수 있으면 좋아요',
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 360,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.baseLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _fundingNameController,
                style: AppTypography.title5.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: '펀딩명 입력',
                  hintStyle: AppTypography.subtitle2.copyWith(
                    color: AppColors.gray500,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 40),

            // 사진 첨부
            Text(
              '사진을 첨부해 주세요',
              style: AppTypography.heading2.copyWith(
                color: const Color(0xFF242221),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '우리의 추억이 담긴 소중한 사진은 어때요?',
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '(선택)',
                    style: AppTypography.title5.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.baseLighter,
                  border: Border.all(color: AppColors.baseDark, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.landscape,
                            color: AppColors.gray500,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Icon(Icons.add, color: AppColors.gray500, size: 24),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 40),

            // 펀딩 설명 입력
            Text(
              '펀딩을 간단히 설명해 주세요',
              style: AppTypography.heading2.copyWith(
                color: const Color(0xFF242221),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '펀딩 설명을 잘 해줄수록 성공 확률이 올라가요',
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '(선택)',
                    style: AppTypography.title5.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 360,
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.baseLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _fundingDescriptionController,
                maxLines: null,
                maxLength: 800,
                style: AppTypography.title5.copyWith(color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: '펀딩내용 입력 (최대 800자)',
                  hintStyle: AppTypography.subtitle2.copyWith(
                    color: AppColors.gray500,
                  ),
                  border: InputBorder.none,
                  counterStyle: AppTypography.caption1.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 100), // 하단 버튼과의 간격
          ],
        ),
      ),
    );
  }

  // 다섯 번째 step: 날짜 선택
  Widget _buildDateSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // 설명
          Text(
            '펀딩 기간을 설정해 주세요',
            style: AppTypography.heading2.copyWith(
              color: const Color(0xFF242221),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '언제부터 언제까지 진행할까요?',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.primary500,
            ),
          ),

          const SizedBox(height: 24),

          // 커스텀 캘린더
          _buildCustomCalendar(),

          const SizedBox(height: 40),

          // 선택된 날짜 표시
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '펀딩 시작일',
                      style: AppTypography.title4.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _startDate != null
                          ? '${_startDate!.year}. ${_startDate!.month.toString().padLeft(2, '0')}. ${_startDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeek(_startDate!)})'
                          : 'YYYY. MM. DD (D)',
                      style: AppTypography.title5.copyWith(
                        color: _startDate != null
                            ? AppColors.textDark
                            : AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '펀딩 목표일',
                      style: AppTypography.title4.copyWith(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _endDate != null
                          ? '${_endDate!.year}. ${_endDate!.month.toString().padLeft(2, '0')}. ${_endDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeek(_endDate!)})'
                          : 'YYYY. MM. DD (D)',
                      style: AppTypography.title5.copyWith(
                        color: _endDate != null
                            ? AppColors.textDark
                            : AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 이미지 선택 및 저장
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // 커스텀 캘린더 위젯
  Widget _buildCustomCalendar() {
    final daysInMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final firstWeekday = firstDayOfMonth.weekday;

    List<Widget> calendarDays = [];

    // 이전 달의 마지막 날들 (빈 칸) - 요일 계산 수정
    // Flutter의 weekday는 1(월요일)~7(일요일)이므로, 일요일부터 시작하려면 7(일요일)일 때 0, 1(월요일)일 때 1, ... 6(토요일)일 때 6
    int emptyDays = 0;
    if (firstWeekday == 7) {
      // 일요일
      emptyDays = 0;
    } else {
      emptyDays = firstWeekday;
    }

    for (int i = 0; i < emptyDays; i++) {
      calendarDays.add(const SizedBox(width: 40, height: 40));
    }

    // 현재 달의 날들
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected = _isDateInRange(date);
      final isStartDate = _startDate != null && _isSameDate(date, _startDate!);
      final isEndDate = _endDate != null && _isSameDate(date, _endDate!);
      final isSunday = date.weekday == 7;

      calendarDays.add(
        GestureDetector(
          onTap: () => _onDateSelected(date),
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary500 : Colors.transparent,
              borderRadius: _getDateBorderRadius(isStartDate, isEndDate),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: AppTypography.title5.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isSunday
                      ? AppColors.primary500
                      : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 390,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 월/년도 헤더와 네비게이션
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.baseLighter, width: 1),
                ),
                child: IconButton(
                  onPressed: _previousMonth,
                  icon: const Icon(Icons.chevron_left, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${_currentMonth.year}.${_currentMonth.month.toString().padLeft(2, '0')}',
                style: AppTypography.title4.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.baseLighter, width: 1),
                ),
                child: IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right, size: 16),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              return SizedBox(
                width: 40,
                child: Text(
                  day,
                  style: AppTypography.title5.copyWith(
                    color: day == '일'
                        ? AppColors.primary500
                        : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 날짜 그리드
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
              ),
              itemCount: calendarDays.length,
              itemBuilder: (context, index) {
                return calendarDays[index];
              },
              // 경계선 제거
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
            ),
          ),
        ],
      ),
    );
  }

  // 날짜가 선택된 범위에 있는지 확인
  bool _isDateInRange(DateTime date) {
    if (_startDate == null) return false;

    // 시작일만 선택된 경우
    if (_endDate == null) {
      return _isSameDate(date, _startDate!);
    }

    // 시작일과 종료일이 같은 경우 (당일 선택)
    if (_isSameDate(_startDate!, _endDate!)) {
      return _isSameDate(date, _startDate!);
    }

    // 시작일부터 종료일까지 포함 (이어서 채워지기)
    // date가 시작일과 같거나, 종료일과 같거나, 그 사이에 있는 경우
    return date.isAtSameMomentAs(_startDate!) ||
        date.isAtSameMomentAs(_endDate!) ||
        (date.isAfter(_startDate!) && date.isBefore(_endDate!));
  }

  // 두 날짜가 같은 날인지 확인
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 날짜 선택 처리
  void _onDateSelected(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // 새로운 선택 시작
        _startDate = date;
        _endDate = null;
        debugPrint('Calendar select startDate=' + _startDate.toString());
      } else {
        // 종료 날짜 선택
        if (date.isAfter(_startDate!) || _isSameDate(date, _startDate!)) {
          // 같은 날짜도 선택 가능하도록 수정
          _endDate = date;
          debugPrint('Calendar select endDate=' + _endDate.toString());
        } else {
          // 선택한 날짜가 시작일보다 이전인 경우
          _startDate = date;
          _endDate = null;
          debugPrint('Calendar reselect startDate=' + _startDate.toString());
        }
      }
    });
  }

  // 이전 달로 이동
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  // 다음 달로 이동
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  // 요일을 한글로 변환
  String _getDayOfWeek(DateTime date) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }

  // 날짜별 테두리 반경 결정
  BorderRadius _getDateBorderRadius(bool isStartDate, bool isEndDate) {
    // 시작일과 종료일이 모두 설정된 경우 (기간 선택)
    if (_startDate != null && _endDate != null) {
      if (isStartDate && isEndDate) {
        // 시작일과 종료일이 같은 경우 (당일 선택)
        return BorderRadius.circular(20);
      } else if (isStartDate) {
        // 시작일 (왼쪽 둥근 모서리)
        return const BorderRadius.horizontal(
          left: Radius.circular(20),
          right: Radius.zero,
        );
      } else if (isEndDate) {
        // 종료일 (오른쪽 둥근 모서리)
        return const BorderRadius.horizontal(
          left: Radius.zero,
          right: Radius.circular(20),
        );
      } else {
        // 중간 날짜들 (직사각형)
        return BorderRadius.zero;
      }
    } else {
      // 시작일만 선택된 경우 (동그라미)
      return BorderRadius.circular(20);
    }
  }

  Widget _buildDeliveryAddressSelection() {
    // 배송지 데이터가 비어있으면 초기화
    if (_deliveryAddresses.isEmpty) {
      _initializeDeliveryAddresses();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 메인 안내 문구
            Text(
              '펀딩 완료 후\n배송 받을 주소를 입력해주세요',
              style: AppTypography.heading2.copyWith(
                color: const Color(0xFF242221),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '어디로 배송 받을까요?',
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 32),
            // 새 배송지 추가 버튼
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = 6; // 새 배송지 추가 step으로 이동
                });
              },
              child: Container(
                width: 360,
                height: 50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.baseLighter,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.gray500, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '지번, 도로명, 건물명으로 검색',
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 이전 사용 주소지
            Text(
              '이전 사용 주소지',
              style: AppTypography.caption1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            // 배송지 리스트
            ..._deliveryAddresses
                .map((address) => _buildDeliveryAddressCard(address))
                .toList(),
            const SizedBox(height: 20), // 하단 버튼과의 간격 (스크롤 내부)
          ],
        ),
      ),
    );
  }

  // 새 배송지 추가 step
  Widget _buildAddNewDeliveryAddress() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              '새 배송지 추가',
              style: AppTypography.title3.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 40),

            _buildInputField(
              controller: _recipientController,
              hintText: '수령인',
              width: 360,
            ),
            const SizedBox(height: 40),

            Row(
              children: [
                _buildInputField(
                  controller: _postalCodeController,
                  hintText: '우편번호',
                  width: 245,
                ),
                const SizedBox(width: 15),
                _buildPostalCodeSearchButton(),
              ],
            ),
            const SizedBox(height: 40),

            _buildInputField(
              controller: _addressController,
              hintText: '주소',
              width: 360,
            ),
            const SizedBox(height: 40),

            _buildInputField(
              controller: _detailAddressController,
              hintText: '상세주소',
              width: 360,
            ),
            const SizedBox(height: 40),

            _buildInputField(
              controller: _phoneController,
              hintText: '연락처',
              width: 360,
            ),

            const SizedBox(height: 40),
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  // Step6 전용 입력 필드
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required double width,
  }) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.baseLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.title5.copyWith(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.subtitle2.copyWith(
                  color: AppColors.gray500,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                setState(() {});
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.close, color: AppColors.gray500, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostalCodeSearchButton() {
    return GestureDetector(
      onTap: () async {
        try {
          debugPrint('Step6: open KpostalScreenReturn');
          Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
              builder: (context) => KpostalScreenReturn(
                onResult: (map) {
                  debugPrint('Step6: onResult received -> ' + map.toString());
                  if (!mounted) return;
                  setState(() {
                    _postalCodeController.text = '${map['postalCode'] ?? ''}';
                    _addressController.text = '${map['address'] ?? ''}';
                    _currentStep = 6;
                  });
                },
              ),
              fullscreenDialog: false,
            ),
          );
        } catch (e) {
          debugPrint('Step6: postal search error - $e');
        }
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.baseLightest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.baseBase, width: 2),
        ),
        child: Center(
          child: Text(
            '우편번호 검색',
            style: AppTypography.button4.copyWith(color: AppColors.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    final isFormValid =
        _recipientController.text.isNotEmpty &&
        _postalCodeController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _detailAddressController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: SizedBox(
        width: 360,
        height: 60,
        child: ElevatedButton(
          onPressed: isFormValid ? _completeAddress : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid
                ? const Color(0xFFFF6622)
                : const Color(0xFFE4E4E4),
            foregroundColor: isFormValid
                ? Colors.white
                : const Color(0xFF242221),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            '완료',
            style: AppTypography.button2.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _completeAddress() async {
    try {
      final uuid = context.read<UserSession>().uuid;
      if (uuid == null) return;

      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://54.180.152.8/graphql/',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      // 1) uuid -> user id
      final qUser = {
        'query': r'query($uuid: String!) { user_by_uuid(uuid: $uuid) { id } }',
        'variables': {'uuid': uuid},
      };
      final resUser = await dio.post('', data: jsonEncode(qUser));
      final Map<String, dynamic> dataUser = resUser.data is String
          ? json.decode(resUser.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(resUser.data as Map);
      final dynamic idRaw = dataUser['data']?['user_by_uuid']?['id'];
      int? userId;
      if (idRaw is int)
        userId = idRaw;
      else if (idRaw is String)
        userId = int.tryParse(idRaw);
      if (userId == null) return;

      // 2) 새 배송지 서버에 저장
      final addrPayload = {
        'query':
            r'query($user_id: Int!, $name: String!, $address: String!, $address_detail: String!, $postal_code: String!) { create_user_address(user_id: $user_id, name: $name, address: $address, address_detail: $address_detail, postal_code: $postal_code) { id } }',
        'variables': {
          'user_id': userId,
          'name': _recipientController.text,
          'address': _addressController.text,
          'address_detail': _detailAddressController.text,
          'postal_code': _postalCodeController.text,
        },
      };
      final resAddr = await dio.post('', data: jsonEncode(addrPayload));
      final Map<String, dynamic> dataAddr = resAddr.data is String
          ? json.decode(resAddr.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(resAddr.data as Map);
      final dynamic addrIdRaw = dataAddr['data']?['create_user_address']?['id'];
      int? addressId;
      if (addrIdRaw is int)
        addressId = addrIdRaw;
      else if (addrIdRaw is String)
        addressId = int.tryParse(addrIdRaw);
      if (addressId == null) return;

      // 3) 새 배송지를 로컬 리스트에 추가
      final newAddress = {
        'id': addressId.toString(),
        'name': _recipientController.text,
        'isDefault': 'false',
        'address': _addressController.text,
        'detailAddress': _detailAddressController.text,
        'phone': _phoneController.text,
      };

      if (!mounted) return;
      setState(() {
        _deliveryAddresses.add(newAddress);
        _selectedDeliveryAddress = newAddress['name'];
        _currentStep = 5;
      });

      // 4) 입력 필드 초기화
      _recipientController.clear();
      _postalCodeController.clear();
      _addressController.clear();
      _detailAddressController.clear();
      _phoneController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('배송지 저장에 실패했어요: $e')));
    }
  }

  // 배송지 카드 위젯
  Widget _buildDeliveryAddressCard(Map<String, String> address) {
    final isSelected = _selectedDeliveryAddress == address['name'];
    final isDefault = address['isDefault'] == 'true';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryAddress = address['name'];
        });
      },
      child: Container(
        width: 362,
        height: 175,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.baseLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 이름과 기본 배송지 태그
            Row(
              children: [
                Text(
                  address['name']!,
                  style: AppTypography.title4.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 84,
                    height: 24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '기본 배송지',
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // 주소
            Text(
              address['address']!,
              style: AppTypography.caption1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 4),

            // 상세 주소
            Text(
              address['detailAddress']!,
              style: AppTypography.caption1.copyWith(color: AppColors.textDark),
            ),
            const SizedBox(height: 4),

            // 전화번호
            Text(
              address['phone']!,
              style: AppTypography.caption1.copyWith(color: AppColors.textDark),
            ),

            const SizedBox(height: 8),

            // 하단: 수정, 삭제 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 32,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.baseLightest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.textLightest, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '수정',
                      style: AppTypography.button4.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 60,
                  height: 32,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.baseLightest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.textLightest, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '삭제',
                      style: AppTypography.button4.copyWith(
                        color: AppColors.textDark,
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

  Widget _buildBottomSection() {
    // step 6 (새 배송지 추가)에서는 하단 버튼을 표시하지 않음
    if (_currentStep == 6) {
      return const SizedBox.shrink();
    }

    return Container(
      color: _currentStep == 7 ? AppColors.primaryLightest : Colors.white,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: _currentStep == 7 ? 0 : 20,
          bottom: 10,
        ),
        child: Column(
          children: [
            // 버튼 (360x60 크기)
            SizedBox(
              width: 360,
              height: 60,
              child: ElevatedButton(
                onPressed: _isStepValid()
                    ? () {
                        debugPrint(
                          'Bottom primary button tapped at step=' +
                              _currentStep.toString(),
                        );
                        // 편집 모드 우선 처리: 어떤 스텝이든 편집 완료 시 7로 복귀
                        if (_isEditing) {
                          setState(() {
                            _currentStep = 7;
                            _isEditing = false;
                            debugPrint('Editing mode: return to step 7');
                          });
                          return;
                        }
                        if (_currentStep == 0) {
                          // 첫 번째 step 완료 시 두 번째 step으로
                          setState(() {
                            _currentStep = 1;
                            _isEditing = false;
                            debugPrint('Move to step 1');
                          });
                        } else if (_currentStep == 1) {
                          // 두 번째 step 완료 시 세 번째 step으로
                          setState(() {
                            _currentStep = 2;
                            _isEditing = false;
                            debugPrint('Move to step 2');
                          });
                        } else if (_currentStep == 2) {
                          // 세 번째 step 완료 시 네 번째 step으로
                          setState(() {
                            _currentStep = 3;
                            _isEditing = false;
                            debugPrint('Move to step 3');
                          });
                        } else if (_currentStep == 3) {
                          // 네 번째 step 완료 시 다섯 번째 step으로
                          setState(() {
                            _currentStep = 4;
                            _isEditing = false;
                            debugPrint('Move to step 4');
                          });
                        } else if (_currentStep == 4) {
                          // 다섯 번째 step 완료 시 여섯 번째 step으로
                          setState(() {
                            _currentStep = 5;
                            _isEditing = false;
                            debugPrint('Move to step 5');
                          });
                        } else if (_currentStep == 5) {
                          // 이전 사용 주소지 선택 완료 시 리뷰 화면으로 이동
                          setState(() {
                            _currentStep = 7;
                            _isEditing = false;
                            debugPrint('Move to step 7 (existing address)');
                          });
                        } else if (_currentStep == 6) {
                          // 새 배송지 추가 step 완료 시 리뷰 화면으로
                          setState(() {
                            _currentStep = 7;
                            _isEditing = false;
                            debugPrint('Move to step 7');
                          });
                        } else if (_currentStep == 7) {
                          // 최종 확정: 서버 저장 시도 후 완료 화면 이동
                          _submitFunding();
                        } else {
                          // 새 배송지 추가 step 완료 시 다음 화면으로
                          // TODO: 다음 화면 구현
                          debugPrint('Step 6 completed, go next screen (TODO)');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isStepValid()
                      ? const Color(0xFFFF6622)
                      : const Color(0xFFE4E4E4),
                  foregroundColor: _isStepValid()
                      ? Colors.white
                      : const Color(0xFF242221),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _getButtonText(),
                  style: AppTypography.button2.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 단계별 유효성 검사
  bool _isStepValid() {
    switch (_currentStep) {
      case 0:
        return _selectedGiftType != null;
      case 1:
        return _linkController.text.isNotEmpty &&
            (_isPriceConfirmed ||
                (_isCrawlingFailed && _manualPrice.isNotEmpty));
      case 2:
        return _selectedFundingType != null &&
            (_selectedFundingType == 'free' ||
                (_selectedFundingType == 'n_way' &&
                    _participantCountController.text.isNotEmpty));
      case 3:
        return _fundingNameController.text.isNotEmpty;
      case 4:
        return _startDate != null && _endDate != null;
      case 5:
        return _selectedDeliveryAddress != null;
      case 6:
        return _recipientController.text.isNotEmpty &&
            _postalCodeController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _detailAddressController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty;
      case 7:
        return true; // 리뷰 화면에서는 유효성 검사 필요 없음
      default:
        return false;
    }
  }

  // 버튼 텍스트 반환
  String _getButtonText() {
    if (_isEditing) {
      return '수정 완료';
    }

    switch (_currentStep) {
      case 0:
        return '선택 완료';
      case 1:
        return '다음';
      case 2:
        return '확인했어요';
      case 3:
        return '다 적었어요';
      case 4:
        return '완료';
      case 5:
        return '완료';
      case 6:
        return '완료';
      case 7:
        return '이대로 확정!';
      default:
        return '선택 완료';
    }
  }

  Widget _buildReviewStep() {
    final themeBg = AppColors.primaryLightest;
    final containerWidth = 362.0;
    final containerHeight = 560.0;

    String fundingName = _fundingNameController.text;
    String giftInfo = _linkController.text.isNotEmpty
        ? (_selectedProductName.isNotEmpty ? _selectedProductName : '링크상품')
        : '직접 입력';
    String participants = _participantCountController.text.isNotEmpty
        ? _participantCountController.text
        : '0';
    String perHead = _calculatePerPersonAmount();

    String periodText = '';
    if (_startDate != null && _endDate != null) {
      String f(DateTime d) =>
          '${d.year.toString().padLeft(4, '0')}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
      periodText = '${f(_startDate!)} ~ ${f(_endDate!)}';
    }

    String addressText = _addressController.text.isNotEmpty
        ? '${_addressController.text}\n${_detailAddressController.text}'
        : '';
    if (addressText.isEmpty && _selectedDeliveryAddress != null) {
      final selected = _deliveryAddresses.firstWhere(
        (a) => a['name'] == _selectedDeliveryAddress,
        orElse: () => {},
      );
      if (selected.isNotEmpty) {
        final base = selected['address'] ?? '';
        final detail = selected['detailAddress'] ?? '';
        addressText = '$base\n$detail'.trim();
      }
    }

    return SingleChildScrollView(
      child: Container(
        color: themeBg,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                '거의 다 왔어요',
                style: AppTypography.heading2.copyWith(
                  color: AppColors.textDarkest,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '펀딩 설정을 확인해 주세요',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.primaryBase,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(color: Colors.white),
                child: Stack(
                  children: [
                    // 스캘럽 상단 장식
                    Positioned(
                      top: -10,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: containerWidth,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 4,
                              children: List.generate(15, (index) {
                                return Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLightest,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 내용
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 270,
                            child: Text(
                              fundingName,
                              style: AppTypography.suiteTitle.copyWith(
                                color: AppColors.primaryBase,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              width: 326,
                              height: 0,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.textLightest,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          _reviewRow(
                            label: '선물',
                            value: giftInfo,
                            onTap: () {
                              setState(() {
                                _currentStep = 1;
                                _isEditing = true;
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          _reviewRow(
                            label: '펀딩 방식',
                            value: _selectedFundingType == 'n_way'
                                ? 'N빵 펀딩 · ${participants}명 참여\n인당 ${perHead.isNotEmpty ? perHead : '0'}원 펀딩 예정'
                                : '자유 펀딩',
                            emphasizeFunding: true,
                            participants: participants,
                            perHead: perHead,
                            onTap: () {
                              setState(() {
                                _currentStep = 2;
                                _isEditing = true;
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          _reviewRow(
                            label: '펀딩 기간',
                            value: periodText,
                            onTap: () {
                              setState(() {
                                _currentStep = 4;
                                _isEditing = true;
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                          _reviewRow(
                            label: '배송지',
                            value: addressText,
                            onTap: () {
                              setState(() {
                                _currentStep = 5;
                                _isEditing = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 하단 버튼은 MakeFundingScreen의 공통 하단 버튼을 사용
          ],
        ),
      ),
    );
  }

  Widget _reviewRow({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool emphasizeFunding = false,
    String? participants,
    String? perHead,
  }) {
    return SizedBox(
      width: 318,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.suiteBody1.copyWith(
                    color: AppColors.primaryBase,
                  ),
                ),
                const SizedBox(height: 6),
                if (emphasizeFunding && _selectedFundingType == 'n_way') ...[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'N빵 펀딩',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.primaryBase,
                          ),
                        ),
                        TextSpan(
                          text: ' · ',
                          style: AppTypography.caption1.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '${participants}명 ',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.primaryBase,
                          ),
                        ),
                        TextSpan(
                          text: '참여',
                          style: AppTypography.caption1.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '인당 ${perHead?.isNotEmpty == true ? perHead : '0'}원 ',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.primaryBase,
                          ),
                        ),
                        TextSpan(
                          text: '펀딩 예정',
                          style: AppTypography.caption1.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    value,
                    style: AppTypography.caption1.copyWith(color: Colors.black),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.primaryBase,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    final linkText = 'https://Happy_Day.com/funding/1292';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/confetti.gif'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '펀딩 세팅이 끝났어요!',
                        style: AppTypography.suiteHeading1.copyWith(
                          color: AppColors.primaryBase,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '친구들이 참여하면 선물이 완성돼요',
                        style: AppTypography.body3.copyWith(
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _selectedImage != null
                              ? Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/icons/cha.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '소중한 사람들이 함께할 수 있도록\n링크를 공유해 보세요',
                        style: AppTypography.title4.copyWith(
                          color: AppColors.textDarker,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 362,
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.baseLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          linkText,
                          style: AppTypography.title5.copyWith(
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _pillActionButton(
                            icon: Icons.copy,
                            label: '링크 복사하기',
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _pillActionButton(
                            icon: Icons.share,
                            label: '공유하기',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pillActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryLightest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBase),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.button4.copyWith(
                color: AppColors.primaryBase,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 배송지 데이터 초기화
  Future<void> _initializeDeliveryAddresses() async {
    try {
      final uuid = context.read<UserSession>().uuid;
      if (uuid == null) return;

      final dio = Dio(
        BaseOptions(
          baseUrl: _graphqlEndpoint,
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      // 1) uuid -> user id
      final qUser = {
        'query': r'query($uuid: String!) { user_by_uuid(uuid: $uuid) { id } }',
        'variables': {'uuid': uuid},
      };
      final resUser = await dio.post('', data: jsonEncode(qUser));
      final Map<String, dynamic> dataUser = resUser.data is String
          ? json.decode(resUser.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(resUser.data as Map);
      final dynamic idRaw = dataUser['data']?['user_by_uuid']?['id'];
      int? userId;
      if (idRaw is int)
        userId = idRaw;
      else if (idRaw is String)
        userId = int.tryParse(idRaw);
      if (userId == null) return;

      // 2) 기존 배송지가 있는지 확인
      final qAddresses = {
        'query':
            r'query($user_id: Int!) { user_addresses(user_id: $user_id) { id name address address_detail postal_code } }',
        'variables': {'user_id': userId},
      };
      final resAddresses = await dio.post('', data: jsonEncode(qAddresses));
      final Map<String, dynamic> dataAddresses = resAddresses.data is String
          ? json.decode(resAddresses.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(resAddresses.data as Map);

      final List<dynamic>? existingAddresses =
          dataAddresses['data']?['user_addresses'];

      if (existingAddresses != null && existingAddresses.isNotEmpty) {
        // 기존 배송지가 있으면 사용
        final List<Map<String, String>> addresses = existingAddresses
            .map<Map<String, String>>((addr) {
              return {
                'id': addr['id'].toString(),
                'name': addr['name'] ?? '수령인',
                'isDefault': 'false',
                'address': addr['address'] ?? '',
                'detailAddress': addr['address_detail'] ?? '',
                'phone': '010-0000-0000', // 기본값
              };
            })
            .toList();

        if (!mounted) return;
        setState(() {
          _deliveryAddresses.clear();
          _deliveryAddresses.addAll(addresses);
        });
      } else {
        // 기존 배송지가 없으면 임시 데이터 생성
        final tempAddresses = [
          {
            'name': '차은우',
            'address': '서울 성북구 안암로 145 고려대학교안암캠퍼스',
            'address_detail': 'SK 미래관 3001호',
            'postal_code': '02841',
          },
          {
            'name': '김철수',
            'address': '서울 강남구 테헤란로 123',
            'address_detail': 'ABC 빌딩 5층',
            'postal_code': '06123',
          },
        ];

        final List<Map<String, String>> newAddresses = [];

        for (final tempAddr in tempAddresses) {
          // 임시 배송지를 서버에 저장
          final addrPayload = {
            'query':
                r'query($user_id: Int!, $name: String!, $address: String!, $address_detail: String!, $postal_code: String!) { create_user_address(user_id: $user_id, name: $name, address: $address, address_detail: $address_detail, postal_code: $postal_code) { id } }',
            'variables': {
              'user_id': userId,
              'name': tempAddr['name']!,
              'address': tempAddr['address']!,
              'address_detail': tempAddr['address_detail']!,
              'postal_code': tempAddr['postal_code']!,
            },
          };

          final resAddr = await dio.post('', data: jsonEncode(addrPayload));
          final Map<String, dynamic> dataAddr = resAddr.data is String
              ? json.decode(resAddr.data as String) as Map<String, dynamic>
              : Map<String, dynamic>.from(resAddr.data as Map);
          final dynamic addrIdRaw =
              dataAddr['data']?['create_user_address']?['id'];

          if (addrIdRaw != null) {
            final addressId = addrIdRaw is int
                ? addrIdRaw.toString()
                : addrIdRaw.toString();
            newAddresses.add({
              'id': addressId,
              'name': tempAddr['name']!,
              'isDefault': newAddresses.isEmpty
                  ? 'true'
                  : 'false', // 첫 번째를 기본으로 설정
              'address': tempAddr['address']!,
              'detailAddress': tempAddr['address_detail']!,
              'phone': '010-0000-0000',
            });
          }
        }

        if (!mounted) return;
        setState(() {
          _deliveryAddresses.clear();
          _deliveryAddresses.addAll(newAddresses);
          // 첫 번째 배송지를 기본 선택으로 설정
          if (newAddresses.isNotEmpty) {
            _selectedDeliveryAddress = newAddresses.first['name'];
          }
        });
      }
    } catch (e) {
      debugPrint('배송지 초기화 오류: $e');
      // 오류 발생 시 빈 리스트로 시작 (사용자가 직접 추가하도록)
      if (!mounted) return;
      setState(() {
        _deliveryAddresses.clear();
        _selectedDeliveryAddress = null;
      });

      // 사용자에게 오류 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배송지 정보를 불러올 수 없어요. 새로 추가해 주세요.')),
      );
    }
  }
}

// 배송지 추가 화면
class AddDeliveryAddressScreen extends StatefulWidget {
  final Function(Map<String, String>)? onComplete;

  const AddDeliveryAddressScreen({super.key, this.onComplete});

  @override
  State<AddDeliveryAddressScreen> createState() =>
      _AddDeliveryAddressScreenState();
}

class _AddDeliveryAddressScreenState extends State<AddDeliveryAddressScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            _buildHeader(),

            // 입력 폼
            Expanded(child: _buildInputForm()),

            // 하단 완료 버튼
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const Spacer(),

          // 오른쪽 X 버튼
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // 수령인 입력
            _buildInputField(
              controller: _recipientController,
              hintText: '수령인',
              width: 360,
            ),
            const SizedBox(height: 40),

            // 우편번호 입력과 검색 버튼
            Row(
              children: [
                _buildInputField(
                  controller: _postalCodeController,
                  hintText: '우편번호',
                  width: 245,
                ),
                const SizedBox(width: 15),
                _buildPostalCodeSearchButton(),
              ],
            ),
            const SizedBox(height: 40),

            // 주소 입력
            _buildInputField(
              controller: _addressController,
              hintText: '주소',
              width: 360,
            ),
            const SizedBox(height: 40),

            // 상세주소 입력
            _buildInputField(
              controller: _detailAddressController,
              hintText: '상세주소',
              width: 360,
            ),
            const SizedBox(height: 40),

            // 연락처 입력
            _buildInputField(
              controller: _phoneController,
              hintText: '연락처',
              width: 360,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required double width,
  }) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.baseLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.title5.copyWith(color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.subtitle2.copyWith(
                  color: AppColors.gray500,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                setState(() {});
              },
              child: SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.close, color: AppColors.gray500, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostalCodeSearchButton() {
    return GestureDetector(
      onTap: () async {
        try {
          final result = await Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(
              builder: (context) => const KpostalScreenReturn(),
              fullscreenDialog: false, // 일반적인 modal navigation
            ),
          );

          if (result != null &&
              result.runtimeType.toString().contains('Kpostal')) {
            debugPrint('AddDeliveryAddressScreen: Kpostal 객체 받음 - $result');
            debugPrint('AddDeliveryAddressScreen: setState() 호출 전');
            setState(() {
              _postalCodeController.text = result.postCode ?? '';
              _addressController.text = result.address ?? '';
              debugPrint(
                'AddDeliveryAddressScreen: 우편번호 설정 - ${_postalCodeController.text}',
              );
              debugPrint(
                'AddDeliveryAddressScreen: 주소 설정 - ${_addressController.text}',
              );
            });
            debugPrint('AddDeliveryAddressScreen: setState() 완료');
            debugPrint(
              'AddDeliveryAddressScreen: AddDeliveryAddressScreen에 머무름 - 나머지 정보 입력 대기',
            );
          } else if (result != null && result is Map<String, dynamic>) {
            debugPrint('AddDeliveryAddressScreen: Map 결과 받음 - $result');
            debugPrint('AddDeliveryAddressScreen: setState() 호출 전');
            setState(() {
              _postalCodeController.text = result['postalCode'] ?? '';
              _addressController.text = result['address'] ?? '';
              debugPrint(
                'AddDeliveryAddressScreen: 우편번호 설정 - ${_postalCodeController.text}',
              );
              debugPrint(
                'AddDeliveryAddressScreen: 주소 설정 - ${_addressController.text}',
              );
            });
            debugPrint('AddDeliveryAddressScreen: setState() 완료');
            debugPrint(
              'AddDeliveryAddressScreen: AddDeliveryAddressScreen에 머무름 - 나머지 정보 입력 대기',
            );
          } else {
            debugPrint('AddDeliveryAddressScreen: 결과가 null이거나 잘못된 형식');
          }
        } catch (e) {
          debugPrint('AddDeliveryAddressScreen: navigation error - $e');
        }
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.baseLightest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.baseBase, width: 2),
        ),
        child: Center(
          child: Text(
            '우편번호 검색',
            style: AppTypography.button4.copyWith(color: AppColors.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    final isFormValid =
        _recipientController.text.isNotEmpty &&
        _postalCodeController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _detailAddressController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
      child: SizedBox(
        width: 360,
        height: 60,
        child: ElevatedButton(
          onPressed: isFormValid ? _completeAddress : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid
                ? const Color(0xFFFF6622)
                : const Color(0xFFE4E4E4),
            foregroundColor: isFormValid
                ? Colors.white
                : const Color(0xFF242221),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            '완료',
            style: AppTypography.button2.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _completeAddress() {
    // 새 배송지 데이터 생성
    final newAddress = {
      'name': _recipientController.text,
      'isDefault': 'false',
      'address': _addressController.text,
      'detailAddress': _detailAddressController.text,
      'phone': _phoneController.text,
    };

    debugPrint('AddDeliveryAddressScreen: 완성된 배송지 데이터 생성 - $newAddress');

    // onComplete 콜백이 있으면 호출
    if (widget.onComplete != null) {
      widget.onComplete!(newAddress);
    } else {
      // 기본 동작: 이전 화면으로 돌아감
      Navigator.of(context).pop(newAddress);
    }
  }
}
