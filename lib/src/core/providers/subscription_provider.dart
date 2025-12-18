import 'package:flutter/material.dart';

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionProvider() {
    _checkSubscriptionStatus();
  }

  bool _isPro = true; // [GHOST MODE] Por defecto TRUE para usuarios fundadores
  bool _isLoading = false;

  bool get isPro => _isPro;
  bool get isLoading => _isLoading;

  Future<void> _checkSubscriptionStatus() async {
    // Aquí integraremos RevenueCat en el futuro.
    // Por ahora, simulamos que verificamos y otorgamos acceso total.
    // Estrategia "Legacy": Si la app ya estaba instalada antes de la fecha de corte, es Pro.
    _isPro = true;
    notifyListeners();
  }

  // Método placeholder para futura pantalla de pago
  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isPro = true;
    _isLoading = false;
    notifyListeners();
  }
}
