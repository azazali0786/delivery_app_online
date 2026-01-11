import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/customer_model.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerModel customer;
  final int? overrideLastTimePendingBottles;

  const CustomerInfoCard({
    Key? key,
    required this.customer,
    this.overrideLastTimePendingBottles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _getInitial(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (customer.areaName != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 11,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                customer.subAreaName != null
                                    ? '${customer.areaName} • ${customer.subAreaName}'
                                    : customer.areaName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.water_drop_outlined,
                      label: 'Permanent',
                      value: Helpers.formatQuantity(customer.permanentQuantity),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Pending',
                      value: Helpers.formatCurrency(
                        customer.totalPendingMoney ?? 0,
                      ),
                      isHighlight: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.local_drink_outlined,
                      label: 'Bottles',
                      value:
                          (overrideLastTimePendingBottles ??
                                  customer.lastTimePendingBottles ??
                                  0)
                              .toString(),
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

  String _getInitial() {
    if (customer.shift != null) {
      final shift = customer.shift!.toLowerCase();
      if (shift.contains('m')) return 'M';
      if (shift.contains('e')) return 'E';
    }
    return customer.name[0].toUpperCase();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isHighlight
              ? Colors.amber.shade300
              : Colors.white.withOpacity(0.9),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.amber.shade200 : Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
