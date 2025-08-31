class Event {
  final String id;
  final String title;
  final String date;
  final String profileImage;
  final bool isRegistered;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.profileImage,
    required this.isRegistered,
  });
}

class EventType {
  final String id;
  final String title;
  final String icon;

  EventType({
    required this.id,
    required this.title,
    required this.icon,
  });
}
