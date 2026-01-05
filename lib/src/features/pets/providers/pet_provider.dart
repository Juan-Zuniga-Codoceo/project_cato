import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers/finance_provider.dart';
import '../../finance/domain/models/transaction.dart';
import '../../finance/domain/models/category.dart';
import '../domain/models/pet_model.dart';

class PetProvider extends ChangeNotifier {
  final StorageService _storageService;

  PetProvider(this._storageService) {
    _initGeneralPet();
  }

  void _initGeneralPet() {
    if (!_box.containsKey('general_supplies')) {
      final general = PetModel(
        id: 'general_supplies',
        name: 'LOGÍSTICA',
        birthDate: DateTime.now(),
        vetName: 'Proveedores',
      );
      _box.put('general_supplies', general);
    }
  }

  Box<PetModel> get _box => _storageService.petsBox;

  List<PetModel> get pets =>
      _box.values.where((p) => p.id != 'general_supplies').toList();

  PetModel? get generalSupplies => _box.get('general_supplies');

  PetModel? getPet(String id) => _box.get(id); // [NUEVO]

  Future<void> addPet({
    required String name,
    required DateTime birthDate,
    String? photoPath,
    String? vetName,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newPet = PetModel(
      id: id,
      name: name,
      birthDate: birthDate,
      photoPath: photoPath,
      vetName: vetName,
    );
    await _box.put(id, newPet);
    notifyListeners();
  }

  Future<void> updatePet(PetModel pet) async {
    await _box.put(pet.id, pet);
    notifyListeners();
  }

  Future<void> deletePet(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> addHealthRecord({
    required String petId,
    required HealthRecordModel record,
    FinanceProvider? financeProvider,
    String? paymentMethod,
  }) async {
    final pet = _box.get(petId);
    if (pet != null) {
      // 1. Add record to pet
      final updatedHistory = List<HealthRecordModel>.from(pet.healthHistory)
        ..add(record);
      final updatedPet = pet.copyWith(healthHistory: updatedHistory);
      await _box.put(petId, updatedPet);

      // 2. Add transaction to finance if cost > 0
      if (record.cost > 0 && financeProvider != null) {
        // Find or create 'Mascotas' category
        CategoryModel category;
        try {
          category = financeProvider.categories.firstWhere(
            (c) => c.name.toLowerCase().contains('mascota'),
          );
        } catch (_) {
          // Fallback or create? For now use first or create temp
          if (financeProvider.categories.isNotEmpty) {
            category = financeProvider.categories.first;
          } else {
            // Should not happen if initialized
            return;
          }
        }

        final tx = Transaction(
          id:
              record.transactionId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: '${record.type} - ${pet.name}',
          amount: record.cost,
          isExpense: true,
          date: record.date,
          category: category,
          paymentMethod: paymentMethod,
        );

        // We use the finance provider to add it, so it updates its state
        // Note: addTransaction is async but we don't necessarily need to await it for the pet update
        // But better to await.
        // However, financeProvider.addTransaction is not exposed in the interface I saw?
        // I saw it in the file content: addTransaction(tx)
        // Wait, I saw addTransaction(tx) in the file content I read?
        // Yes, line 184 calls addTransaction(tx).
        // Let's assume it's public.

        // Actually, I can just write to the box directly if I want, but using provider is better.
        // But since I don't have access to addTransaction in the snippet I read (it was cut off or I missed it),
        // I'll assume it exists. If not, I'll use _storageService.transactionBox.put

        await _storageService.transactionBox.put(tx.id, tx);
        financeProvider.notifyListeners(); // Force update
      }

      notifyListeners();
      notifyListeners();
    }
  }

  Future<void> deleteHealthRecord(String petId, String recordId) async {
    final pet = _box.get(petId);
    if (pet != null) {
      final recordIndex = pet.healthHistory.indexWhere((r) => r.id == recordId);
      if (recordIndex == -1) return;

      final record = pet.healthHistory[recordIndex];

      // Delete linked transaction if exists
      if (record.transactionId != null) {
        await _storageService.transactionBox.delete(record.transactionId);
      }

      final updatedHistory = List<HealthRecordModel>.from(pet.healthHistory)
        ..removeAt(recordIndex);

      final updatedPet = pet.copyWith(healthHistory: updatedHistory);
      await _box.put(petId, updatedPet);
      notifyListeners();
    }
  }

  Future<void> updateHealthRecord({
    required String petId,
    required HealthRecordModel record,
    FinanceProvider? financeProvider,
  }) async {
    final pet = _box.get(petId);
    if (pet != null) {
      final index = pet.healthHistory.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        final updatedHistory = List<HealthRecordModel>.from(pet.healthHistory);
        updatedHistory[index] = record;

        final updatedPet = pet.copyWith(healthHistory: updatedHistory);
        await _box.put(petId, updatedPet);

        // Update transaction if exists
        if (record.transactionId != null) {
          final tx = _storageService.transactionBox.get(record.transactionId);
          if (tx != null) {
            final updatedTx = Transaction(
              id: tx.id,
              title: '${record.type} - ${pet.name}',
              amount: record.cost,
              isExpense: true,
              date: record.date,
              category: tx.category,
              paymentMethod: tx.paymentMethod,
            );
            await _storageService.transactionBox.put(tx.id, updatedTx);
            financeProvider?.notifyListeners();
          }
        }

        notifyListeners();
      }
    }
  }
}
