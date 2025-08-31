import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';

class GiftSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> recipientInfo;
  final VoidCallback onBack;
  
  const GiftSelectionScreen({
    super.key,
    required this.recipientInfo,
    required this.onBack,
  });

  @override
  State<GiftSelectionScreen> createState() => _GiftSelectionScreenState();
}

class _GiftSelectionScreenState extends State<GiftSelectionScreen> {
  String _selectedPriceRange = '전체';
  
  // 가격대 필터링 관련 상태
  RangeValues _priceRange = const RangeValues(80000, 120000);
  final double _minPrice = 0;
  final double _maxPrice = 350000;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 뒤로가기 버튼과 제목
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textDarkest,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${widget.recipientInfo['name']}님에게 선물하기',
                  style: AppTypography.title5.copyWith(
                    color: AppColors.textDarkest,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // 수령인 정보 섹션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // 캐릭터 아바타
              CharacterAvatar(
                characterType: (widget.recipientInfo['characterType'] ?? 1) as int,
                size: 48,
              ),
              const SizedBox(width: 16),
              // 수령인 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.recipientInfo['name'] as String,
                          style: AppTypography.title4.copyWith(
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.recipientInfo['eventType'] as String,
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.recipientInfo['date'] as String,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 구분선
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          height: 8,
          color: AppColors.baseLighter,
        ),
        
        // 지석님의 취향 섹션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.recipientInfo['name']}님의 취향',
                style: AppTypography.title2.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '위시리스트',
                style: AppTypography.title4.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              const SizedBox(height: 20),
              
              // 위시리스트 아이템들
              _buildWishlistItems(),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 지석님의 취향 기반 추천 선물 섹션
        if (_dummyWishlistItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.recipientInfo['name']}님의 취향 기반 추천 선물',
                      style: AppTypography.title4.copyWith(
                        color: AppColors.primaryBase,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                                 GestureDetector(
                   onTap: () {
                     _showPriceFilterBottomSheet(context);
                   },
                   child: Container(
                     alignment: Alignment.centerRight,
                     width: 110,
                     padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                     decoration: BoxDecoration(
                       color: AppColors.baseLightest,
                       border: Border.all(
                         color: AppColors.textLightest,
                         width: 1,
                       ),
                       borderRadius: BorderRadius.circular(100),
                     ),
                     child: Center(
                       child: Text(
                         '가격대 필터링',
                         textAlign: TextAlign.center,
                         style: AppTypography.button4.copyWith(
                             color: AppColors.textDark,
                           ),
                         ),
                       ),
                     ),
                   ),
                const SizedBox(height: 20),
                
                // 추천 선물 아이템들
              _buildRecommendedItems(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWishlistItems() {
    // 위시리스트가 없을 경우 빈 상태 UI 표시
    if (_dummyWishlistItems.isEmpty) {
      return Column(
        children: [
          Center(
            child: Text(
              '위시리스트가 없어요',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 200,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLightest,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '갖고 싶은 선물 물어보기',
                    style: AppTypography.button3.copyWith(
                      color: AppColors.primaryBase,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primaryBase,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
    // 위시리스트가 있을 경우 기존 아이템들 표시
    return Column(
      children: _dummyWishlistItems.map((item) => _buildGiftItem(
        item,
        isWishlist: true,
      )).toList(),
    );
  }

  Widget _buildRecommendedItems() {
    return Column(
      children: _dummyRecommendedItems.map((item) => _buildGiftItem(
        item,
        isWishlist: false,
      )).toList(),
    );
  }

  Widget _buildGiftItem(Map<String, dynamic> item, {required bool isWishlist}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item['image'] != null
                ? Image.network(
                    item['image'],
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 72,
                        height: 72,
                        color: AppColors.gray200,
                        child: Center(
                          child: Text(
                            '🖼️',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 72,
                        height: 72,
                        color: AppColors.gray200,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBase,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: 72,
                    height: 72,
                    color: AppColors.gray200,
                    child: Center(
                      child: Text(
                        '🖼️',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          
          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['brand'],
                  style: AppTypography.title5.copyWith(
                    color: AppColors.textDarkest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['name'],
                  style: AppTypography.body3.copyWith(
                    color: AppColors.textLighter,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatPrice(item['price'])}원',
                  style: AppTypography.title5.copyWith(
                    color: AppColors.textDarkest,
                  ),
                ),
              ],
            ),
          ),
          
          // 선물하기 버튼
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showPriceFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, modalSetState) => _buildPriceFilterBottomSheet(modalSetState),
      ),
    );
  }

  Widget _buildPriceFilterBottomSheet(StateSetter modalSetState) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목과 선택된 가격대
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '가격대',
                  style: AppTypography.title1.copyWith(
                    color: AppColors.textDarkest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _priceRange.end.round() >= _maxPrice
                    ? '${_formatPrice(_priceRange.start.round())}원 이상'
                    : '${_formatPrice(_priceRange.start.round())}원 ~ ${_formatPrice(_priceRange.end.round())}원',
                style: AppTypography.title4.copyWith(
                  color: AppColors.textDarker,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // 가격대 슬라이더
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbColor: AppColors.primaryBase,
                activeTrackColor: AppColors.primaryLight,
                inactiveTrackColor: AppColors.baseBase,
              ),
              child: RangeSlider(
                values: _priceRange,
                min: _minPrice,
                max: _maxPrice,
                divisions: ((_maxPrice - _minPrice) / 1000).round(),
                onChanged: (RangeValues values) {
                  modalSetState(() {
                    _priceRange = values;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // 첫 번째 줄 버튼들 (한 줄 3개, 텍스트 폭에 맞춤)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  _buildPriceButton('3만원 이하', 0, 30000, modalSetState),
                  const SizedBox(width: 8),
                  _buildPriceButton('3~5만원', 30000, 50000, modalSetState),
                  const SizedBox(width: 8),
                  _buildPriceButton('5~10만원', 50000, 100000, modalSetState),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // 두 번째 줄 버튼들 (한 줄 3개, 텍스트 폭에 맞춤)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceButton('10~20만원', 100000, 200000, modalSetState),
                  const SizedBox(width: 8),
                  _buildPriceButton('20~30만원', 200000, 300000, modalSetState),
                  const SizedBox(width: 8), 
                  _buildPriceButton('30만원 이상', 300000, _maxPrice, modalSetState),
                ],
              ),
            ),
            const Spacer(),
            
            // 하단 버튼들
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      modalSetState(() {
                        _priceRange = const RangeValues(80000, 120000);
                      });
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '초기화',
                          style: AppTypography.button2.copyWith(
                            color: AppColors.primaryBase,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBase,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '설정',
                          style: AppTypography.button2.copyWith(
                            color: AppColors.textWhite,
                          ),
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

  Widget _buildPriceButton(String text, double? minPrice, double? maxPrice, StateSetter modalSetState) {
    bool isSelected = false;
    
    if (minPrice != null && maxPrice != null) {
      isSelected = _priceRange.start == minPrice && _priceRange.end == maxPrice;
    }
    
    return GestureDetector(
      onTap: () {
        modalSetState(() {
          _priceRange = RangeValues(minPrice ?? _minPrice, maxPrice ?? _maxPrice);
        });
      },
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLightest : AppColors.baseLightest,
          border: Border.all(
            color: AppColors.textLightest,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTypography.button4.copyWith(
            color: isSelected ? AppColors.primaryBase : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  String _formatToMan(int price) {
    final man = (price / 10000).round();
    return '${man}만원';
  }

  // 더미 위시리스트 데이터
  final List<Map<String, dynamic>> _dummyWishlistItems = [
    {
      'brand': 'Stussy',
      'name': 'Nike x Stussy T-shirts',
      'price': 85000,
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200&h=200&fit=crop',
    },
    {
      'brand': 'Nike',
      'name': 'Air Jordan 1 Retro High',
      'price': 180000,
      'image': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=200&h=200&fit=crop',
    },
    {
      'brand': 'Apple',
      'name': 'AirPods Pro 2nd Generation',
      'price': 320000,
      'image': 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=200&h=200&fit=crop',
    },
  ];

  // 더미 추천 선물 데이터
  final List<Map<String, dynamic>> _dummyRecommendedItems = [
    {
      'brand': 'Adidas',
      'name': 'Ultraboost 22 Running Shoes',
      'price': 220000,
      'image': 'https://images.unsplash.com/photo-1543508282-6319a3e2621f?w=200&h=200&fit=crop',
    },
    {
      'brand': 'Samsung',
      'name': 'Galaxy Watch 6 Classic',
      'price': 450000,
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop',
    },
    {
      'brand': 'Levi\'s',
      'name': '501 Original Jeans',
      'price': 120000,
      'image': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop',
    },
  ];
}
