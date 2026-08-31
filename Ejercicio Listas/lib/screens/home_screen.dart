import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tp4/core/router/entities/item.dart';
import 'package:tp4/screens/edit_screen.dart';
import 'package:tp4/screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Item> items;

  @override
  void initState() {
    super.initState();
    items = [
      Item(
        name: 'Feijoada',
        origin: 'Brasil',
        rating: 4.8,
        description: 'Estofado tradicional brasileño hecho con frijoles negros y varias carnes, servido con arroz y farofa.',
        imageUrl: 'https://images.unsplash.com/photo-1625944525533-473f1b3d54f4?w=800',
        ingredients: ['Frijoles negros', 'Carne de cerdo', 'Farofa'],
        accompaniments: ['Arroz blanco', 'Naranjas en gajos'],
      ),
      Item(
        name: 'Asado',
        origin: 'Argentina',
        rating: 4.7,
        description: 'Parrillada clásica argentina: cortes de carne a la parrilla, ahumados lentamente y servidos con chimichurri.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/4/45/Asado_argentino.jpg',
        ingredients: ['Tira de asado', 'Chorizo', 'Morcilla'],
        accompaniments: ['Chimichurri', 'Ensalada criolla'],
      ),
      Item(
        name: 'Pizza estilo NY',
        origin: 'Estados Unidos',
        rating: 4.9,
        description: 'Pizza de masa delgada y bordes crujientes, servida en porciones grandes para llevar y disfrutar al paso.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg',
        ingredients: ['Masa fina', 'Salsa de tomate', 'Mozzarella'],
        accompaniments: ['Pepperoni', 'Albahaca fresca'],
      ),
      Item(
        name: 'Fish and Chips',
        origin: 'Reino Unido',
        rating: 4.6,
        description: 'Pescado rebozado y papas fritas crujientes, un clásico británico acompañado de salsa tártara.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/f/ff/Fish_and_chips_blackpool.jpg',
        ingredients: ['Pescado blanco', 'Rebozado crujiente', 'Papas fritas'],
        accompaniments: ['Salsa tártara', 'Guisantes triturados'],
      ),
      Item(
        name: 'Pasta Carbonara',
        origin: 'Italia',
        rating: 4.9,
        description: 'Pasta italiana con salsa cremosa de huevo, queso pecorino y panceta crujiente.',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/33/Espaguetis_carbonara.jpg',
        ingredients: ['Spaghetti', 'Huevos', 'Panceta'],
        accompaniments: ['Queso Pecorino', 'Pimienta negra'],
      ),
      Item(
        name: 'Churros con Chocolate',
        origin: 'España',
        rating: 4.7,
        description: 'Dulce tradicional hecho de masa frita espolvoreada con azúcar y acompañado de chocolate caliente para mojar.',
        imageUrl: 'https://live.staticflickr.com/126/348229335_8e3e9cf4d7_o.jpg',
        ingredients: ['Masa frita', 'Azúcar', 'Canela'],
        accompaniments: ['Chocolate caliente', 'Café expreso'],
      ),
      Item(
        name: 'Ceviche',
        origin: 'Perú',
        rating: 4.8,
        description: 'Plato de pescado crudo marinado en jugo de limón, acompañado de cebolla, ají y cilantro.',
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJ5IzF2akTbFJQdz_6FOyj27_yCxYQ9ADtMUkuTXdxlyNiU8YAOB_eZwY&s=10',
        ingredients: ['Pescado fresco', 'Jugo de limón', 'Cebolla roja'],
        accompaniments: ['Camote', 'Choclo'],
      ),
    ];
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.of(context).push<Item>(
      MaterialPageRoute(builder: (_) => const EditScreen()),
    );
    if (result != null) {
      setState(() {
        items.insert(0, result);
      });
    }
  }

  // Editing is handled from the Detail screen now.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: const Text('Platos Destacados'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            color: Colors.blueAccent.withAlpha((0.12 * 255).round()),
            child: Text(
              '¡Bienvenido, ${widget.username}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 76,
                            height: 76,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    trailing: SizedBox(
                      width: 96,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Eliminar plato'),
                                  content: Text('¿Eliminar "${item.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                setState(() {
                                  items.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Plato eliminado')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () async {
                              final result = await Navigator.of(context).push<Item>(
                                MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                              );
                              if (result != null) {
                                setState(() {
                                  items[index] = result;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}