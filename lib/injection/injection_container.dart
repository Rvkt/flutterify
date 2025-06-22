import 'package:flutterify/core/network/service/api_service.dart';
import 'package:flutterify/features/products/bloc/product_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => ProductBloc(apiService: sl()));

  // Services
  sl.registerLazySingleton<ApiService>(() => ApiService());
}
