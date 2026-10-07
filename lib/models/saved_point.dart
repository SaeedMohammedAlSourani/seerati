class SavedPoint {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final DateTime savedAt;

  SavedPoint({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': lat,
    'lng': lng,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedPoint.fromJson(Map<String, dynamic> json) => SavedPoint(
    id: json['id'] as String,
    name: json['name'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    savedAt: DateTime.parse(json['savedAt'] as String),
  );
}