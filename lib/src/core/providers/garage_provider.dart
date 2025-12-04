import 'package:flutter/material.dart';
import 'dart:io';
import '../../features/garage/domain/models/vehicle.dart';
import '../../features/garage/domain/models/vehicle_document.dart';
import '../../features/garage/domain/models/maintenance.dart';
import '../services/storage_service.dart';
import '../services/file_manager_service.dart';

class GarageProvider extends ChangeNotifier {
  final StorageService _storageService;

  GarageProvider(this._storageService);

  List<Vehicle> get vehicles => _storageService.vehicleBox.values.toList();
  List<Maintenance> get maintenances =>
      _storageService.maintenanceBox.values.toList();

  void addVehicle(Vehicle vehicle) {
    _storageService.vehicleBox.put(vehicle.id, vehicle);
    notifyListeners();
  }

  void updateVehicle(Vehicle vehicle) {
    _storageService.vehicleBox.put(vehicle.id, vehicle);
    notifyListeners();
  }

  void deleteVehicle(String id) {
    _storageService.vehicleBox.delete(id);

    // Also delete associated maintenance
    final maintenanceToDelete = _storageService.maintenanceBox.values
        .where((m) => m.vehicleId == id)
        .map((m) => m.id)
        .toList();

    for (var maintenanceId in maintenanceToDelete) {
      _storageService.maintenanceBox.delete(maintenanceId);
    }

    notifyListeners();
  }

  void addMaintenance(Maintenance maintenance) {
    _storageService.maintenanceBox.put(maintenance.id, maintenance);

    // Update vehicle mileage if greater
    final vehicle = _storageService.vehicleBox.get(maintenance.vehicleId);
    if (vehicle != null && maintenance.mileage > vehicle.currentMileage) {
      updateVehicle(vehicle.copyWith(currentMileage: maintenance.mileage));
    }

    notifyListeners();
  }

  void deleteMaintenance(String id) {
    _storageService.maintenanceBox.delete(id);
    notifyListeners();
  }

  List<Maintenance> getMaintenanceForVehicle(String vehicleId) {
    return _storageService.maintenanceBox.values
        .where((m) => m.vehicleId == vehicleId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateVehiclePhoto(
    String vehicleId,
    String tempImagePath,
  ) async {
    print('📷 Guardando foto permanentemente...');

    try {
      // Save file permanently using FileManagerService
      final permanentPath = await FileManagerService.saveFilePermanently(
        File(tempImagePath),
        'vehicle_photos',
      );

      print('✅ Foto guardada en: $permanentPath');

      final vehicle = _storageService.vehicleBox.get(vehicleId);
      if (vehicle != null) {
        // Delete old photo if exists
        if (vehicle.imagePath != null && vehicle.imagePath!.isNotEmpty) {
          await FileManagerService.deleteFile(vehicle.imagePath!);
        }

        updateVehicle(vehicle.copyWith(imagePath: permanentPath));
        print('✅ Vehículo actualizado con nueva foto: ${vehicle.name}');
      } else {
        print('❌ Vehículo no encontrado con ID: $vehicleId');
      }
    } catch (e) {
      print('❌ Error guardando foto: $e');
    }
  }

  Future<void> addDocument(String vehicleId, VehicleDocument document) async {
    print('📄 Agregando documento: ${document.name} al vehículo $vehicleId');

    try {
      // Save file permanently using FileManagerService
      final permanentPath = await FileManagerService.saveFilePermanently(
        File(document.imagePath),
        'vehicle_documents',
      );

      print('✅ Documento guardado en: $permanentPath');

      final vehicle = _storageService.vehicleBox.get(vehicleId);
      if (vehicle != null) {
        // Create document with permanent path
        final permanentDocument = document.copyWith(imagePath: permanentPath);

        final updatedDocuments = List<VehicleDocument>.from(vehicle.documents)
          ..add(permanentDocument);
        updateVehicle(vehicle.copyWith(documents: updatedDocuments));
        print('✅ Documento agregado: ${document.name}');
      } else {
        print('❌ Vehículo no encontrado con ID: $vehicleId');
      }
    } catch (e) {
      print('❌ Error agregando documento: $e');
    }
  }

  Future<void> deleteDocument(String vehicleId, String documentId) async {
    print('🗑️ Eliminando documento ID: $documentId del vehículo $vehicleId');
    final vehicle = _storageService.vehicleBox.get(vehicleId);
    if (vehicle != null) {
      // Find document to delete its file
      final docToDelete = vehicle.documents.firstWhere(
        (doc) => doc.id == documentId,
        orElse: () => throw Exception('Document not found'),
      );

      try {
        // Delete file from storage
        await FileManagerService.deleteFile(docToDelete.imagePath);

        // Remove from list
        final updatedDocuments = vehicle.documents
            .where((doc) => doc.id != documentId)
            .toList();
        updateVehicle(vehicle.copyWith(documents: updatedDocuments));
        print('✅ Documento eliminado');
      } catch (e) {
        print('❌ Error eliminando documento: $e');
      }
    } else {
      print('❌ Vehículo no encontrado con ID: $vehicleId');
    }
  }
}
