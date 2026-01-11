import 'package:delivery_app/presentation/screens/admin/admin_dashboard_Report.dart';
import 'package:delivery_app/presentation/screens/delivery_boy/add_customer_screen.dart';
import 'package:delivery_app/presentation/widgets/admin/milk_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../business_logic/cubits/auth/auth_cubit.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          "Add Customer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AdminCubit>(),
                child: const AddCustomerScreen(),
              ),
            ),
          );

          if (result == true) {
            context.read<AdminCubit>().loadDashboard(); // refresh UI
          }
        },
      ),

      backgroundColor: const Color(0xfff7f8fc),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Dashboard Report",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardReport()),
              );
            },
            icon: const Icon(Icons.bar_chart, color: AppColors.primary),
          ),
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => context.read<AdminCubit>().loadDashboard(),
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              _showLogoutDialog(context);
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
            return _buildErrorUI(context, state.message);
          }

          if (state is AdminDashboardLoaded) {
            final stats = state.stats;
            final unapproved = stats['pending_approvals'] ?? 0;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminCubit>().loadDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Quick Actions'),
                    const SizedBox(height: 16),

                    _buildQuickActions(context, unapproved),

                    const SizedBox(height: 30),
                    _buildSectionTitle(context, 'Management'),
                    const SizedBox(height: 16),

                    _ManagementCard(
                      title: 'Delivery Boys',
                      icon: Icons.delivery_dining,
                      color: AppColors.primary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeliveryBoyManagement(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ManagementCard(
                      title: 'Customers',
                      icon: Icons.people,
                      color: AppColors.secondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CustomerManagement(unApproved: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ManagementCard(
                      title: 'Areas',
                      icon: Icons.location_on,
                      color: AppColors.info,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AreaManagement(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _ManagementCard(
                      title: 'Reasons',
                      icon: Icons.note,
                      color: Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReasonManagement(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
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

  // ---------------- UI Components ----------------

  Widget _buildSectionTitle(BuildContext context, String title) {
  return Text(
    title,
   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
  );
}


  /// UPDATED — includes Unapproved inside Quick Action tiles
  Widget _buildQuickActions(BuildContext context, int unapproved) {
    return Row(
      children: [
        Expanded(
          child: _RoundedButton(
            color: AppColors.warning,
            icon: Icons.inventory,
            text: "Assign Stock",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssignStockScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: _RoundedButton(
            color: AppColors.info,
            icon: Icons.receipt_long,
            text: "Share Invoice",
            onTap: () => _showInvoiceDialog(context),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: _RoundedButton(
            color: Colors.redAccent,
            icon: Icons.pending_actions,
            text: "Unapproved\n$unapproved",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerManagement(unApproved: true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorUI(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 60, color: AppColors.error),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<AdminCubit>().loadDashboard(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
  }

  void _showInvoiceDialog(BuildContext context) async {
    final adminRepository = context.read<AdminRepository>();
    final customers = await adminRepository.getAllCustomers();

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceShareDialog(
            customers: customers
                .map(
                  (c) => {
                    'id': c.id,
                    'name': c.name,
                    'phone_number': c.phoneNumber,
                    'address': c.address,
                    'area_name': c.areaName,
                    'sub_area_name': c.subAreaName,
                    'permanent_quantity': c.permanentQuantity,
                  },
                )
                .toList(),
          ),
        ),
      );
    }
  }
}

// ---------------- Custom Buttons & Cards ----------------

class _RoundedButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _RoundedButton({
    Key? key,
    required this.color,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.18),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
