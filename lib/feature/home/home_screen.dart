import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';
import '../../data/dummy_data.dart';
import '../../models/event.dart';
import '../../models/product.dart';
import '../../models/event.dart' as event_models;
import '../on_boarding/on_boarding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          '해피 데이(로고)',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.gray100,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 특별한 날, 잊지 마세요! 섹션
            _buildSpecialDaysSection(),
            const SizedBox(height: 32),

            // OO님의 취향에 맞는 선물 섹션
            _buildGiftRecommendationSection(),
            const SizedBox(height: 100), // 하단 네비게이션 바 공간
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSpecialDaysSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '특별한 날, 잊지 마세요!',
            style: AppTypography.title1.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 기념일 등록 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('🐕', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '된 기념일',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 기념일 등록 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.notice,
                      foregroundColor: AppColors.gray00,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '선물을 까먹지 않도록 등록하세요!',
                      style: AppTypography.button2.copyWith(
                        color: AppColors.gray00,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 기념일 목록
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // 기념일 등록 카드
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.gray200,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  '📅',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '기념일 등록',
                              style: AppTypography.caption1.copyWith(
                                color: AppColors.textLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // 등록된 기념일들
                      ...DummyData.events.map(
                        (event) => _buildEventCard(event),
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

  Widget _buildEventCard(Event event) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                event.profileImage,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: AppTypography.caption1.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            event.date,
            style: AppTypography.caption2.copyWith(
              color: AppColors.textLighter,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '선물하기',
              style: AppTypography.caption2.copyWith(
                color: AppColors.gray00,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftRecommendationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OO님의 취향에 맞는 선물',
                style: AppTypography.title1.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
                child: Text(
                  '더보기 >',
                  style: AppTypography.body3.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 가격대 필터
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: DummyData.priceRanges.length,
              itemBuilder: (context, index) {
                final priceRange = DummyData.priceRanges[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(priceRange.label),
                    selected: priceRange.isSelected,
                    onSelected: (selected) {
                      setState(() {
                        for (var range in DummyData.priceRanges) {
                          range.isSelected = range.id == priceRange.id;
                        }
                      });
                    },
                    backgroundColor: AppColors.gray100,
                    selectedColor: AppColors.gray600,
                    labelStyle: TextStyle(
                      color: priceRange.isSelected
                          ? AppColors.gray00
                          : AppColors.textDark,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 상품 목록
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: DummyData.products.length,
              itemBuilder: (context, index) {
                final product = DummyData.products[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(product.image, style: const TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 8),

          // 브랜드명
          Text(
            product.brand,
            style: AppTypography.caption1.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // 상품 설명
          Text(
            product.description,
            style: AppTypography.body3.copyWith(color: AppColors.textDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // 가격 또는 펀딩 버튼
          if (product.hasFunding)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '펀딩 만들기',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.gray00,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              '${_formatPrice(product.price)}원',
              style: AppTypography.body2.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border(top: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.gray100,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.textLighter,
        selectedLabelStyle: AppTypography.caption1.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTypography.caption1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '선물 고르기',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '위시리스트'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '더보기'),
        ],
      ),
    );
  }

  // 가격 포맷팅 함수
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
