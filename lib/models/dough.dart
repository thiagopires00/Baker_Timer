class Dough {
  String name;
  int speed1Time; // Stored in seconds
  int speed2Time; // Stored in seconds

  Dough({required this.name, required this.speed1Time, required this.speed2Time});

  // Convert a Dough object into a Map object (for JSON encoding)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'speed1Time': speed1Time,
      'speed2Time': speed2Time,
    };
  }

  // Convert a Map object back into a Dough object (for JSON decoding)
  factory Dough.fromJson(Map<String, dynamic> json) {
    return Dough(
      name: json['name'],
      speed1Time: json['speed1Time'],
      speed2Time: json['speed2Time'],
    );
  }
}
