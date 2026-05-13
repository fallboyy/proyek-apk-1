import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class PrayerCard extends StatelessWidget {
  final PrayerType type;
  final DateTime time;
  final bool isNext; // Apakah ini sholat berikutnya?
  final bool isCurrent; // Apakah ini sholat saat ini?

  const PrayerCard({
    super.key,
    required this.type,
    required this.time,
    this.isNext = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan warna accent untuk card sholat berikutnya
    final backgroundColor = isNext
        ? AppColors.primaryGreen.withValues(alpha: 0.15)
        : (isCurrent
            ? AppColors.teal.withValues(alpha: 0.05)
            : Theme.of(context).cardColor);

    final borderColor = isNext
        ? AppColors.primaryGreen
        : (isCurrent ? AppColors.teal : Colors.transparent);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: isNext ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Ikon dan Nama Sholat
            Row(
              children: [
                Text(
                  type.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isNext || isCurrent
                        ? FontWeight.bold
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Jam Sholat
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(time),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isNext ? AppColors.primaryGreen : null,
                  ),
                ),
                if (isNext)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Berikutnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isCurrent && !isNext)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
