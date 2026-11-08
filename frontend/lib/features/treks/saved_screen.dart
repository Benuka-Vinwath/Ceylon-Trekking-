import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/api.dart';
import '../../data/models.dart';
import 'home_screen.dart';

class SavedTreksScreen extends StatelessWidget {
  const SavedTreksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Loader<List<Trek>>(
          load: Api.saved,
          builder: (treks, reload) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Row(children: const [BackCircle(), Expanded(child: Center(child: Text('Saved treks', style: AppText.h2))), SizedBox(width: 40)]),
              const SizedBox(height: 16),
              Text(treks.isEmpty ? 'No saved treks yet. Tap the heart on a trek to save it.' : '${treks.length} treks saved', style: AppText.small),
              const SizedBox(height: 12),
              // reload on return, in case the heart was turned off on the detail screen
              ...treks.map((t) => TrekListTile(trek: t, saved: true, onTap: () => openTrek(context, t).then((_) => reload()))),
            ],
          ),
        ),
      ),
    );
  }
}
