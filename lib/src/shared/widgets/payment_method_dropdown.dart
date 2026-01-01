import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/finance_provider.dart';

/// Widget reutilizable para seleccionar método de pago (Efectivo o Tarjetas)
///
/// Consume automáticamente el `FinanceProvider` para obtener las tarjetas disponibles
/// del usuario. Siempre incluye la opción "Efectivo" como método por defecto.
///
/// Ejemplo de uso:
/// ```dart
/// PaymentMethodDropdown(
///   selectedMethod: _selectedPaymentMethod,
///   onChanged: (method) {
///     setState(() => _selectedPaymentMethod = method);
///   },
/// )
/// ```
class PaymentMethodDropdown extends StatelessWidget {
  /// Método de pago actualmente seleccionado (ej: "Efectivo", "Visa", etc.)
  final String selectedMethod;

  /// Callback que se ejecuta cuando el usuario selecciona un método diferente
  final ValueChanged<String> onChanged;

  /// Si el dropdown está habilitado o deshabilitado
  final bool enabled;

  /// Label personalizado (por defecto: "Método de Pago")
  final String? label;

  const PaymentMethodDropdown({
    required this.selectedMethod,
    required this.onChanged,
    this.enabled = true,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hintColor = theme.hintColor;
    final inputFillColor = isDark ? Colors.black26 : Colors.grey.shade100;
    final textColor = theme.colorScheme.onSurface;

    // Obtener métodos de pago disponibles del usuario
    final availableMethods = financeProvider.getAvailablePaymentMethods();

    // Validación: Si el método seleccionado no está en la lista, usar el primero disponible
    final validatedMethod = availableMethods.contains(selectedMethod)
        ? selectedMethod
        : availableMethods.first;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: validatedMethod,
      dropdownColor: theme.cardColor,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label ?? 'Método de Pago',
        labelStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(
          // Icono dinámico: efectivo vs tarjeta
          validatedMethod == 'Efectivo' ? Icons.money : Icons.credit_card,
          color: validatedMethod == 'Efectivo' ? Colors.green : Colors.cyan,
        ),
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: availableMethods.map((method) {
        // Determinar si es efectivo o tarjeta para el icono
        final isEffective = method == 'Efectivo';

        return DropdownMenuItem(
          value: method,
          child: Row(
            children: [
              Icon(
                isEffective ? Icons.money : Icons.credit_card,
                color: isEffective ? Colors.green : Colors.cyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  method,
                  style: GoogleFonts.inter(
                    fontWeight: isEffective
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: enabled
          ? (value) {
              if (value != null) {
                onChanged(value);
              }
            }
          : null,
    );
  }
}
