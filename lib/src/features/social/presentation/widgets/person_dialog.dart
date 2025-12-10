import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/person_model.dart';
import '../../providers/social_provider.dart';

class PersonDialog extends StatefulWidget {
  final SocialProvider provider;
  final PersonModel? person;

  const PersonDialog({super.key, required this.provider, this.person});

  @override
  State<PersonDialog> createState() => _PersonDialogState();
}

class _PersonDialogState extends State<PersonDialog> {
  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _phoneController;
  late int _frequency;
  File? _imageFile;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person?.name ?? '');
    _relationshipController = TextEditingController(
      text: widget.person?.relationship ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.person?.phoneNumber ?? '',
    );
    _frequency = widget.person?.contactFrequency ?? 7;
    _isFavorite = widget.person?.isFavorite ?? false;

    if (widget.person?.photoPath != null) {
      final file = File(widget.person!.photoPath!);
      if (file.existsSync()) {
        _imageFile = file;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.person != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Editar Aliado' : 'Nuevo Aliado',
        style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[800],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej: Ana',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relación',
                hintText: 'Ej: Pareja, Amigo',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                hintText: 'Ej: +54 9 11...',
                prefixIcon: Icon(Icons.phone, size: 20),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Frecuencia de contacto:',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _frequency,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Diario')),
                DropdownMenuItem(value: 3, child: Text('Cada 3 días')),
                DropdownMenuItem(value: 7, child: Text('Semanal')),
                DropdownMenuItem(value: 14, child: Text('Quincenal')),
                DropdownMenuItem(value: 30, child: Text('Mensual')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _frequency = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Marcar como Favorito'),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: _isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => _isFavorite = !_isFavorite),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _relationshipController.text.isNotEmpty) {
              if (isEditing) {
                final updatedPerson = widget.person!.copyWith(
                  name: _nameController.text,
                  relationship: _relationshipController.text,
                  contactFrequency: _frequency,
                  photoPath: _imageFile?.path,
                  isFavorite: _isFavorite,
                  phoneNumber: _phoneController.text,
                );
                widget.provider.updatePerson(updatedPerson);
              } else {
                widget.provider.addPerson(
                  name: _nameController.text,
                  relationship: _relationshipController.text,
                  contactFrequency: _frequency,
                  photoPath: _imageFile?.path,
                  isFavorite: _isFavorite,
                  phoneNumber: _phoneController.text,
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? 'GUARDAR' : 'AGREGAR'),
        ),
      ],
    );
  }
}
