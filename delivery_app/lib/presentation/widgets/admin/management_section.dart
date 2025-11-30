// lib/presentation/widgets/admin/management_section.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ManagementSection extends StatelessWidget {
  final VoidCallback onDeliveryBoyManagement;
  final VoidCallback onCustomerManagement;
  final VoidCallback onAreaManagement;
  final VoidCallback onReasonManagement;

  const ManagementSection({
    Key? key,
    required this.onDeliveryBoyManagement,
    required this.onCustomerManagement,
    required this.onAreaManagement,
    required this.onReasonManagement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _ManagementCard(
            title: 'Delivery Boy Management',
            subtitle: 'Manage delivery boys and assignments',
            icon: Icons.delivery_dining,
            color: AppColors.primary,
            onTap: onDeliveryBoyManagement,
          ),
          const SizedBox(height: 12),
          _ManagementCard(
            title: 'Customer Management',
            subtitle: 'View and manage customers',
            icon: Icons.people,
            color: AppColors.secondary,
            onTap: onCustomerManagement,
          ),
          const SizedBox(height: 12),
          _ManagementCard(
            title: 'Area Management',
            subtitle: 'Manage areas and sub-areas',
            icon: Icons.location_on,
            color: AppColors.info,
            onTap: onAreaManagement,
          ),
          const SizedBox(height: 12),
          _ManagementCard(
            title: 'Reason Management',
            subtitle: 'Manage delivery reasons',
            icon: Icons.note_alt,
            color: AppColors.warning,
            onTap: onReasonManagement,
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.02),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}