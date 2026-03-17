import 'package:flutter/foundation.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/matches_repository.dart';
import '../datasources/matches_remote_data_source.dart';
import '../datasources/matches_websocket_data_source.dart';
import '../../../../core/network/network_info.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final MatchesRemoteDataSource remoteDataSource;
  final MatchesWebSocketDataSource webSocketDataSource;
  final NetworkInfo networkInfo;

  MatchesRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Match>> getTodayMatches() async {
    if (await networkInfo.isConnected) {
      try {
        final matches = await remoteDataSource.getTodayMatches();
        return matches;
      } catch (e) {
        throw Exception('Failed to get today\'s matches: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<Match>> getYesterdayMatches() async {
    if (await networkInfo.isConnected) {
      try {
        final matches = await remoteDataSource.getYesterdayMatches();
        return matches;
      } catch (e) {
        throw Exception('Failed to get yesterday\'s matches: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<List<Match>> getTomorrowMatches() async {
    if (await networkInfo.isConnected) {
      try {
        final matches = await remoteDataSource.getTomorrowMatches();
        return matches;
      } catch (e) {
        throw Exception('Failed to get tomorrow\'s matches: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Stream<Match> getMatchUpdates() {
    debugPrint('🔄 Repository: Starting WebSocket listening...');
    webSocketDataSource.startListening();
    final stream = webSocketDataSource.getMatchUpdates();
    debugPrint('🔄 Repository: Returning match updates stream');
    return stream.map((match) {
      debugPrint('🔄 Repository: Match update flowing through: ${match.id}');
      return match;
    });
  }
} 