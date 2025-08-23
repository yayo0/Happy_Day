import '../models/event.dart';
import '../models/product.dart';

class DummyData {
  // 기념일 이벤트 타입
  static final List<EventType> eventTypes = [
    EventType(
      id: '1',
      title: '기념일 등록',
      icon: '📅',
    ),
  ];

  // 기념일 이벤트들
  static final List<Event> events = [
    Event(
      id: '1',
      title: '강지석 생일',
      date: '8월 20일',
      profileImage: '🎂',
      isRegistered: true,
    ),
    Event(
      id: '2',
      title: '홍채윤 집들이',
      date: '8월 22일',
      profileImage: '🏠',
      isRegistered: true,
    ),
    Event(
      id: '3',
      title: '김민수 결혼기념일',
      date: '8월 25일',
      profileImage: '💍',
      isRegistered: true,
    ),
    Event(
      id: '4',
      title: '박지영 입사일',
      date: '8월 28일',
      profileImage: '💼',
      isRegistered: true,
    ),
  ];

  // 가격대 필터
  static final List<PriceRange> priceRanges = [
    PriceRange(
      id: '1',
      label: '5-8만원대',
      isSelected: true,
    ),
    PriceRange(
      id: '2',
      label: '4-5만원대',
      isSelected: false,
    ),
    PriceRange(
      id: '3',
      label: '8-10만원대',
      isSelected: false,
    ),
    PriceRange(
      id: '4',
      label: '10만원 이상',
      isSelected: false,
    ),
  ];

  // 상품들
  static final List<Product> products = [
    Product(
      id: '1',
      brand: 'Stussy',
      description: 'Nike x Stussy T-shirts white',
      image: '👕',
      price: 85000,
      hasFunding: false,
    ),
    Product(
      id: '2',
      brand: '스탠리',
      description: '퀜처 프로투어 1.18L',
      image: '🥤',
      price: 0,
      hasFunding: true,
    ),
    Product(
      id: '3',
      brand: 'Rho',
      description: 'the pep',
      image: '💄',
      price: 65000,
      hasFunding: false,
    ),
    Product(
      id: '4',
      brand: 'Apple',
      description: 'AirPods Pro 2세대',
      image: '🎧',
      price: 350000,
      hasFunding: false,
    ),
    Product(
      id: '5',
      brand: 'Samsung',
      description: 'Galaxy Watch 6',
      image: '⌚',
      price: 450000,
      hasFunding: false,
    ),
  ];
}
