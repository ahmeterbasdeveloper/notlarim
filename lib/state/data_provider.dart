import 'package:flutter/material.dart';
import 'package:notlarim/domain/entities/oncelik.dart';
import 'package:notlarim/domain/usecases/oncelik/get_all_oncelik.dart';

class OncelikProvider extends ChangeNotifier {
  final GetAllOncelik getAllOncelikUseCase;

  OncelikProvider({required this.getAllOncelikUseCase});

  List<Oncelik> _oncelikler = [];
  List<Oncelik> get oncelikler => _oncelikler;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await getAllOncelikUseCase();
      _oncelikler = result;
    } catch (e) {
      debugPrint('❌ Öncelikler yüklenirken hata: $e');
      _oncelikler = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
