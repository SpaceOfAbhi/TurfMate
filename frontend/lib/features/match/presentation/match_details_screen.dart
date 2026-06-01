import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/core/widgets/background_img.dart';
import 'package:frontend/services/match_service.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final uri = Uri.parse('google.navigation:q=$latitude,$longitude');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppBackground(
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (match == null) {
      return AppBackground(
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text('Match not found')),
        ),
      );
    }

    final players = match!['players'];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'Match Details',
            style: GoogleFonts.anta(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const SizedBox(height: 10),
              Text(
                'Sport: ${match!['sport']}',
                style: GoogleFonts.anta(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Turf: ${match!['turf_name']}',
                style: GoogleFonts.anta(fontSize: 30, fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
              ),
              
              const SizedBox(height: 15),
              Text(
                'Date : ${DateFormat("dd MMM yyyy").format(DateTime.parse(match!['start_time']))}',
                style: GoogleFonts.anta(fontSize: 18),
              ),

             
              Text(
                'Time: ${DateFormat.jm().format(DateTime.parse(match!['start_time']))} — ${DateFormat.jm().format(DateTime.parse(match!['end_time']))}',
                style: GoogleFonts.anta(fontSize: 18),
              ),


              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoBox(
                    icon: '👥',
                    title: 'Available Slots',
                    value: '${match!['available_slots']}',
                  ),
                  InfoBox(
                    icon: '💲',
                    title: 'Split Amount',
                    value: '₹${match!['amount_per_person']}',
                  ),
                ],
              ),

              const SizedBox(height: 8),

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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.borderColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    await joinMatch();
                  },

                  child: const Text('Join Match'),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,

                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.focusColor),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: openGoogleMaps,

                  child: const Text('Get Direction '),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const InfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 120,

      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.focusColor.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 30)),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
