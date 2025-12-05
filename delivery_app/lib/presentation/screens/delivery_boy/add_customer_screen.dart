import 'package:delivery_app/business_logic/cubits/admin/admin_cubit.dart';
import 'package:delivery_app/business_logic/cubits/admin/admin_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/validators.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_cubit.dart';
import '../../../business_logic/cubits/delivery_boy/delivery_boy_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AddCustomerScreenView();
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
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Check if AdminCubit is available
    try {
      context.read<AdminCubit>();
      _isAdmin = true;
    } catch (_) {
      _isAdmin = false;
    }
  }

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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Location captured successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to get location. Please enable location services.',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'whatsapp_number': _whatsappController.text.trim(),
        'permanent_quantity': double.tryParse(_quantityController.text.trim()) ?? 0.0,
        'latitude': _latitude,
        'longitude': _longitude,
        'location_link': _locationLink,
      };

      if (_isAdmin) {
        context.read<AdminCubit>().createCustomer(data);
      } else {
        context.read<DeliveryBoyCubit>().createCustomer(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build different listeners based on user role
    if (_isAdmin) {
      return _buildAdminView();
    } else {
      return _buildDeliveryBoyView();
    }
  }

  Widget _buildAdminView() {
    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (state is AdminOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          final isLoading = state is AdminOperationLoading;
          return _buildScaffold(isLoading);
        },
      ),
    );
  }

  Widget _buildDeliveryBoyView() {
    return BlocListener<DeliveryBoyCubit, DeliveryBoyState>(
      listener: (context, state) {
        if (state is DeliveryBoyOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else if (state is DeliveryBoyOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<DeliveryBoyCubit, DeliveryBoyState>(
        builder: (context, state) {
          final isLoading = state is DeliveryBoyOperationLoading;
          return _buildScaffold(isLoading);
        },
      ),
    );
  }

  Widget _buildScaffold(bool isLoading) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Add Customer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              // Name Field
              CustomTextField(
                label: 'Customer Name *',
                controller: _nameController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Customer name'),
              ),
              const SizedBox(height: 12),

              // Phone and WhatsApp Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Phone *',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: Validators.validatePhone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'WhatsApp',
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity and Address Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'Quantity (L) *',
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          Validators.validatePositiveNumber(
                            value,
                            'Quantity',
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      label: 'Address *',
                      controller: _addressController,
                      maxLines: 1,
                      validator: (value) =>
                          Validators.validateRequired(value, 'Address'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Location Section (Compact)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _latitude != null
                      ? AppColors.success.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _latitude != null
                        ? AppColors.success
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _latitude != null
                          ? Icons.location_on
                          : Icons.location_off,
                      color: _latitude != null
                          ? AppColors.success
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'Optional',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_latitude != null)
                            Text(
                              '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: _latitude != null
                            ? AppColors.success
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              _latitude != null
                                  ? Icons.refresh
                                  : Icons.my_location,
                              size: 16,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Info + Submit Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.info.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pending approval',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Add Customer',
                      onPressed: isLoading ? null : _handleSubmit,
                      isLoading: isLoading,
                      icon: Icons.person_add,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}