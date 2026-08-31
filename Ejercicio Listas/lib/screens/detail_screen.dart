import 'package:flutter/material.dart';
import 'package:tp4/core/router/entities/item.dart';
import 'package:tp4/screens/edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final Item item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Item _current;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _current = widget.item;
  }

  Future<bool> _onWillPop() async {
    if (_changed) {
      Navigator.of(context).pop(_current);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_current.name),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final edited = await Navigator.of(context).push<Item>(
                  MaterialPageRoute(builder: (_) => EditScreen(item: _current)),
                );
                if (edited != null) {
                  setState(() {
                    _current = edited;
                    _changed = true;
                  });
                }
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // IMAGEN SUPERIOR
              Image.network(
                _current.imageUrl,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Imagen no disponible', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),

              // CONTENIDO INFORMATIVO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título principal
                    Text(
                      _current.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Información de País y Puntuación
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _current.origin,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          _current.rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.0),
                      child: Divider(),
                    ),

                    // Sección: Descripción
                    const Text(
                      'Acerca de este plato',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _current.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sección: Ingredientes
                    const Text(
                      'Ingredientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Generamos la lista de ingredientes dinámicamente
                    ..._current.ingredients.map((ingrediente) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.kitchen, color: Colors.blueAccent),
                        title: Text(
                          ingrediente,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Sección: Sugerencias / Acompañamientos
                    const Text(
                      'Sugerencias',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Generamos la lista de comidas dinámicamente
                    ..._current.accompaniments.map((comida) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: const Icon(Icons.restaurant, color: Colors.orange),
                        title: Text(
                          comida,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}