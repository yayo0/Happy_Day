import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class CurationSection extends StatefulWidget {
  const CurationSection({super.key});

  @override
  State<CurationSection> createState() => _CurationSectionState();
}

class _CurationSectionState extends State<CurationSection> {
  String _selectedCategory = '집들이';

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
                '요즘 뜨는 선물 큐레이션',
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
          
          // 카테고리 탭
          SizedBox(
            height: 35,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                
                return Container(
                   margin: const EdgeInsets.only(right: 8),
                   width: 75,
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
                         ),
                         if (isSelected)
                           Container(
                             margin: const EdgeInsets.only(top: 4),
                             width: 65,
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
          ),
          const SizedBox(height: 20),
          
          // 큐레이션 카드 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _getFilteredCurations().length,
            itemBuilder: (context, index) {
              final curation = _getFilteredCurations()[index];
              return _buildCurationCard(curation);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurationCard(Map<String, String> curation) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 큐레이션 이미지
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Image.network(
              curation['image']!,
              width: 170,
              height: 111,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 170,
                  height: 111,
                  color: AppColors.gray100,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 170,
                  height: 111,
                  color: AppColors.gray100,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          
          // 큐레이션 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical:8),
            child: Text(
              curation['title']!,
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textDarker,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 선택된 카테고리에 맞는 큐레이션 반환
  List<Map<String, String>> _getFilteredCurations() {
    return _dummyCurations.where((curation) {
      return curation['category'] == _selectedCategory;
    }).toList();
  }

  // 카테고리 목록
  final List<String> _categories = [
    '집들이',
    '생일',
    '졸업',
    '신혼/결혼',
    '스승의날',
  ];

  // 더미 큐레이션 데이터
  final List<Map<String, String>> _dummyCurations = [
    {
      'category': '집들이',
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
      'title': '집들이 선물로 들고 가는 술술 잘 풀리는 선물들',
    },
    {
      'category': '집들이',
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
      'title': '새집을 더 아름답게 만들어주는 인테리어 소품',
    },
    {
      'category': '집들이',
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop',
      'title': '새집을 더 아름답게 만들어주는 인테리어 소품',
    },
    {
      'category': '생일',
      'image': 'https://images.unsplash.com/photo-1464349153735-7db50ed83c84?w=400&h=300&fit=crop',
      'title': '특별한 생일을 더욱 특별하게 만들어주는 선물',
    },
    {
      'category': '생일',
      'image': 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=400&h=300&fit=crop',
      'title': '연령대별 인기 생일 선물 베스트',
    },
    {
      'category': '졸업',
      'image': 'https://images.unsplash.com/photo-1523050854058-8df90110cfe1?w=400&h=300&fit=crop',
      'title': '졸업을 축하하는 의미있는 선물 모음',
    },
    {
      'category': '졸업',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
      'title': '새로운 시작을 위한 실용적인 졸업 선물',
    },
    {
      'category': '신혼/결혼',
      'image': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&h=300&fit=crop',
      'title': '신혼부부를 위한 따뜻한 신혼 선물',
    },
    {
      'category': '신혼/결혼',
      'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400&h=300&fit=crop',
      'title': '새로운 가정을 위한 실용적인 결혼 선물',
    },
    {
      'category': '스승의날',
      'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400&h=300&fit=crop',
      'title': '스승님의 은혜를 기리는 감사한 선물',
    },
    {
      'category': '스승의날',
      'image': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=300&fit=crop',
      'title': '선생님을 위한 특별한 스승의날 선물',
    },
  ];
}
