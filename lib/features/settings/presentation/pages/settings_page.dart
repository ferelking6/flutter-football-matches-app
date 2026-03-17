import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tornet_task/generated/l10n/app_localizations.dart';
import 'package:tornet_task/core/theme/theme_exports.dart';
import 'package:tornet_task/core/constants/app_mode_provider.dart';
import 'package:tornet_task/features/matches/presentation/bloc/matches_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<bool> _isDemoMode;

  @override
  void initState() {
    super.initState();
    _isDemoMode = AppModeProvider.isDemoMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Mode Section
          SizedBox(
            height: 24,
            child: Text(
              'App Mode',
              style: AppTextStyles.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<bool>(
            future: _isDemoMode,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final isDemo = snapshot.data ?? true;

              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDemo ? '🎮 DEMO MODE' : '🚀 LIVE MODE',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: isDemo
                                      ? AppColors.accent
                                      : AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDemo
                                    ? 'Using mock data'
                                    : 'Using real API data',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: !isDemo,
                            onChanged: (value) async {
                              await AppModeProvider.setDemoMode(!value);
                              setState(() {
                                _isDemoMode =
                                    AppModeProvider.isDemoMode();
                              });

                              // Reload matches
                              if (mounted) {
                                context.read<MatchesBloc>().add(
                                      LoadTodayMatchesEvent(),
                                    );
                                context.read<MatchesBloc>().add(
                                      LoadYesterdayMatchesEvent(),
                                    );
                                context.read<MatchesBloc>().add(
                                      LoadTomorrowMatchesEvent(),
                                    );
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value
                                      ? '🚀 Switched to LIVE mode'
                                      : '🎮 Switched to DEMO mode'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // API Information Section
          SizedBox(
            height: 24,
            child: Text(
              'API Information',
              style: AppTextStyles.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Staging API',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'https://staging.torliga.com/api/v1',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Production API',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'https://torliga.com/api/v1',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Info Section
          Card(
            margin: EdgeInsets.zero,
            color: AppColors.surface.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📱 Football Matches App v1.0.1\n'
                    '⚽ Real-time match data and predictions\n'
                    '🎯 Get the latest fixtures and results',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
