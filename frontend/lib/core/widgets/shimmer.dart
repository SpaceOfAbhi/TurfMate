import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:shimmer/shimmer.dart';

class MatchCardShimmer extends StatelessWidget {
  const MatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundColor,
      highlightColor:const Color.fromARGB(255, 4, 59, 17),

      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [

              Container(
                width: 80,
                height: 80,
                color: Colors.white,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Container(
                      height: 18,
                      width: 120,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 14,
                      width: 180,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 14,
                      width: 80,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}