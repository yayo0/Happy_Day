import 'package:flutter/material.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';

class SearchGiftScreen extends StatefulWidget {
  const SearchGiftScreen({super.key});

  @override
  State<SearchGiftScreen> createState() => _SearchGiftScreenState();
}

class _SearchGiftScreenState extends State<SearchGiftScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = ['생일선물', '집들이선물', '졸업선물'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray00,
      appBar: AppBar(
        title: Text(
          '선물 검색',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textDarkest,
          ),
        ),
        backgroundColor: AppColors.gray00,
        foregroundColor: AppColors.textDarkest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색바
            Container(
              decoration: BoxDecoration(
                color: AppColors.baseLighter,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '찾고 싶은 선물을 검색해보세요',
                  hintStyle: AppTypography.subtitle2.copyWith(
                    color: AppColors.baseBase,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: AppColors.textDarker,
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
            const SizedBox(height: 32),
            
            // 최근 검색어
            if (_recentSearches.isNotEmpty) ...[
              Text(
                '최근 검색어',
                style: AppTypography.title2.copyWith(
                  color: AppColors.textDarker,
                ),
              ),
              const SizedBox(height: 16),
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
                        color: AppColors.baseLighter,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        search,
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textDarker,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // 인기 검색어
            Text(
              '인기 검색어',
              style: AppTypography.title2.copyWith(
                color: AppColors.textDarker,
              ),
            ),
            const SizedBox(height: 16),
            _buildPopularSearchItem('생일선물', '🎂'),
            _buildPopularSearchItem('집들이선물', '🏠'),
            _buildPopularSearchItem('졸업선물', '🎓'),
            _buildPopularSearchItem('신혼선물', '💍'),
            _buildPopularSearchItem('스승의날선물', '👨‍🏫'),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearchItem(String text, String emoji) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _performSearch(text);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.baseLighter,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textDarker,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    // TODO: 실제 검색 기능 구현
    print('검색어: $query');
    // 여기에 검색 결과 페이지로 이동하는 로직을 추가할 수 있습니다
  }
}
