import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../services/websocket_service.dart';
import '../services/websocket_config.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

// Matches feature imports
import '../../features/matches/presentation/bloc/matches_bloc.dart';
import '../../features/matches/domain/usecases/get_today_matches.dart';
import '../../features/matches/domain/usecases/get_yesterday_matches.dart';
import '../../features/matches/domain/usecases/get_tomorrow_matches.dart';
import '../../features/matches/domain/usecases/get_match_updates.dart';
import '../../features/matches/domain/repositories/matches_repository.dart';
import '../../features/matches/data/repositories/matches_repository_impl.dart';
import '../../features/matches/data/datasources/matches_remote_data_source.dart';
import '../../features/matches/data/datasources/matches_websocket_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<Dio>(() => Dio());
  
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
  
  // Core Services
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(),
  );
  
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorageImpl(),
  );
  
  sl.registerLazySingleton<ApiService>(() => ApiServiceImpl());
  
  sl.registerLazySingleton<WebSocketService>(
    () => WebSocketServiceImpl(
      config: WebSocketConfig.getConfig(ApiConstants.wsEnvironment), // Use staging for real data
    ),
  );

  // Feature - Matches
  // Data sources
  sl.registerLazySingleton<MatchesRemoteDataSource>(
    () => MatchesRemoteDataSourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<MatchesWebSocketDataSource>(
    () => MatchesWebSocketDataSourceImpl(webSocketService: sl()),
  );

  // Repository
  sl.registerLazySingleton<MatchesRepository>(
    () => MatchesRepositoryImpl(
      remoteDataSource: sl(),
      webSocketDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => GetTodayMatches(sl()));
  sl.registerLazySingleton(() => GetYesterdayMatches(sl()));
  sl.registerLazySingleton(() => GetTomorrowMatches(sl()));
  sl.registerLazySingleton(() => GetMatchUpdates(sl()));
  
  // BLoC
  sl.registerFactory(
    () => MatchesBloc(
      getTodayMatches: sl(),
      getYesterdayMatches: sl(),
      getTomorrowMatches: sl(),
      getMatchUpdates: sl(),
    ),
  );
} 