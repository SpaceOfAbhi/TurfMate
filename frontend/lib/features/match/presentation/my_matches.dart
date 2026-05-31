import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/background_img.dart';
import 'package:frontend/features/match/presentation/players_details_screen.dart';
import 'package:frontend/features/match/provider/my_matches_provider.dart';
import 'package:frontend/services/match_service.dart';

class MyMatchesScreen extends ConsumerWidget {
  const MyMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
             backgroundColor: Colors.transparent,
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
            ref.refresh(myCreatedMatchesProvider);
          },
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final match = data[index];

              return MatchCard(
                match: match,

                isCreatedMatch: true,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerListScreen(matchId: match["id"]),
                    ),
                  );
                },

                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Match?"),
                      content: const Text("This cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;
                  try {
                    await MatchService().deleteMatch(match["id"]);

                    ref.refresh(myCreatedMatchesProvider);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Match deleted")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
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
            ref.refresh(myJoinedMatchesProvider);
          },
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final match = data[index];

              return MatchCard(
                match: match,

                onLeave: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Leave Match?"),
                      content: const Text("Are you sure you want to leave this match?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Leave"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;
                  try {
                    await MatchService().leaveMatch(match["id"]);

                    ref.refresh(myJoinedMatchesProvider);

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Left match")));
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
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

class MatchCard extends StatelessWidget {
  final dynamic match;
  final bool isCreatedMatch;

  final VoidCallback? onDelete;
  final VoidCallback? onLeave;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.isCreatedMatch = false,
    this.onDelete,
    this.onLeave,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

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

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  if (isCreatedMatch)
                    ElevatedButton.icon(
                      onPressed: onDelete,

                      icon: const Icon(Icons.delete),

                      label: const Text("Delete"),
                    ),

                  if (!isCreatedMatch)
                    ElevatedButton.icon(
                      onPressed: onLeave,

                      icon: const Icon(Icons.logout),

                      label: const Text("Leave"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
