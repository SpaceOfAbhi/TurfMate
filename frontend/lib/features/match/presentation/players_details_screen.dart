import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/background_img.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/match_service.dart';

class PlayerListScreen extends StatefulWidget {
  final String matchId;

  const PlayerListScreen({super.key, required this.matchId});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  final MatchService matchService = MatchService();

  late Future<List<dynamic>> playersFuture;

  @override
  void initState() {
    super.initState();

    playersFuture = matchService.getMatchPlayers(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Joined Players",
            style: GoogleFonts.anta(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
        ),

        body: FutureBuilder(
          future: playersFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final players = snapshot.data ?? [];

            if (players.isEmpty) {
              return const Center(child: Text("No players joined"));
            }

            return ListView.builder(
              itemCount: players.length,

              itemBuilder: (context, index) {
                final player = players[index];

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),

                  title: Text(player["name"] ?? ""),

                  subtitle: Text(player["location_name"] ?? ""),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
