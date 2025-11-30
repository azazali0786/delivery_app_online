// lib/presentation/widgets/admin/customer_filter_bar.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomerFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController minPendingController;
  final Function(String) onSearchChanged;
  final Function(String) onMinPendingChanged;
  final String? areaFilter;
  final String? subAreaFilter;
  final String? shiftFilter;
  final Set<String> allAreas;
  final Set<String> allSubAreas;
  final Function(String?) onAreaChanged;
  final Function(String?) onSubAreaChanged;
  final Function(String?) onShiftChanged;
  final VoidCallback onClearFilters;

  const CustomerFilterBar({
    Key? key,
    required this.searchController,
    required this.minPendingController,
    required this.onSearchChanged,
    required this.onMinPendingChanged,
    required this.areaFilter,
    required this.subAreaFilter,
    required this.shiftFilter,
    required this.allAreas,
    required this.allSubAreas,
    required this.onAreaChanged,
    required this.onSubAreaChanged,
    required this.onShiftChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = areaFilter != null ||
        subAreaFilter != null ||
        shiftFilter != null ||
        minPendingController.text.isNotEmpty;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // Min Pending Money Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: minPendingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Min pending amount (e.g., 100)',
                prefixIcon: const Icon(Icons.filter_list),
                suffixIcon: minPendingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          minPendingController.clear();
                          onMinPendingChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: onMinPendingChanged,
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Clear All Button
                  if (hasActiveFilters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: const Text('Clear All'),
                        avatar: const Icon(Icons.clear, size: 16),
                        onPressed: onClearFilters,
                        backgroundColor: AppColors.error.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Shift Filter
                  _buildFilterChip(
                    label: 'Shift: ${_getShiftLabel()}',
                    isSelected: shiftFilter != null,
                    onTap: () => _showShiftDialog(context),
                  ),
                  const SizedBox(width: 8),

                  // Area Filter
                  if (allAreas.isNotEmpty)
                    _buildFilterChip(
                      label: 'Area: ${areaFilter ?? 'All'}',
                      isSelected: areaFilter != null,
                      onTap: () => _showAreaDialog(context),
                    ),
                  const SizedBox(width: 8),

                  // Sub-Area Filter
                  if (allSubAreas.isNotEmpty)
                    _buildFilterChip(
                      label: 'Sub-Area: ${subAreaFilter ?? 'All'}',
                      isSelected: subAreaFilter != null,
                      onTap: () => _showSubAreaDialog(context),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String _getShiftLabel() {
    if (shiftFilter == null) return 'All';
    return shiftFilter == 'morning' ? 'Morning' : 'Evening';
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
    );
  }

  void _showShiftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Shift'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              onShiftChanged(null);
              Navigator.pop(ctx);
            },
            child: const Text('All'),
          ),
          SimpleDialogOption(
            onPressed: () {
              onShiftChanged('morning');
              Navigator.pop(ctx);
            },
            child: const Text('Morning'),
          ),
          SimpleDialogOption(
            onPressed: () {
              onShiftChanged('evening');
              Navigator.pop(ctx);
            },
            child: const Text('Evening'),
          ),
        ],
      ),
    );
  }

  void _showAreaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Area'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              onAreaChanged(null);
              Navigator.pop(ctx);
            },
            child: const Text('All Areas'),
          ),
          ...allAreas.map((area) {
            return SimpleDialogOption(
              onPressed: () {
                onAreaChanged(area);
                Navigator.pop(ctx);
              },
              child: Text(area),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showSubAreaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Sub-Area'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              onSubAreaChanged(null);
              Navigator.pop(ctx);
            },
            child: const Text('All Sub-Areas'),
          ),
          ...allSubAreas.map((subArea) {
            return SimpleDialogOption(
              onPressed: () {
                onSubAreaChanged(subArea);
                Navigator.pop(ctx);
              },
              child: Text(subArea),
            );
          }).toList(),
        ],
      ),
    );
  }
}