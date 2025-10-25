import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/claim_provider.dart';
import '../../providers/crop_provider.dart';
import '../../models/claim_model.dart';
import '../../models/crop_model.dart';
import '../../utils/app_colors.dart';

class AddClaimScreen extends StatefulWidget {
  const AddClaimScreen({super.key});

  @override
  State<AddClaimScreen> createState() => _AddClaimScreenState();
}

class _AddClaimScreenState extends State<AddClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _estimatedLossController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  
  Crop? _selectedCrop;
  DisasterType _selectedDisasterType = DisasterType.flood;
  DateTime _selectedDisasterDate = DateTime.now();
  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    // Load crops if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadCrops();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedLossController.dispose();
    _estimatedValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Crop Loss'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text('Submit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crop Selection
              _buildCropSelection(),
              const SizedBox(height: 24),
              
              // Disaster Type
              _buildDisasterTypeSelector(),
              const SizedBox(height: 16),
              
              // Disaster Date
              _buildDisasterDateSelector(),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the damage and its impact',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Estimated Loss
              TextFormField(
                controller: _estimatedLossController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Loss (%)',
                  hintText: 'e.g., 50',
                  prefixIcon: Icon(Icons.trending_down),
                  suffixText: '%',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter estimated loss';
                  }
                  final loss = double.tryParse(value);
                  if (loss == null || loss < 0 || loss > 100) {
                    return 'Please enter a valid percentage (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Estimated Value
              TextFormField(
                controller: _estimatedValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Value Loss (₹)',
                  hintText: 'e.g., 50000',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter estimated value loss';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Images Section
              _buildImagesSection(),
              const SizedBox(height: 24),
              
              // Submit Button
              Consumer<ClaimProvider>(
                builder: (context, claimProvider, _) {
                  return ElevatedButton(
                    onPressed: claimProvider.isLoading ? null : _handleSave,
                    child: claimProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit Claim'),
                  );
                },
              ),
              
              // Error Message
              Consumer<ClaimProvider>(
                builder: (context, claimProvider, _) {
                  if (claimProvider.error != null) {
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              claimProvider.error!,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropSelection() {
    return Consumer<CropProvider>(
      builder: (context, cropProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Crop',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Crop>(
              value: _selectedCrop,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.agriculture),
                hintText: 'Select the affected crop',
              ),
              items: cropProvider.crops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text('${crop.name} (${crop.typeDisplayName})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a crop';
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisasterTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disaster Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DisasterType>(
          value: _selectedDisasterType,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.warning),
          ),
          items: DisasterType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getDisasterTypeDisplayName(type)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDisasterType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDisasterDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disaster Date',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDisasterDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              '${_selectedDisasterDate.day}/${_selectedDisasterDate.month}/${_selectedDisasterDate.year}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Damage Images',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload photos showing the damage to your crops',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        
        // Add Image Button
        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Photos'),
        ),
        
        // Display Selected Images
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDisasterDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDisasterDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDisasterDate = date;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  String _getDisasterTypeDisplayName(DisasterType type) {
    switch (type) {
      case DisasterType.flood:
        return 'Flood';
      case DisasterType.drought:
        return 'Drought';
      case DisasterType.pestAttack:
        return 'Pest Attack';
      case DisasterType.disease:
        return 'Disease';
      case DisasterType.hailstorm:
        return 'Hailstorm';
      case DisasterType.cyclone:
        return 'Cyclone';
      case DisasterType.fire:
        return 'Fire';
      case DisasterType.other:
        return 'Other';
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one image')),
        );
        return;
      }

      final claimProvider = Provider.of<ClaimProvider>(context, listen: false);
      
      final claim = Claim(
        id: '', // Will be set by provider
        farmerId: '1', // Should come from auth provider
        cropId: _selectedCrop!.id,
        disasterType: _selectedDisasterType,
        description: _descriptionController.text.trim(),
        estimatedLoss: double.parse(_estimatedLossController.text),
        estimatedValue: double.parse(_estimatedValueController.text),
        imageUrls: _selectedImages.map((file) => file.path).toList(), // In real app, upload to server
        status: ClaimStatus.underReview,
        disasterDate: _selectedDisasterDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await claimProvider.addClaim(claim);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim submitted successfully!')),
        );
        context.go('/claims');
      }
    }
  }
}
