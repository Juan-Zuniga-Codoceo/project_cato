import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/pet_provider.dart';
import '../../domain/models/pet_model.dart'; // [NUEVO]

class AddPetDialog extends StatefulWidget {
  final PetModel? petToEdit; // [NUEVO]
  const AddPetDialog({super.key, this.petToEdit});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _nameController = TextEditingController();
  final _vetController = TextEditingController();
  DateTime _birthDate = DateTime.now();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.petToEdit != null) {
      _nameController.text = widget.petToEdit!.name;
      _vetController.text = widget.petToEdit!.vetName ?? '';
      _birthDate = widget.petToEdit!.birthDate;
      if (widget.petToEdit!.photoPath != null) {
        _imageFile = File(widget.petToEdit!.photoPath!);
      }
    }
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
    return AlertDialog(
      title: Text(
        widget.petToEdit != null ? 'Editar Recluta' : 'Nuevo Recluta',
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
                    ? const Icon(Icons.add_a_photo, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vetController,
              decoration: const InputDecoration(
                labelText: 'Veterinario (Opcional)',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de Nacimiento'),
              subtitle: Text(
                '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _birthDate = picked);
                }
              },
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
          onPressed: _isLoading
              ? null
              : () async {
                  if (_nameController.text.isNotEmpty) {
                    setState(() => _isLoading = true);
                    try {
                      if (widget.petToEdit != null) {
                        await Provider.of<PetProvider>(
                          context,
                          listen: false,
                        ).updatePet(
                          widget.petToEdit!.copyWith(
                            name: _nameController.text,
                            birthDate: _birthDate,
                            photoPath: _imageFile?.path,
                            vetName: _vetController.text,
                          ),
                        );
                      } else {
                        await Provider.of<PetProvider>(
                          context,
                          listen: false,
                        ).addPet(
                          name: _nameController.text,
                          birthDate: _birthDate,
                          photoPath: _imageFile?.path,
                          vetName: _vetController.text,
                        );
                      }
                      if (mounted) Navigator.pop(context);
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.petToEdit != null ? 'GUARDAR' : 'AGREGAR'),
        ),
      ],
    );
  }
}
