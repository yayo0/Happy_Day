import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class GiftRecommendationSection extends StatefulWidget {
  const GiftRecommendationSection({super.key});

  @override
  State<GiftRecommendationSection> createState() => _GiftRecommendationSectionState();
}

class _GiftRecommendationSectionState extends State<GiftRecommendationSection> {
  String _selectedPriceRange = '5-8만원대';

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.title2.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: 더보기 기능 구현
                },
                child: Text(
                  '더보기 >',
                  style: AppTypography.caption1.copyWith(
                    color: AppColors.textLighter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 가격대 필터
          SizedBox(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _priceRanges.length,
              itemBuilder: (context, index) {
                final priceRange = _priceRanges[index];
                final isSelected = _selectedPriceRange == priceRange;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPriceRange = priceRange;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.textDarker : AppColors.gray100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        priceRange,
                        style: AppTypography.button4.copyWith(
                          color: isSelected ? AppColors.gray00 : AppColors.textDark,
                        ),
                      ),
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
              padding: EdgeInsets.zero,
              itemCount: _getFilteredProducts().length,
              itemBuilder: (context, index) {
                final product = _getFilteredProducts()[index];
                return _buildProductCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      width: 165,
      height: 230,
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.baseLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['image']!,
              width: 145,
              height: 105,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 145,
                  height: 105,
                  color: AppColors.baseWhite,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
           // 상품명
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              product['name'],
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textDarkest,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          
          // 브랜드명
          Text(
            product['brand'],
            style: AppTypography.caption2.copyWith(
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // 가격
          Text(
            '${_formatPrice(product['price'])}원',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textDarkest,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 가격대별 필터링된 상품 반환
  List<Map<String, dynamic>> _getFilteredProducts() {
    return _dummyProducts.where((product) {
      return product['priceRange'] == _selectedPriceRange;
    }).toList();
  }

  // 가격 포맷팅 함수
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // 가격대 목록
  final List<String> _priceRanges = [
    '5-8만원대',
    '4-5만원대',
    '8-10만원대',
    '10만원 이상',
  ];

  // 더미 상품 데이터
  final List<Map<String, dynamic>> _dummyProducts = [
    {
      'name': 'Nike x Stussy T-shirts white',
      'brand': 'Stussy',
      'price': 85000,
      'priceRange': '8-10만원대',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=300&fit=crop',
    },
    {
      'name': '퀜처 프로투어 1.18L',
      'brand': '스탠리',
      'price': 65000,
      'priceRange': '5-8만원대',
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
    },
    {
      'name': 'the pep lip treatment',
      'brand': 'Rhode',
      'price': 65000,
      'priceRange': '5-8만원대',
      'image': 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400&h=300&fit=crop',
    },
    {
      'name': 'Apple AirPods Pro',
      'brand': 'Apple',
      'price': 350000,
      'priceRange': '10만원 이상',
      'image': 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400&h=300&fit=crop',
    },
    {
      'name': 'Samsung Galaxy Watch',
      'brand': 'Samsung',
      'price': 45000,
      'priceRange': '4-5만원대',
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=300&fit=crop',
    },
    {
      'name': 'Nike Air Force 1',
      'brand': 'Nike',
      'price': 120000,
      'priceRange': '10만원 이상',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop',
    },
    {
      'name': 'Nike Air Force 1',
      'brand': 'Nike',
      'price': 120000,
      'priceRange': '10만원 이상',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=300&fit=crop',
    },
    
  ];
}
