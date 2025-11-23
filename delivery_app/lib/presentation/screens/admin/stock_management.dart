import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../widgets/common/loading_widget.dart';

class StockManagement extends StatelessWidget {
  const StockManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(context.read<AdminRepository>())
        ..loadStockEntries(),
      child: const StockManagementView(),
    );
  }
}

class StockManagementView extends StatelessWidget {
  const StockManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AdminCubit>().loadStockEntries(),
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const LoadingWidget(message: 'Loading stock...');
          }

          if (state is StockLoaded) {
            final stocks = state.stocks;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(stock.deliveryBoyName ?? 'Unknown'),
                    subtitle: Text(
                      'Half: ${stock.halfLtrBottles} | One: ${stock.oneLtrBottles}\nDate: ${stock.entryDate}',
                    ),
                    trailing: Text(
                      '${stock.totalMilk.toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}