import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherData {
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final DateTime timestamp;
  final List<WeatherAlert> alerts;

  const WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.timestamp,
    required this.alerts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) => _$WeatherDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);
}

@JsonSerializable()
class WeatherAlert {
  final String id;
  final String title;
  final String description;
  final String severity; // low, medium, high, critical
  final DateTime startTime;
  final DateTime endTime;
  final String type; // rain, storm, drought, etc.

  const WeatherAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => _$WeatherAlertFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherAlertToJson(this);
}

@JsonSerializable()
class FarmingTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final String cropType;
  final DateTime publishedAt;
  final String? imageUrl;

  const FarmingTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cropType,
    required this.publishedAt,
    this.imageUrl,
  });

  factory FarmingTip.fromJson(Map<String, dynamic> json) => _$FarmingTipFromJson(json);
  Map<String, dynamic> toJson() => _$FarmingTipToJson(this);
}
