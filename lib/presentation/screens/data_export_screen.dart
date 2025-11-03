import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/premium/data_export_service.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/common/loading_overlay.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  ExportType _selectedType = ExportType.all;
  ExportFormat _selectedFormat = ExportFormat.csv;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _anonymize = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentTierAsync = ref.watch(currentTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Export'),
        backgroundColor: context.tokens.surface,
        foregroundColor: context.tokens.textPrimary,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: currentTierAsync.when(
          data:
              (tier) =>
                  tier.hasFeature(FeatureType.export)
                      ? _buildExportForm(context)
                      : _buildPremiumRequired(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => const Center(
                child: Text('Error loading subscription status'),
              ),
        ),
      ),
    );
  }

  Widget _buildExportForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildExportTypeSection(context),
          const SizedBox(height: 24),
          _buildFormatSection(context),
          const SizedBox(height: 24),
          _buildDateRangeSection(context),
          const SizedBox(height: 24),
          _buildOptionsSection(context),
          const SizedBox(height: 32),
          _buildExportButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Your Data',
          style: context.tokens.typography.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Download your MinQ data in various formats for backup or analysis',
          style: context.tokens.typography.body.copyWith(
            color: context.tokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExportTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What to Export',
          style: context.tokens.typography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        RadioGroup<ExportType>(
          groupValue: _selectedType,
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
          child: Column(
            children: [
              ...ExportType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<ExportType>(
                    value: type,
                    title: Text(type.displayName),
                    subtitle: Text(_getTypeDescription(type)),
                    contentPadding: EdgeInsets.zero,
                    activeColor: context.tokens.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: context.tokens.typography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children:
              ExportFormat.values
                  .map(
                    (format) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: format != ExportFormat.values.last ? 8 : 0,
                        ),
                        child: _buildFormatCard(context, format),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildFormatCard(BuildContext context, ExportFormat format) {
    final isSelected = _selectedFormat == format;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = format;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? context.tokens.brandPrimary.withAlpha((255 * 0.1).round())
                  : context.tokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? context.tokens.brandPrimary
                    : context.tokens.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getFormatIcon(format),
              size: 32,
              color:
                  isSelected
                      ? context.tokens.brandPrimary
                      : context.tokens.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              format.name.toUpperCase(),
              style: context.tokens.typography.body.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isSelected
                        ? context.tokens.brandPrimary
                        : context.tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getFormatDescription(format),
              style: context.tokens.typography.bodySmall.copyWith(
                color: context.tokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range (Optional)',
          style: context.tokens.typography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                label: 'Start Date',
                date: _startDate,
                onTap: () => _selectStartDate(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                context,
                label: 'End Date',
                date: _endDate,
                onTap: () => _selectEndDate(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.tokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.tokens.typography.bodySmall.copyWith(
                color: context.tokens.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select date',
              style: context.tokens.typography.body.copyWith(
                color:
                    date != null
                        ? context.tokens.textPrimary
                        : context.tokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: context.tokens.typography.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _anonymize,
          onChanged: (value) {
            setState(() {
              _anonymize = value;
            });
          },
          title: const Text('Anonymize Data'),
          subtitle: const Text(
            'Replace personal identifiers with generic placeholders',
          ),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: context.tokens.brandPrimary,
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleExport,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.tokens.brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download),
            SizedBox(width: 8),
            Text(
              'Export Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: context.tokens.textMuted),
            const SizedBox(height: 24),
            Text(
              'Premium Feature',
              style: context.tokens.typography.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data export is available for Premium subscribers only. Upgrade to access this feature.',
              style: context.tokens.typography.body.copyWith(
                color: context.tokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.tokens.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _handleExport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exportService = ref.read(dataExportServiceProvider);

      ExportResult result;
      switch (_selectedFormat) {
        case ExportFormat.csv:
          result = await exportService.exportToCSV(
            type: _selectedType,
            startDate: _startDate,
            endDate: _endDate,
            anonymize: _anonymize,
          );
          break;
        case ExportFormat.pdf:
          result = await exportService.exportToPDF(
            type: _selectedType,
            startDate: _startDate,
            endDate: _endDate,
            anonymize: _anonymize,
          );
          break;
        case ExportFormat.json:
          result = await exportService.exportToJSON(
            type: _selectedType,
            startDate: _startDate,
            endDate: _endDate,
            anonymize: _anonymize,
          );
          break;
      }

      if (!mounted) return;

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed: ${result.fileName}'),
            backgroundColor: context.tokens.success,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => exportService.shareExport(result),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Export failed'),
            backgroundColor: context.tokens.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: context.tokens.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTypeDescription(ExportType type) {
    switch (type) {
      case ExportType.quests:
        return 'All your quests and their details';
      case ExportType.progress:
        return 'Daily progress and completion data';
      case ExportType.analytics:
        return 'Statistics and performance metrics';
      case ExportType.achievements:
        return 'Unlocked achievements and badges';
      case ExportType.all:
        return 'Complete data export including everything';
    }
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return Icons.table_chart;
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
      case ExportFormat.json:
        return Icons.code;
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'Spreadsheet format';
      case ExportFormat.pdf:
        return 'Formatted report';
      case ExportFormat.json:
        return 'Raw data format';
    }
  }
}
