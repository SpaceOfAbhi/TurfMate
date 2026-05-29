import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/match/presentation/players_details_screen.dart';
import 'package:frontend/features/match/provider/my_matches_provider.dart';

class MyMatchesScreen extends ConsumerWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Matches"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Created"),
              Tab(text: "Joined"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [CreatedMatchesTab(), JoinedMatchesTab()],
        ),
      ),
    );
  }
}

class CreatedMatchesTab extends ConsumerWidget {
  const CreatedMatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(myCreatedMatchesProvider);

    return matches.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text("No created matches"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myCreatedMatchesProvider);
          },
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final match = data[index];

              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Tapped")));
                },
                child: MatchCard(match: match),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class JoinedMatchesTab extends ConsumerWidget {
  const JoinedMatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(myJoinedMatchesProvider);

    return matches.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text("No joined matches"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myJoinedMatchesProvider);
          },
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final match = data[index];

              return MatchCard(match: match);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}

class MatchCard extends StatelessWidget {
  final dynamic match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) => PlayerListScreen(matchId: match["id"]),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match["sport"] ?? "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(match["turf_name"] ?? ""),

              const SizedBox(height: 8),

              Text(
                "Slots: ${match["available_slots"]}/${match["total_slots"]}",
              ),

              const SizedBox(height: 8),

              Text("₹${match["amount_per_person"]}"),

              const SizedBox(height: 8),

              Text(match["start_time"].toString()),
            ],
          ),
        ),
      ),
    );
  }
}
