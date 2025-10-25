import 'package:flutter/material.dart';
import '../../models/claim_model.dart';

class ClaimProvider with ChangeNotifier {
  List<Claim> _claims = [];
  bool _isLoading = false;
  String? _error;

  List<Claim> get claims => _claims;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for demonstration
  void loadClaims() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      _claims = [
        Claim(
          id: '1',
          farmerId: '1',
          cropId: '1',
          disasterType: DisasterType.flood,
          description: 'Heavy rainfall caused flooding in the rice field',
          estimatedLoss: 60.0,
          estimatedValue: 50000.0,
          imageUrls: ['https://example.com/flood1.jpg'],
          status: ClaimStatus.underReview,
          disasterDate: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Claim(
          id: '2',
          farmerId: '1',
          cropId: '2',
          disasterType: DisasterType.pestAttack,
          description: 'Locust attack damaged wheat crop',
          estimatedLoss: 40.0,
          estimatedValue: 30000.0,
          imageUrls: ['https://example.com/pest1.jpg'],
          status: ClaimStatus.approved,
          disasterDate: DateTime.now().subtract(const Duration(days: 10)),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          approvedAmount: 25000.0,
        ),
      ];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> addClaim(Claim claim) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newClaim = claim.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _claims.add(newClaim);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add claim: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClaimStatus(String claimId, ClaimStatus newStatus) async {
    try {
      final index = _claims.indexWhere((claim) => claim.id == claimId);
      if (index != -1) {
        _claims[index] = _claims[index].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update claim status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Claim? getClaimById(String id) {
    try {
      return _claims.firstWhere((claim) => claim.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Claim> getClaimsByStatus(ClaimStatus status) {
    return _claims.where((claim) => claim.status == status).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
