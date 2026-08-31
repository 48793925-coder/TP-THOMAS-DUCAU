import 'package:flutter/material.dart';
import 'package:tp4/core/router/entities/item.dart';

class EditScreen extends StatefulWidget {
  final Item? item;

  const EditScreen({super.key, this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageCtrl;
  late final TextEditingController _originCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _accompCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _nameCtrl = TextEditingController(text: it?.name ?? '');
    _descCtrl = TextEditingController(text: it?.description ?? '');
    _imageCtrl = TextEditingController(text: it?.imageUrl ?? 'https://via.placeholder.com/150');
    _originCtrl = TextEditingController(text: it?.origin ?? '');
    _ratingCtrl = TextEditingController(text: it?.rating.toString() ?? '4.5');
    _ingredientsCtrl = TextEditingController(text: it != null ? it.ingredients.join(', ') : '');
    _accompCtrl = TextEditingController(text: it != null ? it.accompaniments.join(', ') : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    _originCtrl.dispose();
    _ratingCtrl.dispose();
    _ingredientsCtrl.dispose();
    _accompCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final image = _imageCtrl.text.trim();
    final origin = _originCtrl.text.trim();
    final rating = double.tryParse(_ratingCtrl.text.trim()) ?? 4.5;
    final ingredients = _ingredientsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final accomp = _accompCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final newItem = Item(
      name: name,
      description: desc,
      imageUrl: image,
      origin: origin,
      rating: rating,
      ingredients: ingredients,
      accompaniments: accomp,
    );

    Navigator.of(context).pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Plato' : 'Agregar Plato'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa una descripción' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageCtrl,
                  decoration: const InputDecoration(labelText: 'URL de imagen'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _originCtrl,
                  decoration: const InputDecoration(labelText: 'Origen'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ratingCtrl,
                  decoration: const InputDecoration(labelText: 'Rating (numérico)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ingredientsCtrl,
                  decoration: const InputDecoration(labelText: 'Ingredientes (separados por coma)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accompCtrl,
                  decoration: const InputDecoration(labelText: 'Acompañamientos (separados por coma)'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
