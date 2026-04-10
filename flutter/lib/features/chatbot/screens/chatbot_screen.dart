import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../services/stt_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String scanContext;
  final String productName;
  final String preferredLanguage;
  const ChatbotScreen({
    super.key,
    required this.scanContext,
    required this.productName,
    this.preferredLanguage = 'en',
  });
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, String>> _messages = [];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = false;
  final _stt = SttService();
  bool _isListening = false;

  static const _suggestions = [
    'Is this safe for my baby?',
    'What is the most harmful ingredient?',
    'Is this pregnancy safe?',
    'What should I avoid?',
  ];
  @override
  void initState() {
    super.initState();
    _stt.init(); // ADD THIS LINE
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future _toggleListening() async {
    if (_isListening) {
      await _stt.stop();
      if (mounted) setState(() => _isListening = false);
    } else {
      if (!_stt.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone not available on this device'),
          ),
        );
        return;
      }
      setState(() => _isListening = true);
      await _stt.listen(
        localeId: widget.preferredLanguage == 'hi' ? 'hi_IN' : 'en_US',
        onResult: (text) {
          if (mounted) {
            _controller.text = text;
            setState(() => _isListening = false);
            _send(text);
          }
        },
      );
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    final userMsg = text.trim();
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': userMsg});
      _loading = true;
    });
    _scrollToBottom();
    try {
      final history = _messages
          .take(_messages.length - 1)
          .map((m) => {'role': m['role']!, 'content': m['content']!})
          .toList();
      final result = await ApiService().chatbot(
        message: userMsg,
        scanContext: widget.scanContext,
        userProfile: {},
        conversationHistory: history,
        targetLanguage: widget.preferredLanguage,
      );
      final reply = result['translated_text'] as String? ??
          result['response_text'] as String? ??
          'Sorry, no response.';
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Something went wrong. Please try again.',
          });
          _loading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppColors.green, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SafeScan AI',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Ask about ${widget.productName}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF888888))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: _messages.isEmpty
              ? _buildSuggestions()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_loading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)
                                .copyWith(bottomLeft: const Radius.circular(4)),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.green),
                                ),
                                SizedBox(width: 8),
                                Text('Thinking...',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888))),
                              ]),
                        ),
                      );
                    }
                    final msg = _messages[i];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.green : Colors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight:
                                isUser ? const Radius.circular(4) : null,
                            bottomLeft:
                                !isUser ? const Radius.circular(4) : null,
                          ),
                          border: isUser
                              ? null
                              : Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          msg['content']!,
                          style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFF111111),
                              fontSize: 13,
                              height: 1.5),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 8,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderLight))),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Listening...'
                      : 'Ask anything about this product...',
                  filled: true,
                  fillColor: _isListening
                      ? AppColors.greenLight
                      : AppColors.subtleLight,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: _send,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            // Mic button
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.red : AppColors.subtleLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color:
                          _isListening ? AppColors.red : AppColors.borderLight),
                ),
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_outlined,
                  color: _isListening ? Colors.white : const Color(0xFF555555),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            GestureDetector(
              onTap: () => _send(_controller.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Suggested questions',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF888888))),
        const SizedBox(height: 12),
        ..._suggestions.map((s) => GestureDetector(
              onTap: () => _send(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(children: [
                  const Icon(Icons.help_outline_rounded,
                      size: 16, color: AppColors.green),
                  const SizedBox(width: 10),
                  Text(s, style: const TextStyle(fontSize: 13)),
                ]),
              ),
            )),
      ],
    );
  }
}
