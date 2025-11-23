import 'package:equatable/equatable.dart';

class AreaModel extends Equatable {
  final int id;
  final String name;
  final List<SubAreaModel>? subAreas;

  const AreaModel({
    required this.id,
    required this.name,
    this.subAreas,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'],
      name: json['name'],
      subAreas: json['sub_areas'] != null
          ? (json['sub_areas'] as List)
              .map((e) => SubAreaModel.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name, subAreas];
}

class SubAreaModel extends Equatable {
  final int id;
  final int? areaId;
  final String name;
  final String? areaName;

  const SubAreaModel({
    required this.id,
    this.areaId,
    required this.name,
    this.areaName,
  });

  factory SubAreaModel.fromJson(Map<String, dynamic> json) {
    return SubAreaModel(
      id: json['id'],
      areaId: json['area_id'],
      name: json['name'],
      areaName: json['area_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_id': areaId,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, areaId, name, areaName];
}