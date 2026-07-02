import 'package:flutter/material.dart';
import 'result_screen.dart';

class SurveyScreen extends StatefulWidget {
  final String userName;
  
  const SurveyScreen({super.key, required this.userName});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _score = 0;
  int _currentQuestionIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How often do you feel mentally exhausted without a clear reason?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'Do you find yourself overthinking social interactions after they happen?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'Do you avoid situations due to fear of judgment?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'How often do you experience racing thoughts or difficulty focusing?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'Do you feel emotionally disconnected from people around you?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'How often have you felt down, depressed, or hopeless?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'Are you having trouble sleeping or staying asleep?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
    {
      'question': 'How often have you felt nervous or on edge recently?',
      'options': ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      'scores': [0, 1, 2, 3],
    },
  ];

  void _answerQuestion(int score) {
    setState(() {
      _score += score;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        String stressLevel = 'Emotionally Regulated 😊';
        if (_score >= 20) {
          stressLevel = 'Severe Distress 😞';
        } else if (_score >= 15) {
          stressLevel = 'Emotional Overload 😣';
        } else if (_score >= 10) {
          stressLevel = 'Heightened Anxiety 😟';
        } else if (_score >= 5) {
          stressLevel = 'Mild Cognitive Stress 🙂';
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              userName: widget.userName, 
              stressLevel: stressLevel
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                question['question'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ...List.generate(
                question['options'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _answerQuestion(question['scores'][index]),
                    child: Text(question['options'][index], style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}
