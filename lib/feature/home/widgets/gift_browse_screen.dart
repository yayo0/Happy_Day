import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class GiftBrowseScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onShowToast;
  
  const GiftBrowseScreen({
    super.key,
    required this.onBack,
    this.onShowToast,
  });

  @override
  State<GiftBrowseScreen> createState() => _GiftBrowseScreenState();
}

class _GiftBrowseScreenState extends State<GiftBrowseScreen> with TickerProviderStateMixin {
  String _selectedCategory = '집들이';
  String? _activeFilter;
  String _selectedGenderFilter = '남녀 모두';
  String _selectedPriceFilter = '가격';
  String _selectedPopularityFilter = '연령';
  String _selectedOccasionFilter = '대상';
  
  // 드롭다운 위치 계산을 위한 변수
  double _dropdownLeft = 20;
  


  // 필터가 기본값인지 확인하는 헬퍼 함수들
  bool _isFilterDefault(String label, String currentValue) {
    switch (label) {
      case '남녀 모두':
        return currentValue == '남녀 모두';
      case '가격':
        return currentValue == '가격';
      case '연령':
        return currentValue == '연령';
      case '대상':
        return currentValue == '대상';
      default:
        return true;
    }
  }

  void _resetFilter(String label) {
    setState(() {
      switch (label) {
        case '남녀 모두':
          _selectedGenderFilter = '남녀 모두';
          break;
        case '가격':
          _selectedPriceFilter = '가격';
          break;
        case '연령':
          _selectedPopularityFilter = '연령';
          break;
        case '대상':
          _selectedOccasionFilter = '대상';
          break;
      }
      _activeFilter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 시즌 배너
            _buildSeasonBanner(),
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 탭
                  _buildCategoryTabs(),
                  const SizedBox(height: 20),
                  
                  // 필터 섹션
                  _buildFilters(),
                  const SizedBox(height: 24),
                  
                  // 선물 아이템들
                  _buildGiftItems(),
                ],
              ),
            ),
          ],
        ),
        // 드롭다운이 활성화되었을 때 뒤의 터치를 막는 오버레이
        if (_activeFilter != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeFilter = null;
                });
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        // 전역 드롭다운 오버레이
        if (_activeFilter != null)
          _buildGlobalDropdown(),
      ],
    );
  }

  Widget _buildSeasonBanner() {
    final bannerData = {
      'backgroundImage': 'https://picsum.photos/800/300?random=1',
      'title': '다가오는 졸업 시즌',
      'subtitle': '센스 있는 선물 미리 준비하세요'
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(bannerData['backgroundImage']!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // 좌하단 - 제목과 부제목
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bannerData['title']!,
                    style: AppTypography.title3.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bannerData['subtitle']!,
                    style: AppTypography.caption2.copyWith(
                      color: AppColors.textLightest,
                    ),
                  ),
                ],
              ),
            ),
            // 우하단 - Top 10 상품 보러가기
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: () {
                  // TODO: Top 10 상품 페이지로 이동
                },
                child: Text(
                  'Top 10 상품 보러가기 >',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
             margin: const EdgeInsets.symmetric(horizontal: 8),
             width: 80, // 60에서 80으로 증가
             child: GestureDetector(
               onTap: () {
                 setState(() {
                   _selectedCategory = category;
                 });
               },
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(
                     category,
                     style: AppTypography.title4.copyWith(
                       color: isSelected ? AppColors.textDarker : AppColors.textLight,
                     ),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     textAlign: TextAlign.center,
                   ),
                   if (isSelected)
                     Container(
                       margin: const EdgeInsets.only(top: 4),
                       width: 80, // 60에서 80으로 증가
                       height: 2,
                       decoration: BoxDecoration(
                         color: AppColors.textDarker,
                         borderRadius: BorderRadius.circular(1),
                       ),
                     ),
                 ],
               ),
             ),
           );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 40,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // 필터 아이콘 버튼
                _buildFilterIconButton(),
                const SizedBox(width: 8),
                _buildFilterButton('남녀 모두', _selectedGenderFilter, _genderOptions, 44, (value) {
                  setState(() {
                    _selectedGenderFilter = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterButton('가격', _selectedPriceFilter, _priceOptions, 134, (value) {
                  setState(() {
                    _selectedPriceFilter = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterButton('연령', _selectedPopularityFilter, _popularityOptions, 224, (value) {
                  setState(() {
                    _selectedPopularityFilter = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterButton('대상', _selectedOccasionFilter, _occasionOptions, 314, (value) {
                  setState(() {
                    _selectedOccasionFilter = value;
                  });
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterIconButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.baseWhite,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.baseBase),
      ),
      child: Icon(
        Icons.tune,
        size: 16,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildFilterButton(String label, String currentValue, List<String> options, double leftPosition, ValueChanged<String> onChanged) {
    final isActive = _activeFilter == label;
    final isDefault = _isFilterDefault(label, currentValue);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (!isDefault && !isActive) {
                  // X 아이콘이 표시되고 드롭다운이 열려있지 않을 때는 리셋
                  _resetFilter(label);
                } else {
                  // 아니면 드롭다운 토글
                  setState(() {
                    _activeFilter = isActive ? null : label;
                    if (_activeFilter != null) {
                      _dropdownLeft = leftPosition;
                    }
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.textDarkest : AppColors.baseWhite,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.baseBase),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentValue,
                      style: AppTypography.button4.copyWith(
                        color: isActive ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isDefault ? Icons.keyboard_arrow_down : Icons.close,
                      size: 16,
                      color: isActive ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ],
                ),
              ),
            ),
            // X 아이콘이 표시될 때 별도의 터치 영역 (X 아이콘은 이미 버튼 안에 있으므로 제거)
          ],
        ),

      ],
    );
  }

  Widget _buildGlobalDropdown() {
    if (_activeFilter == null) return const SizedBox.shrink();
    
    String currentValue = '';
    List<String> options = [];
    ValueChanged<String>? onChanged;
    
    switch (_activeFilter) {
      case '남녀 모두':
        currentValue = _selectedGenderFilter;
        options = _genderOptions;
        onChanged = (value) => setState(() => _selectedGenderFilter = value);
        break;
      case '가격':
        currentValue = _selectedPriceFilter;
        options = _priceOptions;
        onChanged = (value) => setState(() => _selectedPriceFilter = value);
        break;
      case '연령':
        currentValue = _selectedPopularityFilter;
        options = _popularityOptions;
        onChanged = (value) => setState(() => _selectedPopularityFilter = value);
        break;
      case '대상':
        currentValue = _selectedOccasionFilter;
        options = _occasionOptions;
        onChanged = (value) => setState(() => _selectedOccasionFilter = value);
        break;
    }
    
    // 화면 경계 체크
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dropdownWidth = 120.0;
    final estimatedDropdownHeight = options.length * 48.0 + 32; // 대략적인 드롭다운 높이
    double adjustedLeft = _dropdownLeft;
    double adjustedTop = 290.0;
    
    // 오른쪽 경계 체크
    if (_dropdownLeft + dropdownWidth > screenWidth - 20) {
      adjustedLeft = screenWidth - dropdownWidth - 20;
    }
    
    // 왼쪽 경계 체크
    if (adjustedLeft < 20) {
      adjustedLeft = 20;
    }
    
    // 아래쪽 경계 체크 - 드롭다운이 화면 밖으로 나가면 위로 올림
    if (adjustedTop + estimatedDropdownHeight > screenHeight - 100) {
      adjustedTop = 200.0; // 필터 위로 표시
    }
    
    return Positioned(
      top: adjustedTop,
      left: adjustedLeft,
      child: Material(
        elevation: 20,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          width: dropdownWidth,
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.4, // 화면 높이의 40%로 제한
          ),
          decoration: BoxDecoration(
            color: AppColors.baseWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
              final isSelected = option == currentValue;
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (onChanged != null) {
                        onChanged(option);
                      }
                      setState(() {
                        _activeFilter = null;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        option,
                        style: isSelected 
                            ? AppTypography.subtitle1.copyWith(color: AppColors.textDarker)
                            : AppTypography.subtitle2.copyWith(color: AppColors.textLighter),
                      ),
                    ),
                  ),
                  if (option != options.last)
                    Container(
                      height: 0.5,
                      color: AppColors.baseLight,
                    ),
                ],
              );
            }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGiftItems() {
    return Column(
      children: _dummyGiftItems.map((item) => _buildGiftItem(item)).toList(),
    );
  }

  Widget _buildGiftItem(Map<String, dynamic> item) {
    return Container(
      height: 96,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item['image'] != null
                ? Image.network(
                    item['image'],
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 96,
                        height: 96,
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
                        width: 96,
                        height: 96,
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
                    width: 96,
                    height: 96,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                // 하단 아이콘들
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'lib/feature/home/asset/give.png',
                      width: 16,
                      height: 16,
                      color: AppColors.textLighter,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.card_giftcard,
                          color: AppColors.textLighter,
                          size: 16,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onShowToast,
                      child: Icon(
                        Icons.favorite_border,
                        color: AppColors.textLighter,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['likes'] ?? 166}',
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.textLighter,
                      ),
                    ),
                  ],
                ),
              ],
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

  // 카테고리 목록
  final List<String> _categories = [
    '집들이',
    '생일',
    '졸업',
    '신혼/결혼',
    '스승의날',
  ];

  // 필터 옵션들
  final List<String> _genderOptions = ['남녀 모두', '남성', '여성'];
  final List<String> _priceOptions = ['가격', '1만원 이하', '1-3만원', '3-5만원', '5-10만원', '10만원 이상'];
  final List<String> _popularityOptions = ['연령', '10대', '20대', '30대', '40대', '50대 이상'];
  final List<String> _occasionOptions = ['대상', '친구', '가족', '연인', '동료', '기타'];

  // 더미 선물 데이터
  final List<Map<String, dynamic>> _dummyGiftItems = [
    {
      'brand': 'Stussy',
      'name': 'Nike x Stussy T-shirts white',
      'price': 85000,
      'likes': 166,
      'image': 'https://picsum.photos/200/200?random=2',
    },
    {
      'brand': 'Stussy',
      'name': 'Nike x Stussy T-shirts white',
      'price': 85000,
      'likes': 166,
      'image': 'https://picsum.photos/200/200?random=3',
    },
    {
      'brand': 'Stussy',
      'name': 'Nike x Stussy T-shirts white',
      'price': 85000,
      'likes': 166,
      'image': 'https://picsum.photos/200/200?random=4',
    },
    {
      'brand': 'Stussy',
      'name': 'Nike x Stussy T-shirts white',
      'price': 85000,
      'likes': 166,
      'image': 'https://picsum.photos/200/200?random=5',
    },
    {
      'brand': 'Stussy',
      'name': 'Nike x Stussy T-shirts white',
      'price': 85000,
      'likes': 166,
      'image': 'https://picsum.photos/200/200?random=6',
    },
  ];
}
