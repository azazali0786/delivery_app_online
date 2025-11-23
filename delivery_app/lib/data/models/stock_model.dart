import 'package:equatable/equatable.dart';

class StockModel extends Equatable {
  final int id;
  final int deliveryBoyId;
  final String? deliveryBoyName;
  final int halfLtrBottles;
  final int oneLtrBottles;
  final int collectedBottles;
  final String entryDate;
  final String? createdAt;

  const StockModel({
    required this.id,
    required this.deliveryBoyId,
    this.deliveryBoyName,
    required this.halfLtrBottles,
    required this.oneLtrBottles,
    required this.collectedBottles,
    required this.entryDate,
    this.createdAt,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'],
      deliveryBoyId: json['delivery_boy_id'],
      deliveryBoyName: json['delivery_boy_name'],
      halfLtrBottles: json['half_ltr_bottles'] ?? 0,
      oneLtrBottles: json['one_ltr_bottles'] ?? 0,
      collectedBottles: json['collected_bottles'] ?? 0,
      entryDate: json['entry_date'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_boy_id': deliveryBoyId,
      'half_ltr_bottles': halfLtrBottles,
      'one_ltr_bottles': oneLtrBottles,
      'collected_bottles': collectedBottles,
      'entry_date': entryDate,
    };
  }

  double get totalMilk => (halfLtrBottles * 0.5) + oneLtrBottles;

  @override
  List<Object?> get props => [
        id,
        deliveryBoyId,
        deliveryBoyName,
        halfLtrBottles,
        oneLtrBottles,
        collectedBottles,
        entryDate,
        createdAt,
      ];
}