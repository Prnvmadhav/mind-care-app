import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class ResultScreen extends StatelessWidget {
  final String userName;
  final String stressLevel;

  const ResultScreen({super.key, required this.userName, required this.stressLevel});

  Color _getMoodColor() {
    if (stressLevel.contains('Emotionally Regulated')) return Colors.green;
    if (stressLevel.contains('Mild Cognitive Stress')) return Colors.lightGreen;
    if (stressLevel.contains('Heightened Anxiety')) return Colors.orange;
    if (stressLevel.contains('Emotional Overload')) return Colors.deepOrange;
    return Colors.red;
  }

  String _getExplanation() {
    if (stressLevel.contains('Emotionally Regulated')) {
      return "You seem to be in a balanced and peaceful state. Keep practicing your healthy habits!";
    } else if (stressLevel.contains('Mild Cognitive Stress')) {
      return "You are experiencing some mild mental fatigue. It is a good time to take brief breaks throughout your day.";
    } else if (stressLevel.contains('Heightened Anxiety')) {
      return "Your responses indicate signs of heightened anxiety, which may involve persistent worry and mental fatigue.";
    } else if (stressLevel.contains('Emotional Overload')) {
      return "You appear to be dealing with significant emotional pressure. It's crucial to give yourself grace and step back.";
    } else {
      return "Your responses suggest intense distress. Please remember you don't have to carry this alone—consider reaching out to a support system.";
    }
  }

  @override
  Widget build(BuildContext context) {
    Color moodColor = _getMoodColor();
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.self_improvement, size: 80, color: moodColor),
              const SizedBox(height: 24),
              const Text(
                'Check-in Complete',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '${userName}, your current mental state indicates:\n',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                stressLevel,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: moodColor),
              ),
              const SizedBox(height: 24),
              Text(
                _getExplanation(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: moodColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final List<String> moodHistory = ['Mild Cognitive Stress 🙂', 'Heightened Anxiety 😟', stressLevel];

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                          userName: userName,
                          currentMood: stressLevel,
                          moodHistory: moodHistory,
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Dashboard', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
