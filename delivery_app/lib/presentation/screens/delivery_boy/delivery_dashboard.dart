import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
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

          // ---------------- Today Stock ----------------
          const Text(
            "Today's Stock",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SizedBox(width: 140, child: Text("")),
                    Expanded(
                      child: Center(
                        child: Text("1/2 L", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text("1 L", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Need Row
                _stockRow(
                  title: "Need (bottle)",
                  half: stats["need_half"].toString(),
                  one: stats["need_one"].toString(),
                ),

                _stockRow(
                  title: "Assign (stock)",
                  half: stats['stock_half_ltr_bottles'].toString(),
                  one: stats['stock_one_ltr_bottles'].toString(),
                ),

                // Assign Row
                _stockRow(
                  title: "Assign (bottle)",
                  half: stats["assign_half"].toString(),
                  one: stats["assign_one"].toString(),
                ),

                // Left in market Row
                _stockRow(
                  title: "Left in market",
                  half: stats["left_half"].toString(),
                  one: stats["left_one"].toString(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ---------------- Today Money ----------------
          const Text(
            "Today's Money",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: const [
                    Expanded(child: Center(child: Text("Online", style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text("Cash", style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(child: Center(child: Text("Pending", style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
                const SizedBox(height: 10),

                // Values Row
                Row(
                  children: [
                    Expanded(child: Center(child: Text(stats["today_online"].toString()))),
                    Expanded(child: Center(child: Text(stats["today_cash"].toString()))),
                    Expanded(child: Center(child: Text(stats["today_pending"].toString()))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Total Pending Money
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pending Money",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${stats["total_pending"]}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // View Customers Button
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
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
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

Widget _stockRow({
  required String title,
  required String half,
  required String one,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(width: 140, child: Text(title)),
        Expanded(child: Center(child: Text(half))),
        Expanded(child: Center(child: Text(one))),
      ],
    ),
  );
}
