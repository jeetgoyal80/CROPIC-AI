import 'package:flutter/material.dart';
import '../../models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  List<WeatherAlert> _alerts = [];
  List<FarmingTip> _farmingTips = [];
  bool _isLoading = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  List<WeatherAlert> get alerts => _alerts;
  List<FarmingTip> get farmingTips => _farmingTips;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for demonstration
  void loadWeatherData() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      _weatherData = WeatherData(
        location: 'Farm Location',
        temperature: 28.5,
        humidity: 65.0,
        windSpeed: 12.0,
        condition: 'Partly Cloudy',
        description: 'Partly cloudy with light winds',
        timestamp: DateTime.now(),
        alerts: [],
      );

      _alerts = [
        WeatherAlert(
          id: '1',
          title: 'Heavy Rain Warning',
          description: 'Heavy rainfall expected in the next 24 hours. Take necessary precautions for your crops.',
          severity: 'high',
          startTime: DateTime.now().add(const Duration(hours: 6)),
          endTime: DateTime.now().add(const Duration(hours: 30)),
          type: 'rain',
        ),
        WeatherAlert(
          id: '2',
          title: 'Temperature Alert',
          description: 'High temperature expected. Ensure adequate irrigation for your crops.',
          severity: 'medium',
          startTime: DateTime.now().add(const Duration(hours: 12)),
          endTime: DateTime.now().add(const Duration(hours: 48)),
          type: 'temperature',
        ),
      ];

      _farmingTips = [
        FarmingTip(
          id: '1',
          title: 'Rice Cultivation Tips',
          description: 'Ensure proper water management during the vegetative stage. Maintain 2-3 inches of standing water.',
          category: 'Water Management',
          cropType: 'Rice',
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        FarmingTip(
          id: '2',
          title: 'Pest Control for Wheat',
          description: 'Monitor for aphid infestation during flowering stage. Use neem-based pesticides for organic control.',
          category: 'Pest Control',
          cropType: 'Wheat',
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        FarmingTip(
          id: '3',
          title: 'Soil Health Improvement',
          description: 'Add organic compost to improve soil fertility. Test soil pH regularly for optimal crop growth.',
          category: 'Soil Management',
          cropType: 'General',
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
