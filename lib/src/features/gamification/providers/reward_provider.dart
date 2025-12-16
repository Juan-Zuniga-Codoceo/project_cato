import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/reward_model.dart';
import '../../../core/providers/finance_provider.dart';
import '../../finance/domain/models/transaction.dart';
import '../../finance/domain/models/category.dart';

class RewardProvider extends ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  RewardProvider(this._storageService);

  // Obtener todas las recompensas
  List<RewardModel> get rewards => _storageService.rewardsBox.values.toList();

  // Disponibles
  List<RewardModel> get availableRewards =>
      rewards.where((r) => !r.isRedeemed).toList();

  // Historial
  List<RewardModel> get redeemedRewards =>
      rewards.where((r) => r.isRedeemed).toList();

  void addReward({
    required String title,
    required double cost,
    required int iconCode,
    required int colorValue,
    String? categoryId, // [NUEVO]
  }) {
    final newReward = RewardModel(
      id: _uuid.v4(),
      title: title,
      cost: cost,
      iconCode: iconCode,
      colorValue: colorValue,
      categoryId: categoryId, // [NUEVO] Guardamos la categoría
      isRedeemed: false,
    );
    _storageService.rewardsBox.put(newReward.id, newReward);
    notifyListeners();
  }

  void deleteReward(String id) {
    _storageService.rewardsBox.delete(id);
    notifyListeners();
  }

  /// Intenta canjear una recompensa.
  Future<bool> redeemReward(BuildContext context, RewardModel reward) async {
    final financeProvider = Provider.of<FinanceProvider>(
      context,
      listen: false,
    );

    // 1. Verificar Fondos
    if (financeProvider.totalBalance < reward.cost) {
      return false;
    }

    // 2. Determinar Categoría para el Gasto
    CategoryModel? category;

    // A. Intento Directo: Usar la categoría vinculada al item
    if (reward.categoryId != null) {
      category = financeProvider.getCategoryById(reward.categoryId!);
    }

    // B. Fallback: Si no tiene categoría (items viejos) o se borró, buscar genérica
    if (category == null) {
      try {
        category = financeProvider.categories.firstWhere(
          (c) =>
              c.name.toLowerCase().contains('entretenimiento') ||
              c.name.toLowerCase().contains('compras') ||
              c.name.toLowerCase().contains('otros'),
          orElse: () => financeProvider.categories.first,
        );
      } catch (e) {
        return false; // Sin categorías disponibles
      }
    }

    // 3. Crear Transacción
    final transaction = Transaction(
      id: DateTime.now().toString(),
      title: 'Recompensa: ${reward.title}',
      amount: reward.cost,
      isExpense: true,
      date: DateTime.now(),
      category: category,
    );

    await financeProvider.addTransaction(transaction);

    // 4. Actualizar estado
    reward.isRedeemed = true;
    reward.redeemedDate = DateTime.now();
    reward.save();

    notifyListeners();
    return true;
  }

  void restoreReward(RewardModel reward) {
    reward.isRedeemed = false;
    reward.redeemedDate = null;
    reward.save();
    notifyListeners();
  }
}
