import 'dart:convert';

import 'package:flutter/foundation.dart';

class ParkModel {
  final int eventPeriod;
  final double latitude;
  final double longitude;
  final int totalspace;
  final List<String> vehicles;
  ParkModel({
    required this.eventPeriod,
    required this.latitude,
    required this.longitude,
    required this.totalspace,
    required this.vehicles,
  });

  ParkModel copyWith({
    int? eventPeriod,
    double? latitude,
    double? longitude,
    int? totalspace,
    List<String>? vehicles,
  }) {
    return ParkModel(
      eventPeriod: eventPeriod ?? this.eventPeriod,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalspace: totalspace ?? this.totalspace,
      vehicles: vehicles ?? this.vehicles,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'eventPeriod': eventPeriod});
    result.addAll({'latitude': latitude});
    result.addAll({'longitude': longitude});
    result.addAll({'totalspace': totalspace});
    result.addAll({'vehicles': vehicles});
  
    return result;
  }

  factory ParkModel.fromMap(Map<String, dynamic> map) {
    return ParkModel(
      eventPeriod: map['eventPeriod']?.toInt() ?? 0,
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      totalspace: map['totalspace']?.toInt() ?? 0,
      vehicles: List<String>.from(map['vehicles']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParkModel.fromJson(String source) => ParkModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ParkModel(eventPeriod: $eventPeriod, latitude: $latitude, longitude: $longitude, totalspace: $totalspace, vehicles: $vehicles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ParkModel &&
      other.eventPeriod == eventPeriod &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.totalspace == totalspace &&
      listEquals(other.vehicles, vehicles);
  }

  @override
  int get hashCode {
    return eventPeriod.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      totalspace.hashCode ^
      vehicles.hashCode;
  }
}
