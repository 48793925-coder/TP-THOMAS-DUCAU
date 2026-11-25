import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/entities/item.dart';
import '../data/items_repository.dart';
import '../providers/auth_providers.dart';
import '../providers/items_providers.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Carga los platos iniciales una sola vez, según el repositorio.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        await ref
            .read(itemsControllerProvider.notifier)
            .seedIfEmpty();
      } catch (error) {
        _showMessage('No se pudieron cargar los platos iniciales.');
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  Future<void> _openAddScreen() async {
    final item = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (_) => const EditScreen(),
      ),
    );

    if (item == null || !mounted) return;

    try {
      await ref
          .read(itemsControllerProvider.notifier)
          .addItem(item);

      _showMessage('Plato guardado correctamente.');
    } catch (error) {
      _showMessage('No se pudo guardar el plato.');
    }
  }

  Future<void> _openDetail(ItemRecord record) async {
    final updatedItem = await Navigator.of(context).push<Item>(
      MaterialPageRoute(
        builder: (_) => DetailScreen(item: record.item),
      ),
    );

    if (updatedItem == null || !mounted) return;

    try {
      await ref
          .read(itemsControllerProvider.notifier)
          .updateItem(record.id, updatedItem);

      _showMessage('Plato actualizado correctamente.');
    } catch (error) {
      _showMessage('No se pudo actualizar el plato.');
    }
  }

  Future<void> _deleteItem(ItemRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar plato'),
          content: Text('¿Querés eliminar "${record.item.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await ref
          .read(itemsControllerProvider.notifier)
          .deleteItem(record.id);

      _showMessage('Plato eliminado correctamente.');
    } catch (error) {
      _showMessage('No se pudo eliminar el plato.');
    }
  }

  Future<void> _logout() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .logout();

      // El router detecta el cierre de sesión y redirige al login.
    } catch (error) {
      _showMessage('No se pudo cerrar la sesión.');
    }
  }

  Widget _buildItemsList(List<ItemRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Todavía no hay platos.\nPresioná + para agregar uno.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final item = record.item;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            onTap: () => _openDetail(record),
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
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
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
              width: 88,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 21,
                    ),
                    onPressed: () => _deleteItem(record),
                  ),
                  IconButton(
                    tooltip: 'Ver detalle',
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onPressed: () => _openDetail(record),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);

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
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            color: Colors.blueAccent.withAlpha(31),
            child: Text(
              '¡Bienvenido, ${widget.username}!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Expanded(
            child: itemsAsync.when(
              data: _buildItemsList,
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudieron cargar los platos.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(itemsProvider);
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
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