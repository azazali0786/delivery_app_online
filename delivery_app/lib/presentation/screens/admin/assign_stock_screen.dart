import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../widgets/common/loading_widget.dart';

class AssignStockScreen extends StatelessWidget {
  const AssignStockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<AdminRepository>())..loadStockEntries(),
      child: const AssignStockView(),
    );
  }
}

class AssignStockView extends StatefulWidget {
  const AssignStockView({Key? key}) : super(key: key);

  @override
  State<AssignStockView> createState() => _AssignStockViewState();
}

class _AssignStockViewState extends State<AssignStockView> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _stockEntries = [];
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _itemsPerPage = 30;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreStockEntries();
    }
  }

  void _loadMoreStockEntries() {
    setState(() {
      _isLoadingMore = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage++;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Stock Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            context.read<AdminCubit>().loadStockEntries();
          } else if (state is AdminOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
          if (state is StockLoaded) {
            setState(() {
              _stockEntries = state.stocks;
            });
          }
        },
        builder: (context, state) {
          if (state is StockLoading && _stockEntries.isEmpty) {
            return const Center(
              child: LoadingWidget(message: 'Loading stock entries...'),
            );
          }

          if (state is StockError) {
            return _buildErrorView(
              icon: Icons.inventory,
              message: state.message,
              onRetry: () => context.read<AdminCubit>().loadStockEntries(),
            );
          }

          if (_stockEntries.isEmpty && state is! StockLoading) {
            return _buildEmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminCubit>().loadStockEntries();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _stockEntries.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _stockEntries.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final stock = _stockEntries[index];
                return _buildStockCard(stock, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignStockDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text(
          'Assign Stock',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStockCard(dynamic stock, int index) {
    final raw = stock.entryDate ?? '';
    DateTime dt;

    // If entry_date contains a time portion parse it, otherwise fall back to created_at
    if (raw.contains('T')) {
      dt = DateTime.parse(raw).toLocal();
    } else if ((stock.createdAt ?? '').contains('T')) {
      dt = DateTime.parse(stock.createdAt).toLocal();
    } else {
      // fallback to parsing as date only (midnight)
      dt = DateTime.parse(raw).toLocal();
    }

    // Format: 2025-11-29 8:30 PM
    final formatted = DateFormat('yyyy-MM-dd h:mm a').format(dt);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      radius: 24,
                      child: Text(
                        (stock.deliveryBoyName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.deliveryBoyName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatted,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 20),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editStockEntry(stock);
                        } else if (value == 'delete') {
                          _deleteStockEntry(stock);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildStockInfo(
                        icon: Icons.local_drink,
                        label: 'Half Liter',
                        value: '${stock.halfLtrBottles}',
                        color: Colors.orange,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      _buildStockInfo(
                        icon: Icons.local_drink_outlined,
                        label: 'One Liter',
                        value: '${stock.oneLtrBottles}',
                        color: Colors.blue,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      _buildStockInfo(
                        icon: Icons.recycling,
                        label: 'Collected',
                        value: '${stock.collectedBottles ?? 0}',
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView({
    required IconData icon,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No stock entries found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to assign stock',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showAssignStockDialog() {
    // Load delivery boys
    context.read<AdminCubit>().loadDeliveryBoys();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: const _AssignStockDialog(),
      ),
    );
  }

  void _editStockEntry(dynamic stock) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: _EditStockDialog(stock: stock),
      ),
    );
  }

  void _deleteStockEntry(dynamic stock) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Stock Entry'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this stock entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().deleteStockEntry(stock.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Assign Stock Dialog Widget
class _AssignStockDialog extends StatefulWidget {
  const _AssignStockDialog({Key? key}) : super(key: key);

  @override
  State<_AssignStockDialog> createState() => _AssignStockDialogState();
}

class _AssignStockDialogState extends State<_AssignStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _halfLtrController = TextEditingController();
  final _oneLtrController = TextEditingController();
  final _collectedController = TextEditingController();
  int? _selectedDeliveryBoyId;

  @override
  void dispose() {
    _halfLtrController.dispose();
    _oneLtrController.dispose();
    _collectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_box, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          const Text(
            'Assign Stock',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is DeliveryBoysLoading) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is DeliveryBoysError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AdminCubit>().loadDeliveryBoys(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DeliveryBoysLoaded) {
            // Sort delivery boys by name
            final sortedDeliveryBoys = List.from(state.deliveryBoys)
              ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Delivery Boy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: sortedDeliveryBoys.map((boy) {
                        return DropdownMenuItem<int>(
                          value: boy.id,
                          child: Text(boy.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDeliveryBoyId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a delivery boy';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _halfLtrController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Half Liter Bottles',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.local_drink,
                          color: Colors.orange,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _oneLtrController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'One Liter Bottles',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.local_drink_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _collectedController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Collected Bottles',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.recycling,
                          color: Colors.green,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox(
            height: 200,
            child: Center(child: Text('Loading...')),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<AdminCubit>().createStockEntry({
                'delivery_boy_id': _selectedDeliveryBoyId,
                'half_ltr_bottles': int.parse(_halfLtrController.text),
                'one_ltr_bottles': int.parse(_oneLtrController.text),
                'collected_bottles': int.parse(_collectedController.text),
                // store full datetime so UI can display the exact time
                'entry_date': Helpers.formatDateTimeApi(DateTime.now()),
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

// Edit Stock Dialog Widget
class _EditStockDialog extends StatefulWidget {
  final dynamic stock;

  const _EditStockDialog({Key? key, required this.stock}) : super(key: key);

  @override
  State<_EditStockDialog> createState() => _EditStockDialogState();
}

class _EditStockDialogState extends State<_EditStockDialog> {
  late final TextEditingController _halfLtrEditController;
  late final TextEditingController _oneLtrEditController;
  late final TextEditingController _collectedEditController;

  @override
  void initState() {
    super.initState();
    _halfLtrEditController = TextEditingController(
      text: '${widget.stock.halfLtrBottles}',
    );
    _oneLtrEditController = TextEditingController(
      text: '${widget.stock.oneLtrBottles}',
    );
    _collectedEditController = TextEditingController(
      text: '${widget.stock.collectedBottles ?? 0}',
    );
  }

  @override
  void dispose() {
    _halfLtrEditController.dispose();
    _oneLtrEditController.dispose();
    _collectedEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Stock Entry',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _halfLtrEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Half Liter Bottles',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.local_drink),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _oneLtrEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'One Liter Bottles',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.local_drink_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _collectedEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Collected Bottles',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.recycling),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AdminCubit>().updateStockEntry(widget.stock.id, {
              'half_ltr_bottles': int.parse(_halfLtrEditController.text),
              'one_ltr_bottles': int.parse(_oneLtrEditController.text),
              'collected_bottles': int.parse(_collectedEditController.text),
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
