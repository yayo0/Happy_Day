import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../style/app_colors.dart';
import '../../style/app_typography.dart';
import 'widgets/special_days_section.dart';
import 'widgets/gift_recommendation_section.dart';
import 'widgets/curation_section.dart';
import 'widgets/gift_search_section.dart';
import 'widgets/search_mode_content.dart';
import 'widgets/home_header_section.dart';
import 'widgets/gift_selection_screen.dart';
import 'widgets/gift_browse_screen.dart';
import 'widgets/wishlist_screen.dart';
import 'widgets/more_screen.dart';
import '../give_funding/funding_page.dart';
import '../funding/make.dart';
import 'widgets/make_special_day.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _currentMode = 'home'; // 'home', 'search', 'gift', 'gift_browse', 'wishlist', 'more', 'make_special_day'
  Map<String, dynamic>? _selectedRecipient; // 선택된 수령인 정보
  
  // 토스트 관련 변수
  bool _showToast = false;
  late AnimationController _toastController;
  late Animation<double> _toastAnimation;
  
  // 기념일 데이터
  final List<Map<String, dynamic>> _events = [
    {
      'name': '강지석',
      'eventType': '생일',
      'date': '8월 20일',
      'characterType': 1,
    },
    {
      'name': '홍채윤',
      'eventType': '집들이',
      'date': '8월 22일',
      'characterType': 3,
    },
    {
      'name': '김민수',
      'eventType': '결혼기념일',
      'date': '8월 25일',
      'characterType': 5,
    },
    {
      'name': '박지영',
      'eventType': '입사일',
      'date': '8월 28일',
      'characterType': 7,
    },
  ];
  
  // 등록된 기념일이 있는지 여부
  bool get _hasRegisteredEvents => _events.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _toastController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toastAnimation = Tween<double>(
      begin: -80,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _toastController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
  }

  void _showWishlistToast() {
    setState(() {
      _showToast = true;
    });
    _toastController.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _toastController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showToast = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _currentMode == 'more' ? AppColors.baseLightest : AppColors.gray00,
          appBar: AppBar(
        backgroundColor: _currentMode == 'make_special_day' ? AppColors.baseLighter : AppColors.gray00,
        // foregroundColor: AppColors.textDarkest,
        elevation: 0,
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: _currentMode == 'make_special_day' ? AppColors.baseLighter : AppColors.gray00,
      ),
      body: Stack(
        children: [
          // 스크롤 가능한 콘텐츠
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더가 있을 공간 확보 (검색, 선물하기, 기념일 만들기 모드가 아닐 때)
                if (_currentMode != 'search' && _currentMode != 'gift' && _currentMode != 'make_special_day') ...[
                  const SizedBox(height: 100), // 헤더 높이만큼 공간 확보
                ] else ...[
                  const SizedBox(height: 0),
                ],
 
                
                // 모드에 따라 다른 콘텐츠 표시
                if (_currentMode == 'search') ...[
                  SearchModeContent(
                    onBack: () {
                      setState(() {
                        _currentMode = 'home';
                      });
                    },
                  ),
                ] else if (_currentMode == 'gift') ...[
                  GiftSelectionScreen(
                    recipientInfo: _selectedRecipient!,
                    onBack: () {
                      setState(() {
                        _currentMode = 'home';
                        _selectedRecipient = null;
                      });
                    },
                  ),
                ] else if (_currentMode == 'gift_browse') ...[
                  GiftBrowseScreen(
                    onBack: () {
                      setState(() {
                        _currentMode = 'home';
                        _selectedIndex = 0;
                      });
                    },
                    onShowToast: _showWishlistToast,
                  ),
                ] else if (_currentMode == 'wishlist') ...[
                  WishlistScreen(
                    onBack: () {
                      setState(() {
                        _currentMode = 'home';
                        _selectedIndex = 0;
                      });
                    },
                    onShowToast: _showWishlistToast,
                  ),
                ] else if (_currentMode == 'more') ...[
                  MoreScreen(
                    onBack: () {
                      setState(() {
                        _currentMode = 'home';
                        _selectedIndex = 0;
                      });
                    },
                  ),
                ] else if (_currentMode == 'make_special_day') ...[
                  MakeSpecialDay(
                    onBack: () {
                      setState(() {
                        _currentMode = 'home';
                      });
                    },
                  ),
                ] else ...[
                   // 기념일이 있을 때만 SpecialDaysSection 렌더링
                   if (_events.isNotEmpty) ...[
                     SpecialDaysSection(
                       events: _events,
                       onGiftButtonTap: (recipientInfo) {
                         // 펀딩 페이지로 이동
                         Navigator.of(context).push(
                           MaterialPageRoute(
                             builder: (_) => FundingPage(
                               data: {
                                 'name': recipientInfo['name'] ?? '친구',
                                 'product': '스탠리 텀블러',
                                 'productImage': 'https://images.unsplash.com/photo-1545239705-8836f1ab6aff',
                                 'type': '자유', // N빵 또는 자유
                                 'price': 56000, // 총 상품 금액
                                 'endDate': DateTime.now().add(const Duration(days: 4)).toIso8601String(),
                                 'fundingTitle': '웃으면 안되는 생일파티',
                                 'paritcipants': [
                                   {
                                     'name': '벨라', 
                                     'characterType': 1,
                                     'fundedAmount': 15000,
                                     'letter': {
                                       'isPrivacy': false,
                                       'content': '생일 축하해 ${recipientInfo['name'] ?? '친구'}야! 친구들이랑 함께 선물 준비해봤어',
                                     },
                                   },
                                   {
                                     'name': '보우', 
                                     'characterType': 2,
                                     'fundedAmount': 8000,
                                     'letter': {
                                       'isPrivacy': true,
                                       'content': '비밀 메시지입니다.',
                                     },
                                   },
                                   {
                                     'name': '세원', 
                                     'characterType': 3,
                                     'fundedAmount': 9000,
                                     'letter': {
                                       'isPrivacy': false,
                                       'content': '${recipientInfo['name'] ?? '친구'}야 생일 축하해! 오늘 하루도 행복하게 보내!',
                                     },
                                   },
                                   {
                                     'name': '희안', 
                                     'characterType': 4,
                                     'fundedAmount': 7000,
                                     'letter': {
                                       'isPrivacy': false,
                                       'content': '생일 축하해! 오늘 하루도 웃음 가득한 하루가 되길 바라!',
                                     },
                                   },
                                   {
                                     'name': '샘', 
                                     'characterType': 5,
                                     'fundedAmount': 2000,
                                     'letter': {
                                       'isPrivacy': false,
                                       'content': '${recipientInfo['name'] ?? '친구'}야 생일 축하해! 오늘 하루도 즐겁게 보내!',
                                     },
                                   },
                                 ],
                               },
                             ),
                           ),
                         );
                       },
                       onRegisterTap: () {
                         setState(() {
                           _currentMode = 'make_special_day';
                         });
                       },
                     ),
                     const SizedBox(height: 32),
                   ],
                   
                   // OO님의 취향에 맞는 선물 섹션
                   const GiftRecommendationSection(),
                   const SizedBox(height: 32),
                   
                   // 요즘 뜨는 선물 큐레이션 섹션
                   const CurationSection(),
                   const SizedBox(height: 32),
                   
                   // 선물 검색 섹션
                   GiftSearchSection(
                     onSearchTap: () {
                       setState(() {
                         _currentMode = 'search';
                       });
                     },
                   ),
                 ],
                const SizedBox(height: 100), // 펀딩 버튼과 하단 네비게이션 바 공간
                
              ],
            ),
          ),
          
          // 펀딩 만들기 버튼 (고정) - 홈 모드에서만 표시
          if (_currentMode == 'home') ...[
            Positioned(
              bottom: 10, // 하단 네비게이션 바 위에 위치
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 150,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBase,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MakeFundingScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'lib/feature/home/asset/gift.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                AppColors.textWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '펀딩 만들기',
                              style: AppTypography.button3.copyWith(
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          // 고정 헤더 (스크롤과 무관하게 항상 위에 표시)
          if (_currentMode != 'search' && _currentMode != 'gift' && _currentMode != 'make_special_day') ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: _currentMode == 'more' ? AppColors.baseLightest : AppColors.gray00, // 배경색으로 뒤쪽 콘텐츠 가림
                padding: const EdgeInsets.only(top: 20, bottom: 0), // 더보기일 때 하단 패딩 제거
                child: HomeHeaderSection(
                  hasRegisteredEvents: _hasRegisteredEvents,
                  currentMode: _currentMode,
                  onCalendarTap: () {
                    setState(() {
                      _currentMode = 'make_special_day';
                    });
                  },
                  onHomeTap: () {
                    setState(() {
                      _currentMode = 'home';
                      _selectedIndex = 0;
                    });
                  },
                ),
              ),
            ),
          ],
        ],
      ),
          bottomNavigationBar: (_currentMode == 'search' || _currentMode == 'gift' || _currentMode == 'make_special_day') ? null : _buildBottomNavigationBar(),
        ),
        // 화면 고정 토스트 UI
        if (_showToast)
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 20, // 헤더 아래 위치
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _toastAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _toastAnimation.value),
                  child: Container(
                    height: 56, // 명시적 높이 설정
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.textDarkest,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              '위시리스트에 추가되었어요',
                              style: TextStyle(
                                fontSize: AppTypography.title5.fontSize,
                                fontWeight: AppTypography.title5.fontWeight,
                                fontFamily: AppTypography.title5.fontFamily,
                                color: AppColors.textWhite,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            // TODO: 위시리스트 목록 페이지로 이동
                          },
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              '목록보기',
                              style: TextStyle(
                                fontSize: AppTypography.title5.fontSize,
                                fontWeight: AppTypography.title5.fontWeight,
                                fontFamily: AppTypography.title5.fontFamily,
                                color: AppColors.primaryBase,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryBase,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border(
          top: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            setState(() {
              _currentMode = 'home';
              _selectedIndex = index;
            });
            return;
          }
          if (index == 1) {
            // 선물 둘러보기 탭 클릭 시 gift_browse 모드로 변경
            setState(() {
              _currentMode = 'gift_browse';
              _selectedIndex = index;
            });
            return;
          }
          if (index == 2) {
            // 위시리스트 탭 클릭 시 wishlist 모드로 변경
            setState(() {
              _currentMode = 'wishlist';
              _selectedIndex = index;
            });
            return;
          }
          if (index == 3) {
            // 더보기 탭 클릭 시 more 모드로 변경
            setState(() {
              _currentMode = 'more';
              _selectedIndex = index;
            });
            return;
          }
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '선물 둘러보기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '위시리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: '더보기',
          ),
        ],
      ),
    );
  }
}
