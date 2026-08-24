import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/datasources/item_remote_datasource.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/entities/item_entity.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/usecases/create_item.dart';

final itemRemoteDataSourceProvider = Provider<ItemRemoteDataSource>((ref) {
  return ItemRemoteDataSource();
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepositoryImpl(
    remoteDataSource: ref.watch(itemRemoteDataSourceProvider),
  );
});

final createItemProvider = Provider<CreateItem>((ref) {
  return CreateItem(repository: ref.watch(itemRepositoryProvider));
});

final itemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  return ref.watch(itemRepositoryProvider).getItems();
});

final myItemsProvider = StreamProvider<List<ItemEntity>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(const <ItemEntity>[]);
      }
      return ref.watch(itemRepositoryProvider).getMyItems(user.uid);
    },
    loading: () => StreamController<List<ItemEntity>>().stream,
    error: (error, stack) => Stream<List<ItemEntity>>.error(error, stack),
  );
});

final itemDetailsProvider = StreamProvider.family<ItemEntity?, String>((
  ref,
  itemId,
) {
  return ref.watch(itemRepositoryProvider).watchItem(itemId);
});
