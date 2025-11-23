import 'package:equatable/equatable.dart';

class DeliveryBoyModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? address;
  final String? phoneNumber1;
  final String? phoneNumber2;
  final String? adharNumber;
  final String? drivingLicenceNumber;
  final String? panNumber;
  final bool isActive;
  final List<SubAreaAssignment>? subAreas;

  const DeliveryBoyModel({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.phoneNumber1,
    this.phoneNumber2,
    this.adharNumber,
    this.drivingLicenceNumber,
    this.panNumber,
    required this.isActive,
    this.subAreas,
  });

  factory DeliveryBoyModel.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      address: json['address'],
      phoneNumber1: json['phone_number1'],
      phoneNumber2: json['phone_number2'],
      adharNumber: json['adhar_number'],
      drivingLicenceNumber: json['driving_licence_number'],
      panNumber: json['pan_number'],
      isActive: json['is_active'] ?? true,
      subAreas: json['sub_areas'] != null
          ? (json['sub_areas'] as List)
              .map((e) => SubAreaAssignment.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'phone_number1': phoneNumber1,
      'phone_number2': phoneNumber2,
      'adhar_number': adharNumber,
      'driving_licence_number': drivingLicenceNumber,
      'pan_number': panNumber,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        address,
        phoneNumber1,
        phoneNumber2,
        adharNumber,
        drivingLicenceNumber,
        panNumber,
        isActive,
        subAreas,
      ];
}

class SubAreaAssignment extends Equatable {
  final int subAreaId;
  final String subAreaName;
  final int areaId;
  final String areaName;

  const SubAreaAssignment({
    required this.subAreaId,
    required this.subAreaName,
    required this.areaId,
    required this.areaName,
  });

  factory SubAreaAssignment.fromJson(Map<String, dynamic> json) {
    return SubAreaAssignment(
      subAreaId: json['sub_area_id'],
      subAreaName: json['sub_area_name'],
      areaId: json['area_id'],
      areaName: json['area_name'],
    );
  }

  @override
  List<Object?> get props => [subAreaId, subAreaName, areaId, areaName];
}