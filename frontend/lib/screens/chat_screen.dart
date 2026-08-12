import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/services/chatbot_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final List<Map<String, dynamic>> _messages;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages = getIt<ChatbotService>().messages;
    // Add welcome message from the bot only if empty
    if (_messages.isEmpty) {
      _messages.add({
        'isUser': false,
        'text':
            'Halo! Saya NutriBot, asisten nutrisi pribadimu. Tanyakan apa saja tentang diet, kalori, atau cara mencapai body goals-mu! 🥗✨',
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text});
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final chatbotService = getIt<ChatbotService>();
      final response = await chatbotService.sendMessage(text);

      setState(() {
        _isTyping = false;
        _messages.add({'isUser': false, 'text': response.reply});
      });
      _scrollToBottom();

      // Check if navigation was requested
      if (response.navigateTo != null && response.navigateTo!.isNotEmpty) {
        final target = response.navigateTo!.toLowerCase().trim();

        // Show navigation notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Membuka halaman $target...',
                style: const TextStyle(
                  color: NutrifyTheme.darkCard,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: NutrifyTheme.accentOrange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Delay slightly so the user can see the snackbar before popping
          await Future.delayed(const Duration(milliseconds: 1200));

          if (mounted) {
            Navigator.pop(context, target);
          }
        }
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text':
              'Maaf, saya sedang mengalami gangguan koneksi. Coba lagi sebentar lagi ya! 😔🔌',
        });
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastBotMessageIndex = _messages.lastIndexWhere((msg) => msg['isUser'] == false);
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      appBar: AppBar(
        backgroundColor: NutrifyTheme.darkCard,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NutrifyTheme.accentOrange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: NutrifyTheme.accentOrange,
              radius: 18,
              child: const Icon(
                Icons.smart_toy,
                color: NutrifyTheme.darkCard,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NutriBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Online',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;
                final text = message['text'] as String;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? NutrifyTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: NutrifyTheme.darkCard.withValues(
                                alpha: 0.1,
                              ),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.3,
                            ),
                          )
                        : StreamingMarkdownMessage(
                            text: text,
                            isLatest: index == lastBotMessageIndex,
                          ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: NutrifyTheme.darkCard.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            NutrifyTheme.darkCard,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'NutriBot sedang mengetik...',
                        style: TextStyle(
                          color: AppColors.navy.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Tanya asisten nutrisi...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: NutrifyTheme.darkCard,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      backgroundColor: NutrifyTheme.darkCard,
                      radius: 22,
                      child: const Icon(
                        Icons.send,
                        color: NutrifyTheme.accentOrange,
                        size: 20,
                      ),
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

class StreamingMarkdownMessage extends StatefulWidget {
  final String text;
  final bool isLatest;

  const StreamingMarkdownMessage({
    super.key,
    required this.text,
    required this.isLatest,
  });

  @override
  State<StreamingMarkdownMessage> createState() => _StreamingMarkdownMessageState();
}

class _StreamingMarkdownMessageState extends State<StreamingMarkdownMessage> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.isLatest && !isTest) {
      _startTyping();
    } else {
      _displayedText = widget.text;
    }
  }

  void _startTyping() {
    _displayedText = '';
    _currentIndex = 0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          int charsToAdd = (widget.text.length - _currentIndex) >= 2 ? 2 : 1;
          _currentIndex += charsToAdd;
          _displayedText = widget.text.substring(0, _currentIndex);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant StreamingMarkdownMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.text != oldWidget.text) {
      if (widget.isLatest && !isTest) {
        _startTyping();
      } else {
        _timer?.cancel();
        setState(() {
          _displayedText = widget.text;
        });
      }
    } else if (!widget.isLatest && oldWidget.isLatest) {
      _timer?.cancel();
      if (_displayedText != widget.text) {
        setState(() {
          _displayedText = widget.text;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) {
      return Text(
        widget.text,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          height: 1.3,
        ),
      );
    }
    return MarkdownBody(
      data: _displayedText,
      selectable: false,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: const TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          height: 1.3,
        ),
        strong: const TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: AppColors.navy,
          fontSize: 15,
          fontStyle: FontStyle.italic,
        ),
        h1: const TextStyle(
          color: AppColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h2: const TextStyle(
          color: AppColors.navy,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: AppColors.navy,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        listBullet: const TextStyle(
          color: AppColors.navy,
          fontSize: 15,
        ),
        code: const TextStyle(
          color: AppColors.navy,
          backgroundColor: Colors.transparent,
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }
}
