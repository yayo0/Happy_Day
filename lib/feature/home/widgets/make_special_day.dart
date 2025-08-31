import 'package:flutter/material.dart';
import '../../../style/app_colors.dart';
import '../../../style/app_typography.dart';
import '../../../interface/character.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MakeSpecialDay extends StatefulWidget {
  final VoidCallback onBack;

  const MakeSpecialDay({super.key, required this.onBack});

  @override
  State<MakeSpecialDay> createState() => _MakeSpecialDayState();
}

class _MakeSpecialDayState extends State<MakeSpecialDay> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // 예시 데이터 구조: { 'YYYY-MM-DD': [ { user: {...}, state: '' }, ... ] }
  final Map<String, List<Map<String, dynamic>>> _eventsByDate = {
    // 예시
    '2025-08-22': [
      {
        'user': {
          'name': '홍채윤',
          'characterType': 3,
          'eventType': '집들이',
          'date': '8월 22일',
        },
        'state': '펀딩 중',
      },
      {
        'user': {
          'name': '홍채윤',
          'characterType': 3,
          'eventType': '집들이',
          'date': '8월 22일',
        },
        'state': '펀딩 완료',
      },
      {
        'user': {
          'name': '홍채윤',
          'characterType': 3,
          'eventType': '집들이',
          'date': '8월 22일',
        },
        'state': '선물하기',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final days = _buildDaysOfMonth(_currentMonth);
    final selectedKey = _formatDateKey(_selectedDate);
    final dayEvents = _eventsByDate[selectedKey] ?? [];

    return Column(
      children: [
        // 상단 바: 기본 / 검색 모드
        Container(
          color: AppColors.baseLighter,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: _isSearching
                ? Row(
                    children: [
                      // backspace 아이콘 (검색 모드 종료)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.keyboard_backspace,
                            color: AppColors.textDark,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 검색 바 (남은 공간 모두 차지)
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.baseWhite,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            cursorColor: AppColors.primaryBase,
                            textAlignVertical: TextAlignVertical.center,
                            style: AppTypography.body1.copyWith(color: AppColors.textDarkest),
                            decoration: InputDecoration(
                              hintText: '기념일/이름 검색',
                              hintStyle: AppTypography.body1.copyWith(color: AppColors.textLightest),
                              border: InputBorder.none,
                              isDense: true,
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              suffixIcon: const Icon(Icons.search, color: AppColors.textDark, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppColors.textDarkest,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '기념일 등록하기',
                          style: AppTypography.title5.copyWith(
                            color: AppColors.textDarkest,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                        child: Icon(
                          Icons.search,
                          color: AppColors.textDark,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // 월 표시 및 네비게이션 (중앙 정렬, 좌우 원형 테두리 화살표)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.baseWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textDark, width: 1),
                    ),
                    child: const Center(
                      child: Icon(Icons.chevron_left, size: 16, color: AppColors.textDark),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_currentMonth.year}. ${_twoDigits(_currentMonth.month)}',
                  style: AppTypography.title4.copyWith(color: AppColors.textDarkest),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.baseWhite,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.textDark, width: 1),
                    ),
                    child: const Center(
                      child: Icon(Icons.chevron_right, size: 16, color: AppColors.textDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // 요일 헤더 (그리드와 동일 레이아웃로 정렬)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 32,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 0,
              ),
              itemCount: 7,
              itemBuilder: (context, i) {
                const labels = ['일','월','화','수','목','금','토'];
                final isSunday = i == 0;
                return Center(
                  child: Text(
                    labels[i],
                    style: AppTypography.button4.copyWith(
                      color: isSunday ? AppColors.error : AppColors.textDark,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 캘린더 Grid (요일 헤더와 동일한 좌우 여백/간격)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) {
                return const SizedBox.shrink();
              }
              final isPast = day.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
              final isTodayOrFuture = !isPast;
              final isSelected = _isSameDate(day, _selectedDate);
              final hasEvents = _eventsByDate.containsKey(_formatDateKey(day));

              final isSundayCol = index % 7 == 0;
              final textColor = isSundayCol
                  ? AppColors.error
                  : (isPast ? AppColors.textLighter : AppColors.textDarkest);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isSelected)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLighter,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text('${day.day}', style: AppTypography.body3.copyWith(color: textColor)),
                    if (hasEvents)
                      Positioned(
                        bottom: 8,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBase,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        Container(height: 16, color: AppColors.baseLighter),

        // 선택 날짜 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Row(
            children: [
              Text(_formatDateKorean(_selectedDate), style: AppTypography.title3.copyWith(color: AppColors.textDarker)),
              const Spacer(),
              _buildAddCalendarButton(),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 선택 날짜의 이벤트 목록
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: dayEvents.map((e) => _buildEventRow(e)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCalendarButton() {
    return GestureDetector(
      onTap: _showAddEventBottomSheet,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLightest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: SvgPicture.asset(
            'lib/feature/home/asset/addCalendar.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(AppColors.primaryBase, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  void _showAddEventBottomSheet() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController eventTypeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final bottomInset = media.viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: AppColors.textLighter,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Icon(
                        Icons.check,
                        size: 22,
                        color: AppColors.textLighter,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatFullKoreanDateWithWeekday(_selectedDate),
                  style: AppTypography.title1.copyWith(color: AppColors.textDarkest),
                ),
                const SizedBox(height: 22),
                Text('친구 이름', style: AppTypography.subtitle2.copyWith(color: AppColors.primaryBase)),
                const SizedBox(height: 8),
                _BottomInput(
                  controller: nameController,
                  hintText: '친구 이름(닉네임)',
                ),
                const SizedBox(height: 24),
                Text('기념일 종류', style: AppTypography.subtitle2.copyWith(color: AppColors.primaryBase)),
                const SizedBox(height: 8),
                _BottomInput(
                  controller: eventTypeController,
                  hintText: '예시) 생일, 집들이, 결혼,..',
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatFullKoreanDateWithWeekday(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];
    return '${date.month}월 ${date.day}일 $weekday';
  }

  Widget _buildEventRow(Map<String, dynamic> item) {
    final user = item['user'] as Map<String, dynamic>;
    final state = item['state'] as String;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CharacterAvatar(characterType: (user['characterType'] ?? 1) as int, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user['name'] as String, style: AppTypography.title4.copyWith(color: AppColors.textDark)),
                    const SizedBox(width: 8),
                    Text(user['eventType'] as String, style: AppTypography.caption1.copyWith(color: AppColors.textLight)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(user['date'] as String, style: AppTypography.body2.copyWith(color: AppColors.textLight)),
              ],
            ),
          ),
          _buildStateButton(state),
        ],
      ),
    );
  }

  Widget _buildStateButton(String state) {
    Color bg;
    Color fg;
    if (state == '펀딩 중') {
      bg = AppColors.baseLighter;
      fg = AppColors.textLighter;
    } else if (state == '펀딩 완료') {
      bg = AppColors.success.withOpacity(0.1);
      fg = AppColors.success;
    } else {
      bg = AppColors.primaryLightest;
      fg = AppColors.primaryBase;
    }
    return Container(
      width: 105,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          state,
          style: AppTypography.button3.copyWith(color: fg),
        ),
      ),
    );
  }

  List<DateTime?> _buildDaysOfMonth(DateTime base) {
    final firstDay = DateTime(base.year, base.month, 1);
    final firstWeekday = firstDay.weekday % 7; // Sunday=0
    final daysInMonth = DateTime(base.year, base.month + 1, 0).day;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    final List<DateTime?> days = List.filled(totalCells, null);
    for (int i = 0; i < daysInMonth; i++) {
      days[firstWeekday + i] = DateTime(base.year, base.month, i + 1);
    }
    return days;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateKey(DateTime d) {
    return '${d.year}-${_twoDigits(d.month)}-${_twoDigits(d.day)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _formatDateKorean(DateTime d) {
    return '${d.month}월 ${d.day}일';
  }
}

class _BottomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _BottomInput({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.baseLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        cursorColor: AppColors.primaryBase,
        style: AppTypography.body1.copyWith(color: AppColors.textDarkest),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.body1.copyWith(color: AppColors.textLighter),
          border: InputBorder.none,
          isDense: true,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

}

