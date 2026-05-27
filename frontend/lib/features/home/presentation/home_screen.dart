import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/home/provider/home_provider.dart';
import 'package:frontend/features/match_details/pesentation/matchDetails_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(nearbyMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Matches')),

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
