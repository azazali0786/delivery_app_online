import 'package:delivery_app/presentation/screens/admin/admin_dashboard_Report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/auth/auth_cubit.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'delivery_boy_management.dart';
import 'customer_management.dart';
import 'area_management.dart';
import 'reason_management.dart';
import 'assign_stock_screen.dart';
import 'invoice_share_dialog.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<AdminRepository>())..loadDashboard(),
      child: const AdminDashboardView(),
    );
  }
}

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardReport(),
                ),
              );
            },
            icon: Icon(Icons.dashboard),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminCubit>().loadDashboard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthCubit>().logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const LoadingWidget(message: 'Loading dashboard...');
          }

          if (state is AdminDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminCubit>().loadDashboard();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminDashboardLoaded) {
            final stats = state.stats;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminCubit>().loadDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.90,
                      children: [
                        StatCard(
                          title: 'Delivery Boys',
                          value: stats['total_delivery_boys'].toString(),
                          icon: Icons.person,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Total Customers',
                          value: stats['total_customers'].toString(),
                          icon: Icons.people,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Pending Approvals',
                          value: stats['pending_approvals'].toString(),
                          icon: Icons.pending_actions,
                          color: AppColors.warning,
                        ),
                        StatCard(
                          title: 'Pending Money',
                          value: Helpers.formatCurrency(
                            stats['total_pending_money'],
                          ),
                          icon: Icons.account_balance_wallet,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AssignStockScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.inventory_2),
                            label: const Text('Assign Stock'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.warning,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showInvoiceDialog(context),
                            icon: const Icon(Icons.receipt),
                            label: const Text('Share Invoice'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Management Options
                    const Text(
                      'Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _ManagementCard(
                      title: 'Delivery Boy Management',
                      subtitle: 'Manage delivery boys and assignments',
                      icon: Icons.delivery_dining,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeliveryBoyManagement(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    _ManagementCard(
                      title: 'Customer Management',
                      subtitle: 'View and manage customers',
                      icon: Icons.people,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerManagement(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    _ManagementCard(
                      title: 'Area Management',
                      subtitle: 'Manage areas and sub-areas',
                      icon: Icons.location_on,
                      color: AppColors.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AreaManagement(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    _ManagementCard(
                      title: 'Reason Management',
                      subtitle: 'Manage delivery reasons',
                      icon: Icons.note,
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReasonManagement(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context) async {
    final adminRepository = context.read<AdminRepository>();
    final customers = await adminRepository.getAllCustomers();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => InvoiceShareDialog(
          customers: customers
              .map((c) => {'id': c.id, 'name': c.name})
              .toList(),
        ),
      );
    }
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
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
              Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
