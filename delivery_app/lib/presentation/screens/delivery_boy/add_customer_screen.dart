import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/validators.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../../data/repositories/delivery_boy_repository.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DeliveryBoyCubit(context.read<DeliveryBoyRepository>()),
      child: const AddCustomerScreenView(),
    );
  }
}

class AddCustomerScreenView extends StatefulWidget {
  const AddCustomerScreenView({Key? key}) : super(key: key);

  @override
  State<AddCustomerScreenView> createState() => _AddCustomerScreenViewState();
}

class _AddCustomerScreenViewState extends State<AddCustomerScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationService = LocationService();

  double? _latitude;
  double? _longitude;
  String? _locationLink;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationLink = _locationService.getLocationLink(
            position.latitude,
            position.longitude,
          );
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location fetched successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get location. Please enable location services.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim(),
        'permanent_quantity': double.parse(_quantityController.text),
        'latitude': _latitude,
        'longitude': _longitude,
        'location_link': _locationLink,
      };

      context.read<DeliveryBoyCubit>().createCustomer(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
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
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Customer Name',
                    controller: _nameController,
                    validator: (value) =>
                        Validators.validateRequired(value, 'Customer name'),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'WhatsApp Number (Optional)',
                    controller: _whatsappController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Address',
                    controller: _addressController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Permanent Quantity (Liters)',
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.validatePositiveNumber(
                      value,
                      'Permanent quantity',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_locationLink != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location captured',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  CustomButton(
                    text: _isLoadingLocation
                        ? 'Fetching Location...'
                        : 'Auto Fetch Current Location',
                    onPressed: _isLoadingLocation
                        ? null
                        : () => _getCurrentLocation(),
                    isLoading: _isLoadingLocation,
                    icon: Icons.my_location,
                    isOutlined: true,
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Add Customer',
                    onPressed: _handleSubmit,
                    isLoading: isLoading,
                    icon: Icons.person_add,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info),
                        SizedBox(height: 8),
                        Text(
                          'This customer will be added to pending approvals. Admin will approve and assign sub-area.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
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
