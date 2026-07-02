import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import '../main.dart'; 

class DashboardScreen extends StatelessWidget {
  final String userName;
  final String currentMood;
  final List<String> moodHistory;

  const DashboardScreen({
    super.key, 
    required this.userName, 
    required this.currentMood,
    required this.moodHistory,
  });

  Color _getMoodColor(String mood) {
    if (mood.contains('Emotionally Regulated')) return Colors.green;
    if (mood.contains('Mild Cognitive Stress')) return Colors.lightGreen;
    if (mood.contains('Heightened Anxiety')) return Colors.orange;
    if (mood.contains('Emotional Overload')) return Colors.deepOrange;
    if (mood.contains('Severe Distress')) return Colors.red;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    Color moodColor = _getMoodColor(currentMood);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => 
                      RotationTransition(turns: animation, child: ScaleTransition(scale: animation, child: child)),
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny,
                    key: ValueKey(isDark ? 'dark' : 'light'),
                    color: isDark ? Colors.blue.shade200 : Colors.orange,
                  ),
                ),
                onPressed: () {
                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, $userName!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shadowColor: moodColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: moodColor.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Your Current State',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentMood,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: moodColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mood History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: moodHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.history, color: _getMoodColor(moodHistory[index])),
                    title: Text(moodHistory[index], style: const TextStyle(fontSize: 16)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start Chat', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: moodColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatbotScreen(
                      userName: userName,
                      lastMood: currentMood,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
