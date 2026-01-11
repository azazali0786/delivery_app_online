// Add this widget class in your file
import 'package:flutter/material.dart';

class MilkInventoryScreen extends StatefulWidget {
  const MilkInventoryScreen({Key? key}) : super(key: key);

  @override
  State<MilkInventoryScreen> createState() => _MilkInventoryScreenState();
}

class _MilkInventoryScreenState extends State<MilkInventoryScreen> {
  // Sample data - this is today milk(half+one ltr bottle) requirement
  Map<String, dynamic> inventoryData = {
    'total_active_milk': 92.5,
    'total_half_liter_bottles': 35,
    'total_one_liter_bottles': 75,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milk Inventory'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MilkInventorySection(inventoryData: inventoryData),
            
            // Add more sections here if needed
            const SizedBox(height: 24),
            
            // Example: Add buttons or additional features
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Handle update inventory
          },
          icon: const Icon(Icons.edit),
          label: const Text('Update Inventory'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // Handle view history
          },
          icon: const Icon(Icons.history),
          label: const Text('View History'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

class MilkInventorySection extends StatelessWidget {
  final Map<String, dynamic> inventoryData;

  const MilkInventorySection({Key? key, this.inventoryData = const {}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalMilk = inventoryData['total_active_milk'] ?? 0.0;
    final halfLiterBottles = inventoryData['total_half_liter_bottles'] ?? 0;
    final oneLiterBottles = inventoryData['total_one_liter_bottles'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Active Milk Card - Compact
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_drink_rounded,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Total Active Milk',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 15,
                      ),
                ),
              ),
              Text(
                '${totalMilk.toStringAsFixed(1)} L',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Bottle Types Row - Compact
        Row(
          children: [
            Expanded(
              child: _BottleTypeCard(
                bottleSize: '½ L',
                count: halfLiterBottles,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _BottleTypeCard(
                bottleSize: '1 L',
                count: oneLiterBottles,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottleTypeCard extends StatelessWidget {
  final String bottleSize;
  final int count;
  final Color color;

  const _BottleTypeCard({
    required this.bottleSize,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.water_drop_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            bottleSize,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
          const Spacer(),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
