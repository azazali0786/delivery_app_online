// lib/presentation/screens/admin/delivery_boy_stats_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/delivery_boy_model.dart';
import '../../../data/repositories/admin_repository.dart';

class DeliveryBoyStatsScreen extends StatefulWidget {
  final DeliveryBoyModel deliveryBoy;

  const DeliveryBoyStatsScreen({Key? key, required this.deliveryBoy})
      : super(key: key);

  @override
  State<DeliveryBoyStatsScreen> createState() => _DeliveryBoyStatsScreenState();
}

class _DeliveryBoyStatsScreenState extends State<DeliveryBoyStatsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final repo = context.read<AdminRepository>();
    final start = _startDate?.toIso8601String().split('T')[0];
    final end = _endDate?.toIso8601String().split('T')[0];
    setState(() {
      _statsFuture = repo.calculateDeliveryBoyStats(
        widget.deliveryBoy.id,
        startDate: start,
        endDate: end,
      );
    });
  }

  Future<void> _pickDateRange() async {
    final today = DateTime.now();
    final initialStart = _startDate ?? today;
    final initialEnd = _endDate ?? today;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadStats();
    }
  }

  String _fmtDate(DateTime? d) =>
      d == null ? 'All time' : d.toIso8601String().split('T')[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.deliveryBoy.name}'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final stats = snapshot.data ?? {};

          return RefreshIndicator(
            onRefresh: () async {
              _loadStats();
              // Wait a bit for the future to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              // Add physics to ensure pull-to-refresh works even when content is short
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Filter Card
                  _buildDateRangeCard(),

                  // Milk Inventory Section
                  _buildMilkInventorySection(stats),

                  // Money Section
                  _buildMoneySection(stats),

                  // Time Series Section
                  if ((stats['time_series'] ?? []).isNotEmpty)
                    _buildTimeSeriesSection(stats),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _startDate == null
                      ? 'All Time'
                      : '${_fmtDate(_startDate)} → ${_fmtDate(_endDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.edit, size: 14),
            label: const Text('Change', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkInventorySection(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_drink_rounded,
                  color: Colors.purple.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Milk Inventory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Total Active Milk
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Active Milk',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${stats['total_active_milk'] ?? 0} L',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bottle Stats Grid
          _buildBottleStatsGrid(stats),
        ],
      ),
    );
  }

  Widget _buildBottleStatsGrid(Map<String, dynamic> stats) {
    return Column(
      children: [
        // Needed
        _buildBottleStatRow(
          'Needed',
          stats['need_half'] ?? 0,
          stats['need_one'] ?? 0,
          Colors.orange,
          Icons.assignment_outlined,
        ),
        const SizedBox(height: 12),
        
        // Dispatched
        _buildBottleStatRow(
          'Dispatched',
          stats['stock_half_ltr_bottles'] ?? 0,
          stats['stock_one_ltr_bottles'] ?? 0,
          Colors.blue,
          Icons.local_shipping_outlined,
        ),
        const SizedBox(height: 12),
        
        // Delivered
        _buildBottleStatRow(
          'Delivered',
          stats['assign_half'] ?? 0,
          stats['assign_one'] ?? 0,
          Colors.green,
          Icons.check_circle_outline,
        ),
        const SizedBox(height: 12),
        
        // Left in Market
        _buildBottleStatRow(
          'Left in Market',
          stats['left_half'] ?? 0,
          stats['left_one'] ?? 0,
          Colors.red,
          Icons.inventory_2_outlined,
        ),
      ],
    );
  }

  Widget _buildBottleStatRow(
    String label,
    int halfLiter,
    int oneLiter,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    '½L: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$halfLiter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '1L: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '$oneLiter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneySection(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  color: Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Money Collection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildMoneyCard(
                  'Collected',
                  stats['collected_money'] ?? 0,
                  Colors.green,
                  Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMoneyCard(
                  'Pending',
                  stats['pending_money'] ?? 0,
                  Colors.orange,
                  Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyCard(String label, dynamic amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            '₹$amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesSection(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.table_chart_rounded,
                  color: Colors.indigo.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Disp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Del',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Coll\n  (₹)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'pend\n   (₹)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Data Rows
                ...((stats['time_series'] ?? []) as List).map((ts) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            ts['date'] ?? '',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              (ts['dispatched_one'] + (ts['dispatched_half'] * 0.5) ?? 0).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              (ts['assign_one'] + (ts['assign_half'] * 0.5) ?? 0).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              (ts['collected_money'] ?? 0).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              (ts['pending_money'] ?? 0).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}