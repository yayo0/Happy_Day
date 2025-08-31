import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';

class WishlistScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onShowToast;
  
  const WishlistScreen({
    super.key,
    required this.onBack,
    this.onShowToast,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedFriend = '강지석';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 친구들의 위시는? 제목
              Text(
                '친구들의 위시는?',
                style: AppTypography.title2.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              const SizedBox(height: 16),
              
              // 친구들 목록 컨테이너
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _friendsData.length,
                    itemBuilder: (context, index) {
                      final friend = _friendsData[index];
                      final isSelected = _selectedFriend == friend['name'];
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFriend = friend['name'];
                            });
                          },
                          child: Column(
                            children: [
                              CharacterAvatar(
                                characterType: friend['characterType'],
                                size: 50,
                                backgroundColor: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                friend['name'],
                                style: AppTypography.caption2.copyWith(
                                  color: AppColors.textDarker,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // OO님의 위시리스트 제목
              Text(
                '$_selectedFriend님의 위시리스트',
                style: AppTypography.title2.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              const SizedBox(height: 16),
              
              // 위시리스트 아이템들
              _buildWishlistItems(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistItems() {
    return Column(
      children: _dummyWishlistItems.map((item) => _buildWishlistItem(item)).toList(),
    );
  }

  Widget _buildWishlistItem(Map<String, dynamic> item) {
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
                    Icon(
                      Icons.favorite, // 채워진 하트
                      color: AppColors.error, // error 색으로
                      size: 16,
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

  // 친구들 데이터
  final List<Map<String, dynamic>> _friendsData = [
    {'name': '강지석', 'characterType': 1},
    {'name': '홍채윤', 'characterType': 2},
    {'name': '김민수', 'characterType': 3},
    {'name': '박지영', 'characterType': 4},
    {'name': '이수진', 'characterType': 5},
    {'name': '정하늘', 'characterType': 6},
    {'name': '최윤아', 'characterType': 7},
  ];

  // 더미 위시리스트 데이터
  final List<Map<String, dynamic>> _dummyWishlistItems = [
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
  ];
}
