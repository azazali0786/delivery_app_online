import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/repositories/admin_repository.dart';

class InvoiceShareDialog extends StatefulWidget {
  final List<Map<String, dynamic>> customers;

  const InvoiceShareDialog({Key? key, required this.customers})
    : super(key: key);

  @override
  State<InvoiceShareDialog> createState() => _InvoiceShareDialogState();
}

class _InvoiceShareDialogState extends State<InvoiceShareDialog> {
  int? _selectedCustomerId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _useDateRange = false;
  late AdminRepository _adminRepository;

  @override
  void initState() {
    super.initState();
    _adminRepository = context.read<AdminRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Invoice'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Customer',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              value: _selectedCustomerId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Choose a customer',
                prefixIcon: const Icon(Icons.people),
              ),
              items: widget.customers.map((customer) {
                return DropdownMenuItem<int?>(
                  value: customer['id'] as int?,
                  child: Text(customer['name'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCustomerId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Date Range (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _useDateRange,
                  onChanged: (value) {
                    setState(() {
                      _useDateRange = value ?? false;
                      if (!_useDateRange) {
                        _startDate = null;
                        _endDate = null;
                      }
                    });
                  },
                ),
                const Expanded(
                  child: Text('Use Date Range', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            if (_useDateRange) ...[
              const SizedBox(height: 12),
              _buildDatePicker(
                label: 'From Date',
                date: _startDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildDatePicker(
                label: 'To Date',
                date: _endDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _endDate = picked);
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Leave date range empty to get full invoice',
                style: TextStyle(fontSize: 12, color: AppColors.info),
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
        ElevatedButton.icon(
          onPressed: _generateInvoice,
          icon: const Icon(Icons.share),
          label: const Text('Generate & Share'),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null ? DateFormat('dd MMM yyyy').format(date) : label,
                style: TextStyle(
                  fontSize: 14,
                  color: date != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateInvoice() {
    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_useDateRange && (_startDate == null || _endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.pop(context);
    _showInvoicePreview();
  }

  void _showInvoicePreview() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            title: const Text('Invoice Preview'),
            content: FutureBuilder<Map<String, dynamic>>(
              future: _adminRepository.generateInvoice(
                customerId: _selectedCustomerId!,
                startDate: _useDateRange && _startDate != null
                    ? Helpers.formatDateApi(_startDate!)
                    : null,
                endDate: _useDateRange && _endDate != null
                    ? Helpers.formatDateApi(_endDate!)
                    : null,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 300,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generating invoice...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Text('No data');
                }

                return _buildInvoiceContent(snapshot.data!);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice shared successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceContent(Map<String, dynamic> invoice) {
    final entries = invoice['entries'] as List? ?? [];
    final totalMilk = invoice['total_milk'] ?? 0.0;
    final totalCollected = invoice['total_collected'] ?? 0.0;
    final totalPending = invoice['total_pending'] ?? '0.00';
    final customerName = invoice['customer_name'] ?? 'Unknown';
    final customerPhone = invoice['customer_phone'] ?? 'N/A';
    final periodStart = invoice['period_start'] ?? 'N/A';
    final periodEnd = invoice['period_end'] ?? 'N/A';

    return SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MILK DELIVERY INVOICE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Customer: $customerName'),
                Text('Phone: $customerPhone'),
                Text('Period: $periodStart to $periodEnd'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isNotEmpty) ...[
            const Text(
              'Delivery Details:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${e['date']} - ${e['milk_quantity']}L',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              Helpers.formatCurrency(
                                double.tryParse(e['collected'].toString()) ??
                                    0.0,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const Text(
              'No entries found for selected period',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Milk:'),
                    Text('${totalMilk.toStringAsFixed(2)} L'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Collected:'),
                    Text(
                      Helpers.formatCurrency(
                        double.tryParse(totalCollected.toString()) ?? 0.0,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pending Amount:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Helpers.formatCurrency(
                        double.tryParse(totalPending) ?? 0.0,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
