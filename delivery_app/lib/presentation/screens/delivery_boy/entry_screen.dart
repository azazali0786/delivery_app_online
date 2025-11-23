import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/custom_dropdown.dart';

class EntryScreen extends StatelessWidget {
  final CustomerModel customer;

  const EntryScreen({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryBoyCubit(context.read<DeliveryBoyRepository>()),
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
  bool _isLoadingReasons = true;

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.customer.permanentQuantity.toString();
    _loadReasons();
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

  @override
  void dispose() {
    _quantityController.dispose();
    _collectedMoneyController.dispose();
    _pendingBottlesController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'customer_id': widget.customer.id,
        'milk_quantity': double.parse(_quantityController.text),
        'collected_money': double.parse(_collectedMoneyController.text),
        'pending_bottles': int.parse(_pendingBottlesController.text),
        'rate': double.parse(_rateController.text),
        'payment_method': _paymentMethod,
        'entry_date': Helpers.formatDateApi(DateTime.now()),
      };

      context.read<DeliveryBoyCubit>().createEntry(data);
    }
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
        title: const Text('Mark as Not Delivered'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select reason:'),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedReason,
                  isExpanded: true,
                  items: _reasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason['reason'],
                      child: Text(reason['reason']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedReason != null) {
                // Create entry with is_delivered = false
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan QR Code for Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              QrImageView(
                data: 'upi://pay?pa=example@upi&pn=MilkDelivery&cu=INR',
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 24),
              const Text(
                'UPI ID: example@upi',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendTransactionPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      // Send to WhatsApp
      await Helpers.openWhatsApp(
        '918800646224',
        'Transaction proof for ${widget.customer.name}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry'),
      ),
      body: BlocConsumer<DeliveryBoyCubit, DeliveryBoyState>(
        listener: (context, state) {
          if (state is DeliveryBoyOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is DeliveryBoyOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is DeliveryBoyOperationLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Customer Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  widget.customer.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.customer.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.customer.phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoTile(
                                  label: 'Permanent Qty',
                                  value: Helpers.formatQuantity(
                                    widget.customer.permanentQuantity,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _InfoTile(
                                  label: 'Pending Money',
                                  value: Helpers.formatCurrency(
                                    widget.customer.totalPendingMoney ?? 0,
                                  ),
                                  valueColor: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoTile(
                                  label: 'Pending Bottles',
                                  value: widget.customer.lastTimePendingBottles
                                          ?.toString() ??
                                      '0',
                                ),
                              ),
                              Expanded(
                                child: _InfoTile(
                                  label: 'Area',
                                  value: widget.customer.subAreaName ?? 'N/A',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      Helpers.makePhoneCall(widget.customer.phoneNumber),
                                  icon: const Icon(Icons.phone, size: 18),
                                  label: const Text('Call'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Helpers.openMap(
                                    widget.customer.locationLink,
                                    widget.customer.latitude,
                                    widget.customer.longitude,
                                  ),
                                  icon: const Icon(Icons.map, size: 18),
                                  label: const Text('Location'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Entry Form
                  const Text(
                    'Entry Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Milk Quantity (Liters)',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.validatePositiveNumber(value, 'Milk quantity'),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Rate per Liter (₹)',
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.validatePositiveNumber(value, 'Rate'),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Collected Money (₹)',
                    controller: _collectedMoneyController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.validatePositiveNumber(value, 'Collected money'),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Pending Bottles',
                    controller: _pendingBottlesController,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        Validators.validateNumber(value, 'Pending bottles'),
                  ),
                  const SizedBox(height: 16),

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

                  if (_paymentMethod == 'online') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showQRCode,
                            icon: const Icon(Icons.qr_code),
                            label: const Text('Show QR'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _sendTransactionPhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Send Photo'),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Submit Entry',
                    onPressed: _handleSubmit,
                    isLoading: isLoading,
                    icon: Icons.check,
                  ),
                  const SizedBox(height: 12),

                  CustomButton(
                    text: 'Not Delivered',
                    onPressed: _isLoadingReasons ? null : _showNotDeliveredDialog,
                    isOutlined: true,
                    color: AppColors.error,
                    icon: Icons.close,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}