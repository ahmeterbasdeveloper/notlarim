import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/di/core_providers.dart';

import '../../domain/repositories/kullanici_repository.dart';
import '../../data/repositories/kullanici_repository_impl.dart';

// UseCases
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/verify_user.dart';
import '../../domain/usecases/update_password.dart';

// REPOSITORY
final kullaniciRepositoryProvider = Provider<KullaniciRepository>((ref) {
  return KullaniciRepositoryImpl(ref.watch(dbServiceProvider));
});

// USECASES
final loginUserProvider =
    Provider((ref) => LoginUser(ref.watch(kullaniciRepositoryProvider)));

final verifyUserProvider =
    Provider((ref) => VerifyUser(ref.watch(kullaniciRepositoryProvider)));

final updatePasswordProvider =
    Provider((ref) => UpdatePassword(ref.watch(kullaniciRepositoryProvider)));
