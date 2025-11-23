import 'package:equatable/equatable.dart';

class EntryModel extends Equatable {
  final int id;
  final int customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final int? deliveryBoyId;
  final String? deliveryBoyName;
  final double milkQuantity;
  final double collectedMoney;
  final int pendingBottles;
  final double rate;
  final String paymentMethod;
  final String? transactionPhoto;
  final bool isDelivered;
  final String? notDeliveredReason;
  final String entryDate;
  final String? createdAt;

  const EntryModel({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.deliveryBoyId,
    this.deliveryBoyName,
    required this.milkQuantity,
    required this.collectedMoney,
    required this.pendingBottles,
    required this.rate,
    required this.paymentMethod,
    this.transactionPhoto,
    required this.isDelivered,
    this.notDeliveredReason,
    required this.entryDate,
    this.createdAt,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      customerAddress: json['customer_address'],
      deliveryBoyId: json['delivery_boy_id'],
      deliveryBoyName: json['delivery_boy_name'],
      milkQuantity: double.tryParse(json['milk_quantity'].toString()) ?? 0,
      collectedMoney: double.tryParse(json['collected_money'].toString()) ?? 0,
      pendingBottles: json['pending_bottles'] ?? 0,
      rate: double.tryParse(json['rate'].toString()) ?? 0,
      paymentMethod: json['payment_method'] ?? 'cash',
      transactionPhoto: json['transaction_photo'],
      isDelivered: json['is_delivered'] ?? true,
      notDeliveredReason: json['not_delivered_reason'],
      entryDate: json['entry_date'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'delivery_boy_id': deliveryBoyId,
      'milk_quantity': milkQuantity,
      'collected_money': collectedMoney,
      'pending_bottles': pendingBottles,
      'rate': rate,
      'payment_method': paymentMethod,
      'transaction_photo': transactionPhoto,
      'is_delivered': isDelivered,
      'not_delivered_reason': notDeliveredReason,
      'entry_date': entryDate,
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        deliveryBoyId,
        deliveryBoyName,
        milkQuantity,
        collectedMoney,
        pendingBottles,
        rate,
        paymentMethod,
        transactionPhoto,
        isDelivered,
        notDeliveredReason,
        entryDate,
        createdAt,
      ];
}