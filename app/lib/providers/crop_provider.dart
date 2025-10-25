import 'package:flutter/material.dart';
import '../../models/crop_model.dart';

class CropProvider with ChangeNotifier {
  List<Crop> _crops = [];
  bool _isLoading = false;
  String? _error;

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for demonstration
  void loadCrops() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      _crops = [
        Crop(
          id: '1',
          farmerId: '1',
          name: 'Rice Field 1',
          type: CropType.rice,
          sowingDate: DateTime.now().subtract(const Duration(days: 30)),
          area: 2.5,
          latitude: 28.6139,
          longitude: 77.2090,
          address: 'Village A, District B, State C',
          currentStage: CropStage.vegetative,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        Crop(
          id: '2',
          farmerId: '1',
          name: 'Wheat Field 1',
          type: CropType.wheat,
          sowingDate: DateTime.now().subtract(const Duration(days: 15)),
          area: 1.8,
          latitude: 28.6140,
          longitude: 77.2091,
          address: 'Village A, District B, State C',
          currentStage: CropStage.sowing,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> addCrop(Crop crop) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newCrop = crop.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _crops.add(newCrop);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add crop: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCropStage(String cropId, CropStage newStage) async {
    try {
      final index = _crops.indexWhere((crop) => crop.id == cropId);
      if (index != -1) {
        _crops[index] = _crops[index].copyWith(
          currentStage: newStage,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update crop stage: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Crop? getCropById(String id) {
    try {
      return _crops.firstWhere((crop) => crop.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Crop> getCropsByStage(CropStage stage) {
    return _crops.where((crop) => crop.currentStage == stage).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
