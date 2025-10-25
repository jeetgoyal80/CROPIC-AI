import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/crop_provider.dart';
import '../../models/crop_model.dart';
import '../../utils/app_colors.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        final crop = cropProvider.getCropById(widget.cropId);
        
        if (crop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Crop Details')),
            body: const Center(
              child: Text('Crop not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(crop.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement edit functionality
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Image
                _buildCropImage(crop),
                const SizedBox(height: 24),
                
                // Basic Information
                _buildBasicInfo(crop),
                const SizedBox(height: 24),
                
                // Crop Stage Progress
                _buildStageProgress(crop),
                const SizedBox(height: 24),
                
                // Location Information
                _buildLocationInfo(crop),
                const SizedBox(height: 24),
                
                // Action Buttons
                _buildActionButtons(crop),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCropImage(Crop crop) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
      ),
      child: crop.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                crop.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture,
            size: 60,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(Crop crop) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Crop Type', crop.typeDisplayName),
          _buildInfoRow('Area', '${crop.area} acres'),
          _buildInfoRow('Sowing Date', _formatDate(crop.sowingDate)),
          _buildInfoRow('Current Stage', crop.stageDisplayName),
          _buildInfoRow('Days Since Sowing', _calculateDaysSinceSowing(crop.sowingDate).toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgress(Crop crop) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Crop Stage Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...CropStage.values.asMap().entries.map((entry) {
            final index = entry.key;
            final stage = entry.value;
            final isCompleted = index <= CropStage.values.indexOf(crop.currentStage);
            final isCurrent = stage == crop.currentStage;
            
            return _buildStageItem(stage, isCompleted, isCurrent);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStageItem(CropStage stage, bool isCompleted, bool isCurrent) {
    Color stageColor;
    IconData stageIcon;
    
    switch (stage) {
      case CropStage.sowing:
        stageColor = AppColors.sowing;
        stageIcon = Icons.agriculture;
        break;
      case CropStage.vegetative:
        stageColor = AppColors.vegetative;
        stageIcon = Icons.local_florist;
        break;
      case CropStage.flowering:
        stageColor = AppColors.flowering;
        stageIcon = Icons.eco;
        break;
      case CropStage.fruiting:
        stageColor = AppColors.fruiting;
        stageIcon = Icons.apple;
        break;
      case CropStage.harvest:
        stageColor = AppColors.harvest;
        stageIcon = Icons.grass;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted || isCurrent 
                  ? stageColor 
                  : AppColors.textSecondary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stageIcon,
              color: isCompleted || isCurrent ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStageDisplayName(stage),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCurrent ? stageColor : AppColors.textPrimary,
                  ),
                ),
                if (isCurrent)
                  Text(
                    'Current Stage',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: stageColor,
                    ),
                  ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(Crop crop) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Location Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Address', crop.address),
          _buildInfoRow('Latitude', crop.latitude.toStringAsFixed(6)),
          _buildInfoRow('Longitude', crop.longitude.toStringAsFixed(6)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Open map with crop location
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening map...')),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('View on Map'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Crop crop) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _updateCropStage(crop),
            icon: const Icon(Icons.update),
            label: const Text('Update Stage'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _reportLoss(crop),
            icon: const Icon(Icons.report_problem),
            label: const Text('Report Loss'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getStageDisplayName(CropStage stage) {
    switch (stage) {
      case CropStage.sowing:
        return 'Sowing';
      case CropStage.vegetative:
        return 'Vegetative';
      case CropStage.flowering:
        return 'Flowering';
      case CropStage.fruiting:
        return 'Fruiting';
      case CropStage.harvest:
        return 'Harvest';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDaysSinceSowing(DateTime sowingDate) {
    return DateTime.now().difference(sowingDate).inDays;
  }

  void _updateCropStage(Crop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${crop.name} Stage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CropStage.values.map((stage) {
            return ListTile(
              title: Text(_getStageDisplayName(stage)),
              leading: Radio<CropStage>(
                value: stage,
                groupValue: crop.currentStage,
                onChanged: (value) {
                  if (value != null) {
                    context.read<CropProvider>().updateCropStage(crop.id, value);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${crop.name} stage updated to ${_getStageDisplayName(value)}')),
                    );
                  }
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _reportLoss(Crop crop) {
    context.go('/add-claim', extra: {'cropId': crop.id});
  }
}
