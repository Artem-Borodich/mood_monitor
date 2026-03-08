/// Action type for a tip card.
enum TipAction {
  none,
  breathingTimer,
  logWalk,
}

class Tip {
  const Tip({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.whyItHelps,
    required this.howToDo,
    required this.iconName,
    this.action = TipAction.none,
  });

  final String id;
  /// One of: breathing, movement, sleep, mindset, quick_breaks
  final String category;
  final String title;
  final String description;
  final String whyItHelps;
  final List<String> howToDo;
  /// Icon name for category: air, directions_walk, bedtime, psychology, coffee
  final String iconName;
  final TipAction action;
}
