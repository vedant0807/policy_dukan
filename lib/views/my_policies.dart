import 'dart:io';

import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import 'package:policy_dukaan/widgets/custom_appbar.dart';
import '../api_service.dart';
import '../widgets/custom_searchbar.dart';
import 'package:file_picker/file_picker.dart';

class PoliciesScreen extends StatefulWidget {
  const PoliciesScreen({Key? key}) : super(key: key);

  @override
  State<PoliciesScreen> createState() => _PoliciesScreenState();
}

class _PoliciesScreenState extends State<PoliciesScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _policies = [];
  String? _errorMessage;
  int selectedIndex = 0;
  bool _isImporting = false;
  bool _isExporting = false;
  bool _isDeleting = false;

  // ✅ Bulk delete selection state
  bool _isSelectionMode = false;
  Set<String> _selectedPolicyIds = {};

  final List<_ButtonData> buttons = [
    _ButtonData("Bulk Import", Icons.upload),
    _ButtonData("Sample CSV", Icons.description),
    _ButtonData("Export All", Icons.download),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPolicies();
  }

  void _showImportResultDialog({
    required bool success,
    required String title,
    required String message,
    required int inserted,
    required int total,
    required int skipped,
    Map<String, dynamic>? skipReasons,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('Total Records', total.toString()),
              _buildStatRow('Imported', inserted.toString(), Colors.green),
              if (skipped > 0)
                _buildStatRow('Skipped', skipped.toString(), Colors.orange),
              if (skipReasons != null && skipReasons.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Skip Reasons:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...skipReasons.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      '• ${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchPolicies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getPolicies();

    if (result['success'] == true) {
      setState(() {
        _policies = result['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load policies';
        _isLoading = false;
      });
    }
  }

  Future<void> _onBulkImportClick() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);

        debugPrint('Selected file: ${file.path}');

        setState(() {
          _isImporting = true;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Importing policies...'),
                  SizedBox(height: 8),
                  Text(
                    'Please wait while we process your file',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );

        final response = await _apiService.bulkImportPolicies(file);

        if (mounted) {
          Navigator.of(context).pop();
        }

        setState(() {
          _isImporting = false;
        });

        if (response['success'] == true) {
          final inserted = response['inserted'] ?? 0;
          final total = response['total'] ?? 0;
          final skipped = response['skippedInFile'] ?? 0;

          _showImportResultDialog(
            success: true,
            title: 'Import Successful',
            message: response['message'] ?? 'Import completed',
            inserted: inserted,
            total: total,
            skipped: skipped,
            skipReasons: response['skipReasons'],
          );

          _fetchPolicies();
        } else {
          _showErrorSnackBar(
            response['message'] ?? 'Failed to import policies',
          );
        }
      }
    } catch (e) {
      debugPrint('Bulk import error: $e');

      if (mounted && _isImporting) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isImporting = false;
      });

      _showErrorSnackBar('Failed to import: ${e.toString()}');
    }
  }

  Future<void> _onSampleCSVClick() async {
    try {
      setState(() {
        _isExporting = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating sample CSV...'),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );

      final response = await _apiService.downloadSampleExcel();

      if (mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isExporting = false;
      });

      if (response['success'] == true && response['filePath'] != null) {
        _showSuccessSnackBar(
          'Sample CSV template downloaded: ${response['fileName']}',
        );
      } else {
        _showErrorSnackBar(
          response['message'] ?? 'Failed to download sample CSV',
        );
      }
    } catch (e) {
      debugPrint('Sample CSV error: $e');

      if (mounted && _isExporting) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isExporting = false;
      });

      _showErrorSnackBar('Failed to download sample: ${e.toString()}');
    }
  }

  Future<void> _onExportClick() async {
    try {
      setState(() {
        _isExporting = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Exporting policies...'),
                SizedBox(height: 8),
                Text(
                  'Please wait while we prepare your file',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );

      final response = await _apiService.exportPolicies();

      if (mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isExporting = false;
      });

      if (response['success'] == true && response['filePath'] != null) {
        _showSuccessSnackBar(
          'File downloaded to Downloads folder: ${response['fileName']}',
        );
      } else {
        _showErrorSnackBar(
          response['message'] ?? 'Failed to export policies',
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');

      if (mounted && _isExporting) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isExporting = false;
      });

      _showErrorSnackBar('Failed to export: ${e.toString()}');
    }
  }

  // ✅ Enter selection mode
  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedPolicyIds.clear();
    });
  }

  // ✅ Exit selection mode
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedPolicyIds.clear();
    });
  }

  // ✅ Toggle policy selection
  void _togglePolicySelection(String policyId) {
    if (policyId.isEmpty) return;

    setState(() {
      if (_selectedPolicyIds.contains(policyId)) {
        _selectedPolicyIds.remove(policyId);
      } else {
        _selectedPolicyIds.add(policyId);
      }
    });
  }

  // ✅ Confirm and delete selected policies
  Future<void> _confirmAndDeleteSelected() async {
    if (_selectedPolicyIds.isEmpty) {
      _showErrorSnackBar('Please select at least one policy to delete');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Confirm Delete'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete ${_selectedPolicyIds.length} ${_selectedPolicyIds.length == 1 ? 'policy' : 'policies'}?\n\nThis action cannot be undone.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _bulkDeletePolicies();
    }
  }

  // ✅ Bulk delete policies
  Future<void> _bulkDeletePolicies() async {
    setState(() {
      _isDeleting = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting policies...'),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );

    final response = await _apiService.bulkDeletePolicies(
      _selectedPolicyIds.toList(),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isDeleting = false;
    });

    if (response['success'] == true) {
      _showSuccessSnackBar(
        response['message'] ?? 'Policies deleted successfully',
      );

      // Exit selection mode and refresh
      _exitSelectionMode();
      _fetchPolicies();
    } else {
      _showErrorSnackBar(
        response['message'] ?? 'Failed to delete policies',
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isSelectionMode
            ? '${_selectedPolicyIds.length} Selected'
            : "My Policies",
        centerTitle: true,
        actions: _isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
            tooltip: 'Cancel',
          ),
        ]
            : null,
      ),
      body: Column(
        children: [
          // 🔢 Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Total', _policies.length.toString(),
                    Colors.white, Colors.black87),
                _buildStatCard('Active', _countByStatus('Active').toString(),
                    AppColors.card1, AppColors.success),
                _buildStatCard('Pending', _countByStatus('Pending').toString(),
                    AppColors.card2, AppColors.orange),
                _buildStatCard('Expired', _countByStatus('Expired').toString(),
                    AppColors.card3, AppColors.error),
              ],
            ),
          ),

          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search policy',
              onChanged: (value) {
                debugPrint('Searching: $value');
              },
              onClear: () {
                debugPrint('Search cleared');
              },
            ),
          ),

          // ✅ Action Buttons Row
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _policies.isEmpty
                    ? null
                    : (_isSelectionMode
                    ? _confirmAndDeleteSelected
                    : _enterSelectionMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isSelectionMode ? Colors.red : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isSelectionMode
                          ? Colors.red[700]!
                          : AppColors.primaryVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSelectionMode ? Icons.delete : Icons.checklist,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSelectionMode ? 'Delete Selected' : 'Bulk Delete',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ Other Buttons (Import, Sample CSV, Export)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(buttons.length, (index) {
                final isSelected = selectedIndex == index;

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });

                    if (index == 0) {
                      // ✅ BULK IMPORT
                      _onBulkImportClick();
                    } else if (index == 1) {
                      // Sample CSV
                      _onSampleCSVClick();
                    } else if (index == 2) {
                      // Export All
                      _onExportClick();
                    }
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ?  AppColors.primary// 🔵 Blue selected
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryVariant
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          buttons[index].icon,
                          size: 14,
                          color:
                          isSelected ? Colors.white : Colors.black87,
                        ),
                        Text(
                          buttons[index].label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // 📋 Policies List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_policies.isEmpty) {
      return const Center(
        child: Text('No policies found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _policies.length,
        itemBuilder: (context, index) {
          final policy = _policies[index];
          final policyId = policy['id']?.toString() ?? '';  // ✅ FIXED: Use 'id' instead of '_id'
          final isSelected = _selectedPolicyIds.contains(policyId);

          // Debug: Print the policy ID
          debugPrint('Policy ${index + 1} ID: "$policyId"');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: _isSelectionMode && isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _isSelectionMode && policyId.isNotEmpty
                  ? () => _togglePolicySelection(policyId)
                  : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Checkbox in selection mode
                  if (_isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: policyId.isNotEmpty
                          ? (value) => _togglePolicySelection(policyId)
                          : null,
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy['policy_number'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${policy['customer_first_name'] ?? ''} ${policy['customer_last_name'] ?? ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          policy['policy_type'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          policy['status'] ?? 'Active',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${policy['premium_with_gst'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Exp: ${policy['policy_end_date'] ?? '-'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        );
  }

  int _countByStatus(String status) {
    return _policies
        .where((p) =>
    (p['status'] ?? '').toString().toLowerCase() ==
        status.toLowerCase())
        .length;
  }

  Widget _buildStatCard(
      String label, String count, Color bgColor, Color textColor) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ButtonData {
  final String label;
  final IconData icon;

  _ButtonData(this.label, this.icon);
}

Widget _buildStatRow(String label, String value, [Color? valueColor]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    ),
  );
}