
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/entities/item.dart';
import '../data/items_repository.dart';
import 'auth_providers.dart';

// Repositorio de platos.
final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

// LISTADO REACTIVO DE FIRESTORE.
final itemsProvider = StreamProvider<List<ItemRecord>>((ref) {
  final authState = ref.watch(authStateProvider);
  final repository = ref.watch(itemsRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(<ItemRecord>[]);
      }

      return repository.watchItems(user.uid);
    },
    loading: () => Stream.value(<ItemRecord>[]),
    error: (error, stackTrace) {
      return Stream<List<ItemRecord>>.error(
        error,
        stackTrace,
      );
    },
  );
});

// CONTROLADOR DE OPERACIONES ABM.
final itemsControllerProvider =
    AsyncNotifierProvider<ItemsController, void>(
  ItemsController.new,
);

class ItemsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Obtener UID del usuario autenticado.
  String _currentUid() {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;

    if (uid == null) {
      throw StateError('No hay un usuario autenticado.');
    }

    return uid;
  }

  // Cargar platos iniciales si la colección está vacía.
  Future<void> seedIfEmpty() async {
    final uid = _currentUid();

    await _execute(() {
      return ref
          .read(itemsRepositoryProvider)
          .seedInitialItemsIfEmpty(uid);
    });
  }

  // CREAR.
  Future<void> addItem(Item item) async {
    final uid = _currentUid();

    await _execute(() {
      return ref
          .read(itemsRepositoryProvider)
          .addItem(uid, item);
    });
  }

  // ACTUALIZAR.
  Future<void> updateItem(
    String documentId,
    Item item,
  ) async {
    final uid = _currentUid();

    await _execute(() {
      return ref
          .read(itemsRepositoryProvider)
          .updateItem(uid, documentId, item);
    });
  }

  // ELIMINAR.
  Future<void> deleteItem(String documentId) async {
    final uid = _currentUid();

    await _execute(() {
      return ref
          .read(itemsRepositoryProvider)
          .deleteItem(uid, documentId);
    });
  }

  // Manejar carga y errores.
  Future<void> _execute(
    Future<void> Function() action,
  ) async {
    state = const AsyncLoading<void>();

    try {
      await action();
      state = const AsyncData<void>(null);
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      rethrow;
    }
  }
}
