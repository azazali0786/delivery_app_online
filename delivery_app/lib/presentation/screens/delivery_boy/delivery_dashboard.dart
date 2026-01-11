// lib/presentation/screens/delivery_boy/delivery_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/cubits/auth/auth_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import '../../widgets/common/loading_widget.dart';
import 'customer_list_screen.dart';
import 'add_customer_screen.dart';

class DeliveryDashboard extends StatelessWidget {
  const DeliveryDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DeliveryBoyCubit(context.read<DeliveryBoyRepository>())
            ..loadDashboard(),
      child: const _DeliveryDashboardView(),
    );
  }
}

class _DeliveryDashboardView extends StatelessWidget {
  const _DeliveryDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.error),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<DeliveryBoyCubit>(),
                child: const AddCustomerScreen(),
              ),
            ),
          );

          if (result == true) {
            context.read<DeliveryBoyCubit>().loadDashboard(); // refresh UI
          }
        },
      ),
      body: BlocBuilder<DeliveryBoyCubit, DeliveryBoyState>(
        builder: (context, state) {
          if (state is DeliveryBoyDashboardLoading) {
            return const LoadingWidget(message: 'Loading dashboard...');
          }

          if (state is DeliveryBoyDashboardError) {
            return _buildError(context, state.message);
          }

          if (state is DeliveryBoyDashboardLoaded) {
            return _buildDashboard(context, state.stats);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<DeliveryBoyCubit>().loadDashboard(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> stats) {
    return RefreshIndicator(
      onRefresh: () async => context.read<DeliveryBoyCubit>().loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stock Section
            _StockSection(stats: stats),

            const SizedBox(height: 20),

            // Money Section
            _MoneySection(stats: stats),

            const SizedBox(height: 20),

            // Total Pending
            _TotalPendingCard(
              amount: stats['total_pending'] ?? 0,
              pendingBottles: stats['total_pending_bottles'] ?? 0,
            ),

            const SizedBox(height: 24),

            // View Customers Button
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerListScreen()),
                );
              },
              icon: const Icon(Icons.people_rounded),
              label: const Text('View All Customers'),
            ),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.logout_rounded, color: colorScheme.error, size: 32),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ==================== STOCK SECTION ====================

class _StockSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StockSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Stock",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  stats['period'] == 'evening' ? 'Evening' : 'Morning',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    const SizedBox(width: 120),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '1/2 L',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '1 L',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),

                // Rows
                _buildStockRow(
                  context,
                  'Required',
                  stats['need_half']?.toString() ?? '0',
                  stats['need_one']?.toString() ?? '0',
                  Icons.inventory_rounded,
                ),

                _buildStockRow(
                  context,
                  'Dispatched',
                  stats['stock_half_ltr_bottles']?.toString() ?? '0',
                  stats['stock_one_ltr_bottles']?.toString() ?? '0',
                  Icons.local_shipping_rounded,
                ),

                _buildStockRow(
                  context,
                  'Delivered',
                  stats['assign_half']?.toString() ?? '0',
                  stats['assign_one']?.toString() ?? '0',
                  Icons.check_circle_rounded,
                ),

                _buildStockRow(
                  context,
                  'pending',
                  stats['left_half']?.toString() ?? '0',
                  stats['left_one']?.toString() ?? '0',
                  Icons.hourglass_bottom_rounded,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockRow(
    BuildContext context,
    String label,
    String value1,
    String value2,
    IconData icon, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value1,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value2,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

// ==================== MONEY SECTION ====================

class _MoneySection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _MoneySection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.currency_rupee_rounded,
                color: Colors.green.shade700,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                  "Today's Collections",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  stats['period'] == 'evening' ? 'Evening' : 'Morning',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _CollectionCard(
                label: 'Online',
                amount: stats['today_online'] ?? 0,
                icon: Icons.credit_card_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CollectionCard(
                label: 'Cash',
                amount: stats['today_cash'] ?? 0,
                icon: Icons.payments_rounded,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CollectionCard(
                label: 'Pending',
                amount: stats['today_pending'] ?? 0,
                icon: Icons.schedule_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CollectionCard(
                label: 'Bottles',
                bottles: stats['today_collected_bottles'] ?? 0,
                icon: Icons.local_drink_rounded,
                color: Colors.purple,
                isBottleCard: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final String label;
  final dynamic amount;
  final int? bottles;
  final IconData icon;
  final Color color;
  final bool isBottleCard;

  const _CollectionCard({
    required this.label,
    required this.icon,
    required this.color,
    this.amount,
    this.bottles,
    this.isBottleCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final int parsedAmount =
        double.tryParse(amount?.toString() ?? '0')?.toInt() ?? 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                if (!isBottleCard)
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                if (isBottleCard) ...[
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isBottleCard ? '${bottles ?? 0}' : '₹$parsedAmount',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TOTAL PENDING CARD ====================

class _TotalPendingCard extends StatelessWidget {
  final dynamic amount;
  final int pendingBottles;

  const _TotalPendingCard({
    Key? key,
    required this.amount,
    required this.pendingBottles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final int pendingAmount = double.tryParse(amount.toString())?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.errorContainer,
            colorScheme.errorContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: colorScheme.error,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pending',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All outstanding payments',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Amount + Bottles
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$pendingAmount',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$pendingBottles ${pendingBottles == 1 ? "Bottle" : "Bottles"}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
