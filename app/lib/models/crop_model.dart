import 'package:json_annotation/json_annotation.dart';

part 'crop_model.g.dart';

enum CropType {
  rice,
  wheat,
  maize,
  cotton,
  sugarcane,
  potato,
  tomato,
  onion,
  chili,
  other
}

enum CropStage {
  sowing,
  vegetative,
  flowering,
  fruiting,
  harvest
}

@JsonSerializable()
class Crop {
  final String id;
  final String farmerId;
  final String name;
  final CropType type;
  final DateTime sowingDate;
  final double area; // in acres
  final double latitude;
  final double longitude;
  final String address;
  final String? imageUrl;
  final CropStage currentStage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? additionalData;

  const Crop({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.type,
    required this.sowingDate,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrl,
    required this.currentStage,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => _$CropFromJson(json);
  Map<String, dynamic> toJson() => _$CropToJson(this);

  Crop copyWith({
    String? id,
    String? farmerId,
    String? name,
    CropType? type,
    DateTime? sowingDate,
    double? area,
    double? latitude,
    double? longitude,
    String? address,
    String? imageUrl,
    CropStage? currentStage,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return Crop(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      type: type ?? this.type,
      sowingDate: sowingDate ?? this.sowingDate,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      currentStage: currentStage ?? this.currentStage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case CropType.rice:
        return 'Rice';
      case CropType.wheat:
        return 'Wheat';
      case CropType.maize:
        return 'Maize';
      case CropType.cotton:
        return 'Cotton';
      case CropType.sugarcane:
        return 'Sugarcane';
      case CropType.potato:
        return 'Potato';
      case CropType.tomato:
        return 'Tomato';
      case CropType.onion:
        return 'Onion';
      case CropType.chili:
        return 'Chili';
      case CropType.other:
        return 'Other';
    }
  }

  String get stageDisplayName {
    switch (currentStage) {
      case CropStage.sowing:
        return 'Sowing';
      case CropStage.vegetative:
        return 'Vegetative';
      case CropStage.flowering:
        return 'Flowering';
      case CropStage.fruiting:
        return 'Fruiting';
      case CropStage.harvest:
        return 'Harvest';
    }
  }
}
