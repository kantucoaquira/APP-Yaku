import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color cardColor;

  const StatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.cardColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                Text(
                  value.toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}