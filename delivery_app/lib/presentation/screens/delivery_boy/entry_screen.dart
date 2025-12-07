import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/delivery_boy/customer_info_card.dart';
import '../../widgets/delivery_boy/entry_history_card.dart';

class EntryScreen extends StatelessWidget {
  final CustomerModel customer;

  const EntryScreen({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeliveryBoyCubit(context.read<DeliveryBoyRepository>()),
      child: EntryScreenView(customer: customer),
    );
  }
}

class EntryScreenView extends StatefulWidget {
  final CustomerModel customer;

  const EntryScreenView({Key? key, required this.customer}) : super(key: key);

  @override
  State<EntryScreenView> createState() => _EntryScreenViewState();
}

class _EntryScreenViewState extends State<EntryScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _collectedMoneyController = TextEditingController();
  final _pendingBottlesController = TextEditingController();
  final _rateController = TextEditingController();

  String _paymentMethod = 'cash';
  List<Map<String, dynamic>> _reasons = [];
  List<dynamic> _entries = [];
  bool _isLoadingReasons = true;
  bool _isLoadingEntries = true;
  bool _isFormExpanded = false;

  @override
  void initState() {
    super.initState();
    final qty = widget.customer.permanentQuantity;
_quantityController.text = qty % 1 == 0
    ? qty.toInt().toString()
    : qty.toString();

    _rateController.text = "80"; // Default rate
    _loadReasons();
    _loadEntries();
  }

  Future<void> _loadReasons() async {
    try {
      final reasons = await context.read<DeliveryBoyRepository>().getReasons();
      setState(() {
        _reasons = reasons;
        _isLoadingReasons = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingReasons = false;
      });
    }
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await context
          .read<DeliveryBoyRepository>()
          .getCustomerEntries(widget.customer.id);
      setState(() {
        _entries = entries;
        _isLoadingEntries = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEntries = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _collectedMoneyController.dispose();
    _pendingBottlesController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    String qText = _quantityController.text.trim().replaceAll(',', '.');
    String rateText = _rateController.text.trim().replaceAll(',', '.');
    String collectedText = _collectedMoneyController.text.trim().replaceAll(',', '.');
    String pendingText = _pendingBottlesController.text.trim();

    

    final milkQty = double.tryParse(qText) ?? 0.0;
    final rate = double.tryParse(rateText) ?? 0.0;
    final collected = double.tryParse(collectedText) ?? 0.0;
    final pendingBottles = int.tryParse(pendingText) ?? 0;

    final data = {
      'customer_id': widget.customer.id,
      'milk_quantity': milkQty,
      'collected_money': collected,
      'pending_bottles': pendingBottles,
      'rate': rate,
      'payment_method': _paymentMethod,
      'entry_date': Helpers.formatDateApi(DateTime.now()),
    };

    context.read<DeliveryBoyCubit>().createEntry(data);

    setState(() {
      _isFormExpanded = false;
    });
  }

  void _showNotDeliveredDialog() {
    if (_reasons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reasons available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String? selectedReason = _reasons[0]['reason'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        title: const Text(
          'Mark as Not Delivered',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select reason:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedReason,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    items: _reasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason['reason'],
                        child: Text(
                          reason['reason'],
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedReason != null) {
                final data = {
                  'customer_id': widget.customer.id,
                  'milk_quantity': 0,
                  'collected_money': 0,
                  'pending_bottles': 0,
                  'rate': 0,
                  'payment_method': 'cash',
                  'is_delivered': false,
                  'not_delivered_reason': selectedReason,
                  'entry_date': Helpers.formatDateApi(DateTime.now()),
                };
                context.read<DeliveryBoyCubit>().createEntry(data);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Entry Details'),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<DeliveryBoyCubit, DeliveryBoyState>(
        listener: (context, state) {
          if (state is DeliveryBoyOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is DeliveryBoyOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DeliveryBoyOperationLoading;

          return SingleChildScrollView(
            child: Column(
              children: [
                CustomerInfoCard(customer: widget.customer),
                
                // Entry Form Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isFormExpanded = !_isFormExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(
                                  Icons.edit_note,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Entry Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _isFormExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_isFormExpanded) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Quantity (L)',
                                        controller: _quantityController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) {
                                          final s = val?.trim().replaceAll(',', '.') ?? '';
                                          if (s.isEmpty) return 'Required';
                                          final v = double.tryParse(s);
                                          if (v == null) return 'Enter valid number';
                                          if (v <= 0) return 'Must be greater than 0';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Rate (₹/L)',
                                        controller: _rateController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) {
                                          final s = val?.trim().replaceAll(',', '.') ?? '';
                                          if (s.isEmpty) return 'Required';
                                          final v = double.tryParse(s);
                                          if (v == null) return 'Enter valid number';
                                          if (v <= 0) return 'Must be greater than 0';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Collected (₹)',
                                        controller: _collectedMoneyController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) {
                                          final s = val?.trim().replaceAll(',', '.') ?? '';
                                          if (s.isEmpty) return 'Required';
                                          final v = double.tryParse(s);
                                          if (v == null) return 'Enter valid number';
                                          if (v < 0) return 'Cannot be negative';
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Bottles Left',
                                        controller: _pendingBottlesController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) {
                                          final s = val?.trim() ?? '';
                                          if (s.isEmpty) return 'Required';
                                          final v = int.tryParse(s);
                                          if (v == null) return 'Enter whole number';
                                          if (v < 0) return 'Cannot be negative';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                CustomDropdown<String>(
                                  label: 'Payment Method',
                                  value: _paymentMethod,
                                  items: const [
                                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                    DropdownMenuItem(value: 'online', child: Text('Online')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _paymentMethod = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton.icon(
                                          onPressed: _handleSubmit,
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            textStyle: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          icon: const Icon(Icons.check_circle_outline, size: 16),
                                          label: const Text("Submit"),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: OutlinedButton.icon(
                                          onPressed: _isLoadingReasons ? null : _showNotDeliveredDialog,
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            side: BorderSide(color: AppColors.error),
                                            foregroundColor: AppColors.error,
                                            textStyle: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          icon: const Icon(Icons.cancel_outlined, size: 16),
                                          label: const Text("Not Delivered"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Entry History Section - FIXED CUMULATIVE CALCULATION
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.history, color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Entry History',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_isLoadingEntries)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_entries.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 40,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'No entries yet',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _entries.length,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];

                            // FIXED: Calculate cumulative pending correctly
                            // Start from the beginning and add up to current entry
                            double cumulativePending = 0;
                            for (int i = _entries.length - 1; i >= index; i--) {
                              final e = _entries[i];
                              final isDelivered = (e is Map
                                  ? e['is_delivered'] ?? true
                                  : e.isDelivered ?? true);

                              if (isDelivered) {
                                final milkQty = (e is Map
                                    ? e['milk_quantity'] ?? 0
                                    : e.milkQuantity ?? 0);
                                final rate = (e is Map
                                    ? e['rate']?.toDouble() ?? 0
                                    : e.rate?.toDouble() ?? 0);
                                final collected = (e is Map
                                    ? e['collected_money']?.toDouble() ?? 0
                                    : e.collectedMoney?.toDouble() ?? 0);

                                // Add today's pending to the running total
                                cumulativePending += (milkQty * rate - collected);
                              }
                            }

                            return EntryHistoryCard(
                              entry: entry,
                              cumulativePending: cumulativePending,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}