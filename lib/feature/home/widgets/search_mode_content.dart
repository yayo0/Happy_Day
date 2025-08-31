import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';

class SearchModeContent extends StatefulWidget {
  final VoidCallback? onBack;
  
  const SearchModeContent({
    super.key,
    this.onBack,
  });

  @override
  State<SearchModeContent> createState() => _SearchModeContentState();
}

class _SearchModeContentState extends State<SearchModeContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = ['텀블러', '글로시립', '티셔츠', '스투시'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색바와 뒤로가기 버튼
          Row(
            children: [
                             // 뒤로가기 버튼
               if (widget.onBack != null) ...[
                 GestureDetector(
                   onTap: widget.onBack,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                     child: Icon(
                       Icons.keyboard_backspace,
                       color: AppColors.textDarker,
                       size: 24,
                     ),
                   ),
                 ),
                 const SizedBox(width: 12),
               ],
              
              // 검색바
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.baseLighter,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '선물 검색',
                      hintStyle: AppTypography.body1.copyWith(
                        color: AppColors.baseBase,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: Icon(
                        Icons.search,
                        color: AppColors.textDarker,
                        size: 24,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _performSearch(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // 최근 검색어
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '최근 검색어',
                style: AppTypography.title5.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: Text(
                  '모두 지우기',
                  style: AppTypography.body3.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 최근 검색어 태그들
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _recentSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.baseBase,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        search,
                        style: AppTypography.button4.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _recentSearches.remove(search);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          // 구분선
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            height: 1,
            color: AppColors.baseLighter,
          ),
          
          // 카테고리별 선물
          Text(
            '카테고리별 선물',
            style: AppTypography.title5.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          
          // 카테고리 필터
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryFilter(
                icon: Icons.attach_money,
                label: '가격대별',
                onTap: () {
                  // TODO: 가격대별 필터 구현
                },
              ),
              _buildCategoryFilter(
                icon: Icons.celebration,
                label: '상황별',
                onTap: () {
                  // TODO: 상황별 필터 구현
                },
              ),
              _buildCategoryFilter(
                icon: Icons.wc,
                label: '성별',
                onTap: () {
                  // TODO: 성별 필터 구현
                },
              ),
              _buildCategoryFilter(
                icon: Icons.stroller,
                label: '나이별',
                onTap: () {
                  // TODO: 나이별 필터 구현
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            child: Icon(
              icon,
              color: AppColors.primaryBase,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textDarker,
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    // TODO: 실제 검색 기능 구현
    print('검색어: $query');
  }
}
