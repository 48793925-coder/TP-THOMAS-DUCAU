import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/router/entities/item.dart';

class ItemRecord {
  final String id;
  final Item item;

  const ItemRecord({
    required this.id,
    required this.item,
  });
}

class ItemsRepository {
  final FirebaseFirestore firestore;

  ItemsRepository({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>> _itemsCollection(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('items');
  }

  // Convierte un plato a un mapa para guardarlo en Firestore.
  Map<String, dynamic> _toMap(Item item) {
    return {
      'name': item.name,
      'origin': item.origin,
      'rating': item.rating,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'ingredients': item.ingredients,
      'accompaniments': item.accompaniments,
    };
  }

  // Convierte un documento de Firestore a un objeto Item.
  Item _fromMap(Map<String, dynamic> data) {
    return Item(
      name: data['name'] as String? ?? '',
      origin: data['origin'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      accompaniments: List<String>.from(
        data['accompaniments'] ?? [],
      ),
    );
  }

  // Escucha los platos en tiempo real.
  Stream<List<ItemRecord>> watchItems(String uid) {
    return _itemsCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemRecord(
          id: doc.id,
          item: _fromMap(doc.data()),
        );
      }).toList();
    });
  }

  // Agrega un plato.
  Future<void> addItem(String uid, Item item) async {
    await _itemsCollection(uid).add({
      ..._toMap(item),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Modifica un plato existente.
  Future<void> updateItem(
    String uid,
    String documentId,
    Item item,
  ) async {
    await _itemsCollection(uid).doc(documentId).update({
      ..._toMap(item),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Elimina un plato.
  Future<void> deleteItem(
    String uid,
    String documentId,
  ) async {
    await _itemsCollection(uid).doc(documentId).delete();
  }

  // Carga los ejemplos solamente la primera vez de cada usuario.
  Future<void> seedInitialItemsIfEmpty(String uid) async {
    final userRef = firestore.collection('users').doc(uid);
    final itemsRef = _itemsCollection(uid);

    // Comprueba si ya existen platos, por ejemplo, de una ejecución anterior.
    final existingItems = await itemsRef.limit(1).get();

    await firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data();

      // Evita volver a cargar los ejemplos.
      if (userData?['initialItemsSeeded'] == true) {
        return;
      }

      // Solo inserta ejemplos si la colección todavía está vacía.
      if (existingItems.docs.isEmpty) {
        for (final item in _initialItems) {
          final newDocument = itemsRef.doc();

          transaction.set(newDocument, {
            ..._toMap(item),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Guarda la marca incluso si el usuario ya tenía platos.
      transaction.set(
        userRef,
        {
          'initialItemsSeeded': true,
          'initialItemsSeededAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  // Los siete platos iniciales.
  List<Item> get _initialItems => [
        Item(
          name: 'Feijoada',
          origin: 'Brasil',
          rating: 4.8,
          description:
              'Estofado tradicional brasileño hecho con frijoles negros y varias carnes, servido con arroz y farofa.',
          imageUrl:
              'https://images.unsplash.com/photo-1625944525533-473f1b3d54f4?w=800',
          ingredients: [
            'Frijoles negros',
            'Carne de cerdo',
            'Farofa',
          ],
          accompaniments: [
            'Arroz blanco',
            'Naranjas en gajos',
          ],
        ),
        Item(
          name: 'Asado',
          origin: 'Argentina',
          rating: 4.7,
          description:
              'Parrillada clásica argentina: cortes de carne a la parrilla, ahumados lentamente y servidos con chimichurri.',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/4/45/Asado_argentino.jpg',
          ingredients: [
            'Tira de asado',
            'Chorizo',
            'Morcilla',
          ],
          accompaniments: [
            'Chimichurri',
            'Ensalada criolla',
          ],
        ),
        Item(
          name: 'Pizza estilo NY',
          origin: 'Estados Unidos',
          rating: 4.9,
          description:
              'Pizza de masa delgada y bordes crujientes, servida en porciones grandes para llevar y disfrutar al paso.',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/a/a3/Eq_it-na_pizza-margherita_sep2005_sml.jpg',
          ingredients: [
            'Masa fina',
            'Salsa de tomate',
            'Mozzarella',
          ],
          accompaniments: [
            'Pepperoni',
            'Albahaca fresca',
          ],
        ),
        Item(
          name: 'Fish and Chips',
          origin: 'Reino Unido',
          rating: 4.6,
          description:
              'Pescado rebozado y papas fritas crujientes, un clásico británico acompañado de salsa tártara.',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/f/ff/Fish_and_chips_blackpool.jpg',
          ingredients: [
            'Pescado blanco',
            'Rebozado crujiente',
            'Papas fritas',
          ],
          accompaniments: [
            'Salsa tártara',
            'Guisantes triturados',
          ],
        ),
        Item(
          name: 'Pasta Carbonara',
          origin: 'Italia',
          rating: 4.9,
          description:
              'Pasta italiana con salsa cremosa de huevo, queso pecorino y panceta crujiente.',
          imageUrl:
              'https://upload.wikimedia.org/wikipedia/commons/3/33/Espaguetis_carbonara.jpg',
          ingredients: [
            'Spaghetti',
            'Huevos',
            'Panceta',
          ],
          accompaniments: [
            'Queso Pecorino',
            'Pimienta negra',
          ],
        ),
        Item(
          name: 'Churros con Chocolate',
          origin: 'España',
          rating: 4.7,
          description:
              'Dulce tradicional hecho de masa frita espolvoreada con azúcar y acompañado de chocolate caliente para mojar.',
          imageUrl:
              'https://live.staticflickr.com/126/348229335_8e3e9cf4d7_o.jpg',
          ingredients: [
            'Masa frita',
            'Azúcar',
            'Canela',
          ],
          accompaniments: [
            'Chocolate caliente',
            'Café expreso',
          ],
        ),
        Item(
          name: 'Ceviche',
          origin: 'Perú',
          rating: 4.8,
          description:
              'Plato de pescado crudo marinado en jugo de limón, acompañado de cebolla, ají y cilantro.',
          imageUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJ5IzF2akTbFJQdz_6FOyj27_yCxYQ9ADtMUkuTXdxlyNiU8YAOB_eZwY&s=10',
          ingredients: [
            'Pescado fresco',
            'Jugo de limón',
            'Cebolla roja',
          ],
          accompaniments: [
            'Camote',
            'Choclo',
          ],
        ),
      ];
}