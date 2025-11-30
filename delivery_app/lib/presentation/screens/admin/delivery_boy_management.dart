import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../business_logic/cubits/admin/admin_cubit.dart';
import '../../../business_logic/cubits/admin/admin_state.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/delivery_boy_model.dart';
import '../../../data/models/area_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class DeliveryBoyManagement extends StatelessWidget {
  const DeliveryBoyManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminCubit(context.read<AdminRepository>())..loadDeliveryBoys(),
      child: const DeliveryBoyManagementView(),
    );
  }
}

class DeliveryBoyManagementView extends StatefulWidget {
  const DeliveryBoyManagementView({Key? key}) : super(key: key);

  @override
  State<DeliveryBoyManagementView> createState() =>
      _DeliveryBoyManagementViewState();
}

class _DeliveryBoyManagementViewState extends State<DeliveryBoyManagementView> {
  final _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDeliveryBoyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: _AddDeliveryBoyDialog(),
      ),
    );
  }

  void _showEditDeliveryBoyDialog(DeliveryBoyModel deliveryBoy) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: _EditDeliveryBoyDialog(deliveryBoy: deliveryBoy),
      ),
    );
  }

  void _showAssignSubAreasDialog(DeliveryBoyModel deliveryBoy) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: _AssignSubAreasDialog(deliveryBoy: deliveryBoy),
      ),
    );
  }

  void _showDeliveryBoyStatsDialog(DeliveryBoyModel deliveryBoy) {
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AdminCubit>(),
        child: _DeliveryBoyStatsDialog(deliveryBoy: deliveryBoy),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Boy Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminCubit>().loadDeliveryBoys();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeliveryBoyDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Delivery Boy'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is AdminOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DeliveryBoysLoading) {
            return const LoadingWidget(message: 'Loading delivery boys...');
          }

          if (state is DeliveryBoysError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminCubit>().loadDeliveryBoys();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DeliveryBoysLoaded) {
            final deliveryBoys = state.deliveryBoys;

            if (deliveryBoys.isEmpty) {
              return const EmptyStateWidget(
                message: 'No delivery boys found.\nTap + to add a new one.',
                icon: Icons.person_off,
              );
            }

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) => {},
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or address...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = null;
                                });
                                context.read<AdminCubit>().loadDeliveryBoys();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _searchQuery = value.isNotEmpty ? value : null;
                      });
                      context.read<AdminCubit>().loadDeliveryBoys(
                        search: _searchQuery,
                      );
                    },
                  ),
                ),

                // Delivery Boys List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminCubit>().loadDeliveryBoys(
                        search: _searchQuery,
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: deliveryBoys.length,
                      itemBuilder: (context, index) {
                        final deliveryBoy = deliveryBoys[index];
                        return _DeliveryBoyCard(
                          deliveryBoy: deliveryBoy,
                          onEdit: () => _showEditDeliveryBoyDialog(deliveryBoy),
                          onAssignSubAreas: () =>
                              _showAssignSubAreasDialog(deliveryBoy),
                          onToggleActive: () {
                            context.read<AdminCubit>().toggleDeliveryBoyActive(
                              deliveryBoy.id,
                            );
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Delivery Boy'),
                                content: Text(
                                  'Are you sure you want to delete ${deliveryBoy.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context
                                          .read<AdminCubit>()
                                          .deleteDeliveryBoy(deliveryBoy.id);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onViewStats: () =>
                              _showDeliveryBoyStatsDialog(deliveryBoy),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DeliveryBoyCard extends StatelessWidget {
  final DeliveryBoyModel deliveryBoy;
  final VoidCallback onEdit;
  final VoidCallback onAssignSubAreas;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onViewStats;

  const _DeliveryBoyCard({
    Key? key,
    required this.deliveryBoy,
    required this.onEdit,
    required this.onAssignSubAreas,
    required this.onToggleActive,
    required this.onDelete,
    required this.onViewStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onDelete,
      onTap: onViewStats,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: deliveryBoy.isActive
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.textTertiary.withOpacity(0.1),
                    child: Text(
                      deliveryBoy.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: deliveryBoy.isActive
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deliveryBoy.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: deliveryBoy.isActive
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                deliveryBoy.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: deliveryBoy.isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deliveryBoy.email,
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
              if (deliveryBoy.subAreas != null &&
                  deliveryBoy.subAreas!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: deliveryBoy.subAreas!.map((subArea) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${subArea.areaName} - ${subArea.subAreaName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: onAssignSubAreas,
                    icon: const Icon(Icons.location_city, size: 18),
                    label: const Text('Assign'),
                  ),
                  TextButton.icon(
                    onPressed: onToggleActive,
                    icon: Icon(
                      deliveryBoy.isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(
                      deliveryBoy.isActive ? 'Intivate' : 'Activate',
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

class _AddDeliveryBoyDialog extends StatefulWidget {
  @override
  State<_AddDeliveryBoyDialog> createState() => _AddDeliveryBoyDialogState();
}

class _AddDeliveryBoyDialogState extends State<_AddDeliveryBoyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _adharController = TextEditingController();
  final _licenceController = TextEditingController();
  final _panController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _adharController.dispose();
    _licenceController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'address': _addressController.text.trim(),
        'phone_number1': _phone1Controller.text.trim(),
        'phone_number2': _phone2Controller.text.trim(),
        'adhar_number': _adharController.text.trim(),
        'driving_licence_number': _licenceController.text.trim(),
        'pan_number': _panController.text.trim(),
      };

      context.read<AdminCubit>().createDeliveryBoy(data);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Delivery Boy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Name'),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number 1',
                  controller: _phone1Controller,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number 2 (Optional)',
                  controller: _phone2Controller,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Adhar Number',
                  controller: _adharController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Driving Licence Number',
                  controller: _licenceController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'PAN Number',
                  controller: _panController,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Add',
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditDeliveryBoyDialog extends StatefulWidget {
  final DeliveryBoyModel deliveryBoy;

  const _EditDeliveryBoyDialog({Key? key, required this.deliveryBoy})
    : super(key: key);

  @override
  State<_EditDeliveryBoyDialog> createState() => _EditDeliveryBoyDialogState();
}

class _EditDeliveryBoyDialogState extends State<_EditDeliveryBoyDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _addressController;
  late final TextEditingController _phone1Controller;
  late final TextEditingController _phone2Controller;
  late final TextEditingController _adharController;
  late final TextEditingController _licenceController;
  late final TextEditingController _panController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.deliveryBoy.name);
    _emailController = TextEditingController(text: widget.deliveryBoy.email);
    _passwordController = TextEditingController(); // password not shown
    _addressController = TextEditingController(
      text: widget.deliveryBoy.address ?? '',
    );
    _phone1Controller = TextEditingController(
      text: widget.deliveryBoy.phoneNumber1 ?? '',
    );
    _phone2Controller = TextEditingController(
      text: widget.deliveryBoy.phoneNumber2 ?? '',
    );
    _adharController = TextEditingController(
      text: widget.deliveryBoy.adharNumber ?? '',
    );
    _licenceController = TextEditingController(
      text: widget.deliveryBoy.drivingLicenceNumber ?? '',
    );
    _panController = TextEditingController(
      text: widget.deliveryBoy.panNumber ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _adharController.dispose();
    _licenceController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(), // optional
        'address': _addressController.text.trim(),
        'phone_number1': _phone1Controller.text.trim(),
        'phone_number2': _phone2Controller.text.trim(),
        'adhar_number': _adharController.text.trim(),
        'driving_licence_number': _licenceController.text.trim(),
        'pan_number': _panController.text.trim(),
      };

      context.read<AdminCubit>().updateDeliveryBoy(widget.deliveryBoy.id, data);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Delivery Boy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Name'),
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Email',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Phone Number 1',
                  controller: _phone1Controller,
                  validator: Validators.validatePhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Phone Number 2 (Optional)',
                  controller: _phone2Controller,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Adhar Number',
                  controller: _adharController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Driving Licence Number',
                  controller: _licenceController,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'PAN Number',
                  controller: _panController,
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Update',
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignSubAreasDialog extends StatefulWidget {
  final DeliveryBoyModel deliveryBoy;

  const _AssignSubAreasDialog({Key? key, required this.deliveryBoy})
    : super(key: key);

  @override
  State<_AssignSubAreasDialog> createState() => _AssignSubAreasDialogState();
}

class _AssignSubAreasDialogState extends State<_AssignSubAreasDialog> {
  List<AreaModel> _areas = [];
  Set<int> _selectedSubAreaIds = {};
  Set<int> _expandedAreaIds = {}; // Track expanded areas
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    try {
      final areas = await context.read<AdminRepository>().getAllAreas();
      setState(() {
        _areas = areas;
        _isLoading = false;
      });

      // Pre-select assigned sub-areas
      if (widget.deliveryBoy.subAreas != null) {
        setState(() {
          _selectedSubAreaIds = widget.deliveryBoy.subAreas!
              .map((sa) => sa.subAreaId)
              .toSet();
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleSubmit() {
    context.read<AdminCubit>().assignSubAreas(
      widget.deliveryBoy.id,
      _selectedSubAreaIds.toList(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: screenWidth * 0.75, // smaller width
        height: screenHeight * 0.60, // smaller height
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Sub-Areas to ${widget.deliveryBoy.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select sub-areas to assign',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // BODY SCROLLABLE
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _areas.isEmpty
                  ? const Center(child: Text('No areas available'))
                  : Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _areas.map((area) {
                            final isExpanded = _expandedAreaIds.contains(
                              area.id,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedAreaIds.remove(area.id);
                                      } else {
                                        _expandedAreaIds.add(area.id);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        area.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 4),

                                if (isExpanded && area.subAreas != null) ...[
                                  ...area.subAreas!.map((subArea) {
                                    final isSelected = _selectedSubAreaIds
                                        .contains(subArea.id);

                                    return CheckboxListTile(
                                      title: Text(subArea.name),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedSubAreaIds.add(subArea.id);
                                          } else {
                                            _selectedSubAreaIds.remove(
                                              subArea.id,
                                            );
                                          }
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                      contentPadding: EdgeInsets.zero,
                                    );
                                  }).toList(),
                                ],

                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),

            const Divider(height: 1),

            // FOOTER BUTTONS
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Assign',
                      onPressed: _handleSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryBoyStatsDialog extends StatefulWidget {
  final DeliveryBoyModel deliveryBoy;

  const _DeliveryBoyStatsDialog({Key? key, required this.deliveryBoy})
    : super(key: key);

  @override
  State<_DeliveryBoyStatsDialog> createState() =>
      _DeliveryBoyStatsDialogState();
}

class _DeliveryBoyStatsDialogState extends State<_DeliveryBoyStatsDialog> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = context.read<AdminRepository>().calculateDeliveryBoyStats(
      widget.deliveryBoy.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    String _formatNumber(dynamic value) {
  if (value == null) return '0';
  final num number = num.tryParse(value.toString()) ?? 0;
  return number.toStringAsFixed(0); // removes .00
}

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: FutureBuilder<Map<String, dynamic>>( 
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text('Error loading stats'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }

          final stats = snapshot.data ?? {};

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "${widget.deliveryBoy.name}'s",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Today's Stock Section
                  const Text(
                    "Today's Stock",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            SizedBox(width: 120, child: Text("")),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "1/2 L",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "1 L",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Need Row
                        _stockRow(
                          title: "Required",
                          half: stats["need_half"].toString(),
                          one: stats["need_one"].toString(),
                        ),

                        // Assign Row
                        _stockRow(
                          title: "Dispatched",
                          half: stats["assign_half"].toString(),
                          one: stats["assign_one"].toString(),
                        ),

                        // Left in market Row
                        _stockRow(
                          title: "Pending",
                          half: stats["left_half"].toString(),
                          one: stats["left_one"].toString(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Today's Money Section
                  const Text(
                    "Today's Money",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // Header Row
                        Row(
                          children: const [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Online",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Cash",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "Pending",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Values Row
                        Row(
                          children: [
                            Expanded(
  child: Center(
    child: Text(_formatNumber(stats["today_online"])),
  ),
),
Expanded(
  child: Center(
    child: Text(_formatNumber(stats["today_cash"])),
  ),
),
Expanded(
  child: Center(
    child: Text(_formatNumber(stats["today_pending"])),
  ),
),

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
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Pending",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${_formatNumber(stats["total_pending"])}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Close Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
          SizedBox(width: 120, child: Text(title)),
          Expanded(child: Center(child: Text(half))),
          Expanded(child: Center(child: Text(one))),
        ],
      ),
    );
  }
}
