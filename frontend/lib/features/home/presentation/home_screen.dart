import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/auth_screen.dart';
import 'package:frontend/features/home/provider/home_provider.dart';
import 'package:frontend/features/match/presentation/match_details_screen.dart';
import 'package:frontend/services/auth_services.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(nearbyMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Turf Mate"),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {
              await AuthService().logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
     
      body: matchesAsync.when(
        data: (matches) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(nearbyMatchesProvider);
            },
            child: ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];

                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => MatchDetailsScreen(matchId: match.id),
                        ),
                      );
                    },
                    title: Text(match.sport),
                    subtitle: Text(match.turfName),
                    trailing: Text('${match.availableSlots} slots'),
                  ),
                );
              },
            ),
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
