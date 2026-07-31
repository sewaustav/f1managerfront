import 'package:flutter/material.dart';
import '../../model/track_info.dart';

class TrackCard extends StatelessWidget {
  const TrackCard(this.track, {super.key});
  final TrackInfo track;

  @override
  Widget build(BuildContext context) {
    final typeLabel = track.type == 1 ? 'City' : 'Classic';
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(track.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Type: $typeLabel'),
            Text('Difficulty: ${track.difficulty}'),
            Text('Rain: ${track.rainPossibility}%'),
            Text('Tyre wear: ${track.tyre}'),
          ],
        ),
      ),
    );
  }
}
