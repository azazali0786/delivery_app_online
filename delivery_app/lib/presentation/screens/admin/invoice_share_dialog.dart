import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/invoice_pdf_helper.dart';
import '../../../data/repositories/customer_repository.dart';

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
  late CustomerRepository _customerRepository;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _customerRepository = context.read<CustomerRepository>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // sort alphabetically
    final sortedCustomers = [...widget.customers];
    sortedCustomers.sort(
      (a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()),
    );

    // filter by search
    final filteredCustomers = sortedCustomers.where((customer) {
      final name = (customer['name'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Share Invoice',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _selectedCustomerId != null ? _generateInvoice : null,
            icon: const Icon(Icons.share, color: Colors.white, size: 16),
            label: const Text(
              'Generate & Share',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: _selectedCustomerId != null
                  ? AppColors.primary
                  : Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.person, size: 16, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Select Customer',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${filteredCustomers.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? AppColors.primary
                      : AppColors.border,
                  width: _searchQuery.isNotEmpty ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search customer...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _searchQuery.isNotEmpty
                        ? AppColors.primary
                        : Colors.grey[400],
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),

            // Customer List
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: filteredCustomers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 40,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No customers found',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(6),
                      itemCount: filteredCustomers.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        final isSelected =
                            customer['id'] == _selectedCustomerId;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() {
                                _selectedCustomerId = customer['id'];
                                _searchController.text = customer['name'];
                                _searchQuery = customer['name'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.08)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isSelected
                                        ? AppColors.primary
                                        : Colors.grey[300],
                                    child: Text(
                                      (customer['name'] ?? 'U')[0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      customer['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: () =>
                                          _sendWhatsAppToCustomer(customer),
                                      child: Image.asset(
                                        'assets/images/whatsapp.png',
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),

                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // Date Range Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    size: 16,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Date Range',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _useDateRange
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _useDateRange = !_useDateRange;
                        if (!_useDateRange) {
                          _startDate = null;
                          _endDate = null;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _useDateRange
                                  ? AppColors.primary
                                  : Colors.white,
                              border: Border.all(
                                color: _useDateRange
                                    ? AppColors.primary
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _useDateRange
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Filter by date range',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_useDateRange) ...[
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      label: 'From Date',
                      date: _startDate,
                      icon: Icons.calendar_today,
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
                    const SizedBox(height: 10),
                    _buildDatePicker(
                      label: 'To Date',
                      date: _endDate,
                      icon: Icons.event,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _endDate = picked);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            if (!_useDateRange) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Full invoice will be generated',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: date != null ? AppColors.primary : AppColors.border,
            width: date != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (date != null ? AppColors.primary : Colors.grey[400])!
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 16,
                color: date != null ? AppColors.primary : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: date != null
                          ? AppColors.textPrimary
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
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

    // Do NOT pop the current dialog before showing the preview.
    // Popping first disposed this State and caused "widget unmounted" errors
    // when the preview tried to use this context. Show the preview on top
    // of the current dialog instead.
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
            content: FutureBuilder<InvoiceData>(
              future: _fetchInvoiceData(),
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
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _generateAndSharePdf();
                },
                icon: const Icon(Icons.share),
                label: const Text('Generate & Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<InvoiceData> _fetchInvoiceData() async {
    final customer = widget.customers.firstWhere(
      (c) => c['id'] == _selectedCustomerId,
    );

    final resp = await _customerRepository.getCustomerEntriesWithOpeningBalance(
      _selectedCustomerId!,
      startDate: _useDateRange && _startDate != null
          ? Helpers.formatDateApi(_startDate!)
          : null,
      endDate: _useDateRange && _endDate != null
          ? Helpers.formatDateApi(_endDate!)
          : null,
    );

    final entries = (resp['entries'] as List).cast();
    final openingBalance = (resp['opening_balance'] ?? 0.0) as double;

    if (entries.isEmpty && openingBalance == 0.0) {
      throw Exception('No entries found for selected period');
    }

    return InvoiceData(
      customer: customer,
      entries: entries,
      openingBalance: openingBalance,
    );
  }

  Future<void> _generateAndSharePdf() async {
    try {
      final customer = widget.customers.firstWhere(
        (c) => c['id'] == _selectedCustomerId,
      );

      final resp = await _customerRepository
          .getCustomerEntriesWithOpeningBalance(
            _selectedCustomerId!,
            startDate: _useDateRange && _startDate != null
                ? Helpers.formatDateApi(_startDate!)
                : null,
            endDate: _useDateRange && _endDate != null
                ? Helpers.formatDateApi(_endDate!)
                : null,
          );

      final entries = (resp['entries'] as List);
      final openingBalance = (resp['opening_balance'] ?? 0.0) as double;

      if (entries.isEmpty && openingBalance == 0.0) {
        _showError('No entries found for selected period');
        return;
      }

      final entriesMap = entries
          .map(
            (e) => {
              'entry_date': e.entryDate,
              'milk_quantity': e.milkQuantity,
              'rate': e.rate,
              'collected_money': e.collectedMoney,
            },
          )
          .toList();

      await InvoicePdfHelper.generateInvoicePdf(
        customerName: customer['name'] ?? 'Unknown',
        customerPhone: customer['phone_number'] ?? '',
        customerAddress: customer['address'],
        areaName: customer['area_name'] ?? 'N/A',
        subAreaName: customer['sub_area_name'] ?? 'N/A',
        permanentQuantity:
            double.tryParse(customer['permanent_quantity'].toString()) ?? 0.0,
        entries: entriesMap,
        openingBalance: openingBalance,
      );

      _showSuccess('Invoice generated and shared successfully');
    } catch (e) {
      _showError('Error generating invoice: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _sendWhatsAppToCustomer(Map<String, dynamic> customer) async {
    final phone = customer['phone_number'] ?? customer['whatsapp_number'] ?? '';
    final message =
        'Hello, this is Alive Milk. Please find your invoice attached. Thank you.';

    try {
      await Helpers.openWhatsApp(phone, message);
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceAll('Exception: ', '')
          : 'Unable to open WhatsApp';
      _showError(msg);
    }
  }

  Widget _buildInvoiceContent(InvoiceData invoiceData) {
    final entries = invoiceData.entries;
    final customer = invoiceData.customer;
    double totalMilk = 0;
    double totalCollected = 0;
    double totalAmount = 0;

    for (var entry in entries) {
      totalMilk += entry.milkQuantity;
      totalCollected += entry.collectedMoney;
      totalAmount += entry.milkQuantity * entry.rate;
    }

    final totalPending = totalAmount - totalCollected;

    // Determine period display
    final periodText = entries.isNotEmpty
        ? '${DateFormat('dd MMM yyyy').format(DateTime.parse(entries.first.entryDate).toLocal())} to ${DateFormat('dd MMM yyyy').format(DateTime.parse(entries.last.entryDate).toLocal())}'
        : 'N/A';

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
                Text('Customer: ${customer['name']}'),
                Text('Phone: ${customer['phone_number'] ?? 'N/A'}'),
                Text('Period: $periodText'),
                const SizedBox(height: 8),
                Text(
                  'Opening Balance: ${Helpers.formatCurrency(invoiceData.openingBalance)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
    children: () {
      // Sort entries by date in ASCENDING order
      final sortedEntries = entries.toList()
        ..sort((a, b) => DateTime.parse(a.entryDate)
            .compareTo(DateTime.parse(b.entryDate)));
      
      double cumulative = invoiceData.openingBalance;
      
      return sortedEntries.map((e) {
        final milkQty = e.milkQuantity;
        final rate = e.rate;
        final collected = e.collectedMoney;
        final amount = milkQty * rate;
        final pending = amount - collected;
        cumulative += pending;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${DateFormat('dd MMM yyyy').format(DateTime.parse(e.entryDate).toLocal())} - ${milkQty.toStringAsFixed(1)}L @ ${rate.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Helpers.formatCurrency(amount),
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Paid: ${Helpers.formatCurrency(collected)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Balance: ${Helpers.formatCurrency(cumulative)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList();
    }(),
  ),
),
          const SizedBox(height: 16),
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
                    Text(Helpers.formatCurrency(totalCollected)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Opening Balance:'),
                    Text(Helpers.formatCurrency(invoiceData.openingBalance)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Balance Due:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      Helpers.formatCurrency(
                        invoiceData.openingBalance + totalPending,
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

class InvoiceData {
  final Map<String, dynamic> customer;
  final List<dynamic> entries;
  final double openingBalance;

  InvoiceData({
    required this.customer,
    required this.entries,
    this.openingBalance = 0.0,
  });
}
