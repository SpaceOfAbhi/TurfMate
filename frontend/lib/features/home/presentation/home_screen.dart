import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/background_img.dart';
import 'package:frontend/core/widgets/shimmer.dart';
import 'package:frontend/features/auth/presentation/auth_screen.dart';
import 'package:frontend/features/home/provider/home_provider.dart';
import 'package:frontend/features/match/presentation/match_details_screen.dart';
import 'package:frontend/services/auth_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(nearbyMatchesProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,

          title: const AppTitle(),
          backgroundColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.focusColor,
                ),
                label: Text(
                  "Logout",
                  style: GoogleFonts.anta(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "Logout",
                          style: GoogleFonts.anta(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "Are you sure you want to logout?",
                          style: GoogleFonts.anta(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text("Cancel"),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout != true) return;

                  await AuthService().logout();

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),

        body: matchesAsync.when(
          data: (matches) {
            if (matches.isEmpty) {
              return  Center(
                child: Text(
                  "No matches available",
                  style: GoogleFonts.anta(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.refresh(nearbyMatchesProvider);
              },
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
              
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1.5,
                        ),
                      ),
              
                      clipBehavior: Clip.antiAlias,
              
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MatchDetailsScreen(matchId: match.id),
                            ),
                          );
                        },
              
                        child: SizedBox(
                          height: 180,
              
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                height: double.infinity,
              
                                child: Image.asset(
                                  'assets/sports/${match.sport.toLowerCase()}.jpg',
              
                                  fit: BoxFit.cover,
              
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/sports/default.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
              
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
              
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
              
                                    mainAxisAlignment: MainAxisAlignment.center,
              
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: AppColors.focusColor,
                                          ),
                                          SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              "${match.turfName},${match.locationName}",
                                              style: GoogleFonts.anta(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.date_range_rounded,
                                            color: AppColors.focusColor,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            DateFormat(
                                              "dd MMM yyyy, jm",
                                            ).format(match.startTime),
                                            style: GoogleFonts.anta(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            color: AppColors.focusColor,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            DateFormat.jm().format(
                                              match.startTime,
                                            ),
                                            style: GoogleFonts.anta(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
              
                              Text(
                                '${match.availableSlots} slots',
                                style: GoogleFonts.anta(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.focusColor,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },

          loading: () => ListView.builder(
            itemCount: 3,

            itemBuilder: (_, _) => const MatchCardShimmer(),
          ),

          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
