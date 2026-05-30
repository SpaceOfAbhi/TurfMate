class MatchModel {
  final String id;
  final String sport;
  final String turfName;
  final double latitude;
  final double longitude;
  final int availableSlots;
  final double? amountPerPerson;
  final String locationName;

  MatchModel({
    required this.id,
    required this.sport,
    required this.turfName,
    required this.latitude,
    required this.longitude,
    required this.availableSlots,
    required this.locationName,

    this.amountPerPerson,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      sport: json['sport'],
      turfName: json['turf_name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      availableSlots: json['available_slots'],
      locationName: json["location_name"] ?? "",
      amountPerPerson: json['amount_per_person'] != null
          ? double.parse(json['amount_per_person'].toString())
          : null,
    );
  }
}
