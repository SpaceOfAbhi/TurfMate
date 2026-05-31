import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/match_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchDetailsScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  Map<String, dynamic>? match;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchMatchDetails();
  }

  final MatchService _matchService = MatchService();

  Future<void> fetchMatchDetails() async {
    try {
      final data = await _matchService.getMatchDetails(widget.matchId);

      setState(() {
        match = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> joinMatch() async {
    try {
      await _matchService.joinMatch(matchId: widget.matchId);

      await fetchMatchDetails();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Joined Successfully')));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to join';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> openGoogleMaps() async {
  final latitude = match!['latitude'];
  final longitude = match!['longitude'];

  final uri = Uri.parse(
    'google.navigation:q=$latitude,$longitude',
  );

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (match == null) {
      return const Scaffold(body: Center(child: Text('Match not found')));
    }

    final players = match!['players'];

    return Scaffold(
      appBar: AppBar(title: Text(match!['sport'])),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              match!['turf_name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text('Slots Left: ${match!['available_slots']}'),

            const SizedBox(height: 8),

            Text('₹${match!['amount_per_person']} per player'),

            const SizedBox(height: 8),

            Text(
              'Date: ${DateFormat("dd MMM yyyy").format(DateTime.parse(match!['start_time']))}',
            ),

            const SizedBox(height: 8),
            Text(
              'Start time: ${DateFormat.jm().format(DateTime.parse(match!['start_time']))}',
            ),

            const SizedBox(height: 8),

            Text(
              'End time: ${DateFormat.jm().format(DateTime.parse(match!['end_time']))}',
            ),

            const SizedBox(height: 20),

            const Text(
              'Players',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: players.length,

                itemBuilder: (context, index) {
                  final player = players[index];

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),

                    title: Text(player['name']),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: ()async {
                  await joinMatch();
                },

                child: const Text('Join Match'),
              ),
            ),
            SizedBox(
              width: double.infinity,

              child: OutlinedButton(
                onPressed: openGoogleMaps,

                child: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
