import 'package:equatable/equatable.dart';

class CustomerModel extends Equatable {
  final int id;
  final String name;
  final String phoneNumber;
  final String? address;
  final String? whatsappNumber;
  final String? locationLink;
  final double? latitude;
  final double? longitude;
  final double permanentQuantity;
  final int? subAreaId;
  final String? subAreaName;
  final String? areaName;
  final int? deliveryBoyId;
  final String? deliveryBoyName;
  final double? sortNumber;
  final bool isApproved;
  final bool pendingApproval;
  final bool? isActive;
  final String? shift;
  final double? totalPendingMoney;
  final int? lastTimePendingBottles;
  final bool? todayDeliveryStatus;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.whatsappNumber,
    this.locationLink,
    this.latitude,
    this.longitude,
    required this.permanentQuantity,
    this.subAreaId,
    this.subAreaName,
    this.areaName,
    this.deliveryBoyId,
    this.deliveryBoyName,
    this.sortNumber,
    required this.isApproved,
    required this.pendingApproval,
    this.isActive,
    this.shift,
    this.totalPendingMoney,
    this.lastTimePendingBottles,
    this.todayDeliveryStatus,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      whatsappNumber: json['whatsapp_number'],
      locationLink: json['location_link'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      permanentQuantity:
          double.tryParse(json['permanent_quantity'].toString()) ?? 0,
      subAreaId: json['sub_area_id'],
      subAreaName: json['sub_area_name'],
      areaName: json['area_name'],
      deliveryBoyId: json['delivery_boy_id'],
      deliveryBoyName: json['delivery_boy_name'],
      sortNumber: json['sort_number'] != null
          ? (json['sort_number'] is num
                ? (json['sort_number'] as num).toDouble()
                : double.tryParse(json['sort_number'].toString()))
          : null,
      isApproved: json['is_approved'] ?? false,
      pendingApproval: json['pending_approval'] ?? false,
      isActive: json['is_active'] != null
          ? (json['is_active'] is bool
                ? json['is_active']
                : (json['is_active'].toString() == '1' ||
                      json['is_active'].toString().toLowerCase() == 'true'))
          : true,
      shift: json['shift'] ?? json['shift_time'] ?? null,
      totalPendingMoney: json['total_pending_money'] != null
          ? double.tryParse(json['total_pending_money'].toString())
          : null,
      lastTimePendingBottles: json['last_time_pending_bottles'],
      todayDeliveryStatus: json['today_delivery_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'whatsapp_number': whatsappNumber,
      'location_link': locationLink,
      'latitude': latitude,
      'longitude': longitude,
      'permanent_quantity': permanentQuantity,
      'sub_area_id': subAreaId,
      'delivery_boy_id': deliveryBoyId,
      'sort_number': sortNumber,
      'is_approved': isApproved,
      'pending_approval': pendingApproval,
      'is_active': isActive,
      'shift': shift,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    address,
    whatsappNumber,
    locationLink,
    latitude,
    longitude,
    permanentQuantity,
    subAreaId,
    subAreaName,
    areaName,
    deliveryBoyId,
    deliveryBoyName,
    sortNumber,
    isApproved,
    pendingApproval,
    totalPendingMoney,
    lastTimePendingBottles,
    todayDeliveryStatus,
  ];
}
