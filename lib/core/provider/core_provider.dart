import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/dio_provider.dart';
import '../services/secure_storage_service.dart';

final flutterStorageProvider =
    Provider(
  (_) => const FlutterSecureStorage(),
);

final secureStorageProvider =
    Provider(
  (ref) => SecureStorageService(
    ref.read(
      flutterStorageProvider,
    ),
  ),
);

final apiClientProvider =
    Provider(
  (ref) => ApiClient(
    ref.read(dioProvider),
  ),
);