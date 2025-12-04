// lib/core/usecases/crud_usecases.dart

import '../base/base_entity.dart';
import '../base/crud_repository.dart';

// 1. GET ALL (Hepsini Getir)
class GetAllUseCase<T extends BaseEntity> {
  final CrudRepository<T> repository;

  GetAllUseCase(this.repository);

  Future<List<T>> call() async {
    return await repository.getAll();
  }
}

// 2. GET BY ID (ID'ye Göre Getir)
class GetByIdUseCase<T extends BaseEntity> {
  final CrudRepository<T> repository;

  GetByIdUseCase(this.repository);

  Future<T?> call(int id) async {
    return await repository.getById(id);
  }
}

// 3. CREATE (Oluştur)
class CreateUseCase<T extends BaseEntity> {
  final CrudRepository<T> repository;

  CreateUseCase(this.repository);

  // Generic yapıda repository genellikle ID (int) döner.
  Future<int> call(T entity) async {
    return await repository.create(entity);
  }
}

// 4. UPDATE (Güncelle)
class UpdateUseCase<T extends BaseEntity> {
  final CrudRepository<T> repository;

  UpdateUseCase(this.repository);

  Future<int> call(T entity) async {
    return await repository.update(entity);
  }
}

// 5. DELETE (Sil)
class DeleteUseCase<T extends BaseEntity> {
  final CrudRepository<T> repository;

  DeleteUseCase(this.repository);

  Future<int> call(int id) async {
    return await repository.delete(id);
  }
}
