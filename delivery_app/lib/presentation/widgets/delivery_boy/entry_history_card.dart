import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class EntryHistoryCard extends StatelessWidget {
  final dynamic entry;
  final double cumulativePending;

  const EntryHistoryCard({
    Key? key,
    required this.entry,
    required this.cumulativePending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract entry data
    final rawDate = (entry is Map)
        ? (entry['entry_date'] ?? 'N/A')
        : (entry.entryDate ?? 'N/A');

    String entryDate;
    try {
      entryDate = DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(rawDate.toString()).toLocal());
    } catch (e) {
      entryDate = rawDate.toString().split('T').first;
    }

    final createdAt = (entry is Map)
        ? entry['created_at'] ?? ''
        : (entry.createdAt ?? '');

    final timeWithAmPm = _formatTimeWithAmPm(createdAt);

    final milkQty = (entry is Map
        ? entry['milk_quantity'] ?? 0
        : entry.milkQuantity ?? 0);

    final rate = (entry is Map
        ? entry['rate']?.toDouble() ?? 0
        : entry.rate?.toDouble() ?? 0);

    final collected = (entry is Map
        ? entry['collected_money']?.toDouble() ?? 0
        : entry.collectedMoney?.toDouble() ?? 0);

    final pendingBottles = (entry is Map
        ? entry['pending_bottles'] ?? 0
        : entry.pendingBottles ?? 0);

    final isDelivered = (entry is Map
        ? entry['is_delivered'] ?? true
        : entry.isDelivered ?? true);

    final paymentMethod = (entry is Map
        ? entry['payment_method'] ?? 'cash'
        : entry.paymentMethod ?? 'cash');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDelivered
              ? Colors.transparent
              : AppColors.error.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Header with date and status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDelivered
                      ? [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.primary.withOpacity(0.03),
                        ]
                      : [
                          AppColors.error.withOpacity(0.08),
                          AppColors.error.withOpacity(0.03),
                        ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isDelivered ? Icons.check_circle : Icons.cancel,
                      color: isDelivered ? AppColors.primary : AppColors.error,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entryDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          timeWithAmPm,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isDelivered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Not Delivered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Entry details
            if (isDelivered)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.water_drop,
                            iconColor: Colors.blue,
                            label: 'Milk Qty',
                            value: Helpers.formatQuantity(milkQty),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.currency_rupee,
                            iconColor: Colors.green,
                            label: 'Rate',
                            value: Helpers.formatCurrency(rate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.account_balance_wallet,
                            iconColor: Colors.orange,
                            label: 'Collected',
                            value: Helpers.formatCurrency(collected),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.local_drink,
                            iconColor: Colors.purple,
                            label: 'Bottles',
                            value: pendingBottles.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: paymentMethod == 'cash'
                                ? Icons.payments
                                : Icons.phone_android,
                            iconColor: Colors.teal,
                            label: 'Payment',
                            value: paymentMethod == 'cash' ? 'Cash' : 'Online',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cumulativePending > 0
                                  ? AppColors.error.withOpacity(0.08)
                                  : Colors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: cumulativePending > 0
                                    ? AppColors.error.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 10,
                                      color: cumulativePending > 0
                                          ? AppColors.error
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Total Pending',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Helpers.formatCurrency(cumulativePending),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: cumulativePending > 0
                                        ? AppColors.error
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.error.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (entry is Map
                                ? entry['not_delivered_reason']
                                : entry.notDeliveredReason) ??
                            'No reason provided',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeWithAmPm(String createdAt) {
    if (createdAt.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final formatter = DateFormat('hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      // Fallback to extracting time
      if (createdAt.contains('T') && createdAt.split('T').length > 1) {
        final timePart = createdAt.split('T')[1];
        if (timePart.length >= 5) {
          final hourMin = timePart.substring(0, 5);
          final parts = hourMin.split(':');
          if (parts.length == 2) {
            int hour = int.tryParse(parts[0]) ?? 0;
            final minute = parts[1];
            final period = hour >= 12 ? 'PM' : 'AM';
            hour = hour % 12;
            if (hour == 0) hour = 12;
            return '$hour:$minute $period';
          }
        }
      }
      return 'N/A';
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
