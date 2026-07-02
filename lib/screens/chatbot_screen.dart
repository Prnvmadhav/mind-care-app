import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String userName;
  final String lastMood;

  const ChatbotScreen({super.key, required this.userName, required this.lastMood});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  Color _getMoodColor(String mood) {
    if (mood.contains('Emotionally Regulated')) return Colors.green;
    if (mood.contains('Mild Cognitive Stress')) return Colors.lightGreen;
    if (mood.contains('Heightened Anxiety')) return Colors.orange;
    if (mood.contains('Emotional Overload')) return Colors.deepOrange;
    if (mood.contains('Severe Distress')) return Colors.red;
    return Colors.teal;
  }

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'bot',
      'text': 'Hi ${widget.userName}, I understand you\'re feeling ${widget.lastMood}. Want to talk about what\'s causing it?'
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    setState(() {
      _messages.add({'sender': 'user', 'text': userText});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final lowerInput = userText.toLowerCase();
    
    // Emergency Detection
    if (lowerInput.contains('suicide') || 
        lowerInput.contains('kill myself') || 
        lowerInput.contains('die') || 
        lowerInput.contains('end my life')) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': "I'm really sorry you're feeling this way. You're not alone. Please consider reaching out to a trusted person or a helpline immediately."
        });
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    // Call API
    final botResponse = await _geminiService.getAIResponse(userText);
    
    if (!mounted) return;
    setState(() {
      _messages.add({
        'sender': 'bot',
        'text': botResponse,
      });
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    Color moodColor = _getMoodColor(widget.lastMood);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindCare Chat'),
        backgroundColor: moodColor.withOpacity(isDark ? 0.2 : 0.8),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Typing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? moodColor.withOpacity(0.8) 
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser 
                            ? Colors.white 
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: moodColor,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
