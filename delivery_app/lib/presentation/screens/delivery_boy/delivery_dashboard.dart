import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/auth/auth_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/loading_widget.dart';
import 'customer_list_screen.dart';
import 'add_customer_screen.dart';

class DeliveryDashboard extends StatelessWidget {
  const DeliveryDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeliveryBoyCubit(context.read<DeliveryBoyRepository>())
            ..loadDashboard(),
      child: const DeliveryDashboardView(),
    );
  }
}

class DeliveryDashboardView extends StatelessWidget {
  const DeliveryDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DeliveryBoyCubit>().loadDashboard(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCustomerScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<DeliveryBoyCubit, DeliveryBoyState>(
        builder: (context, state) {
          if (state is DeliveryBoyDashboardLoading) {
            return const LoadingWidget(message: 'Loading dashboard...');
          }

          if (state is DeliveryBoyDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DeliveryBoyCubit>().loadDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DeliveryBoyDashboardLoaded) {
            final stats = state.stats;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DeliveryBoyCubit>().loadDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Stock',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        StatCard(
                          title: 'Half Liter Bottles',
                          value: stats['half_ltr_bottles'].toString(),
                          icon: Icons.local_drink,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'One Liter Bottles',
                          value: stats['one_ltr_bottles'].toString(),
                          icon: Icons.local_drink,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Total Milk',
                          value: '${stats['total_milk_for_delivery']} L',
                          icon: Icons.opacity,
                          color: AppColors.info,
                        ),
                        StatCard(
                          title: 'Left Bottles',
                          value: stats['total_left_bottles'].toString(),
                          icon: Icons.inventory,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Today\'s Summary',
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
                          child: StatCard(
                            title: 'Collected Money',
                            value: Helpers.formatCurrency(
                              stats['today_collected_money'],
                            ),
                            icon: Icons.attach_money,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Pending Delivery',
                            value: '${stats['today_pending_delivery']} L',
                            icon: Icons.pending,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerListScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('View Customers'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
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
}