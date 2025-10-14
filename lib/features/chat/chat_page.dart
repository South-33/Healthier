import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthier/features/reference/widgets/glassmorphic_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthier/data/repositories/conversation_repository.dart';
import 'package:healthier/data/models/message.dart' as model;
import 'package:healthier/data/models/conversation.dart' as convo;

// API key handling
// - Preferred for dev: run with dart-define so the key isn't committed.
//   flutter run --dart-define=GEMINI_API_KEY=your_key_here
// - Convenience: we also support storing the key locally via SharedPreferences.
const String _envApiKey = String.fromEnvironment('GEMINI_API_KEY');
const String _prefsApiKeyKey = 'gemini_api_key';
const String _prefsSystemPromptKey = 'system_prompt';
const String _prefsConversationIdKey = 'current_conversation_id';

// Default system prompt for the assistant persona and safety rails.
const String _defaultSystemPrompt =
    'You are Healthier, a friendly, concise health companion. '
    'Use the user\'s data when available, cite assumptions, avoid medical advice. '
    'Keep answers short, clear, actionable.';

const String _titleGuidance =
    'Title protocol:\n'
    '- Each user message starts with [current_title:TITLE NAME].\n'
    '- Keep the chat title aligned with the most recent topic.\n'
    '- When a rename is warranted, include exactly one token [title:New Title] in your reply.\n'
    '- Titles must be 3-6 words, Title Case, no trailing punctuation, no PHI, and avoid generic words (chat, conversation, assistant, ai, bot).\n'
    '- Ignore brief acknowledgments or fillers (ok, thanks, sure) when considering renames. Focus on substantive topic shifts.\n'
    '- Do not echo the [current_title:...] token back in your response; treat it as metadata only.\n'
    '- If no rename is needed, do not emit the [title:...] token.';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.tabActiveNotifier});
  final ValueListenable<bool>? tabActiveNotifier;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          double dotOpacity(int i) {
            final phase = (t * 3 - i) % 3; // staggered 0..3
            return phase < 1 ? phase : (phase < 2 ? 2 - phase : 0);
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(3, (i) {
                return Opacity(
                  opacity: 0.25 + 0.75 * dotOpacity(i).clamp(0, 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_Message> _messages = <_Message>[];
  bool _isLoading = false;
  bool _loadingPrefs = true;
  final ConversationRepository _repo = ConversationRepository();
  String? _conversationId;
  StreamSubscription<List<model.Message>>? _messagesSub;
  StreamSubscription<convo.Conversation?>? _convSub;
  String? _initError;

  // Settings (can come from dart-define or SharedPreferences)
  String _apiKey = _envApiKey;
  String _systemPrompt = _defaultSystemPrompt;
  final TextEditingController _apiKeyInputController = TextEditingController();
  String? _sharedApiKey;
  bool _hasUserOverride = false;

  GenerativeModel? _model;
  ChatSession? _chat;
  String _appBarTitle = 'AI Chat';

  String get _systemPromptWithTitleGuidance {
    final base = _systemPrompt.trim();
    return [base, _titleGuidance].where((s) => s.isNotEmpty).join('\n\n');
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    widget.tabActiveNotifier?.addListener(_onTabActiveChanged);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_prefsApiKeyKey);
    final savedPrompt = prefs.getString(_prefsSystemPromptKey);
    final savedConv = prefs.getString(_prefsConversationIdKey);
    if (savedKey != null && savedKey.isNotEmpty) {
      _apiKey = savedKey;
      _hasUserOverride = true;
    }
    if (savedPrompt != null && savedPrompt.isNotEmpty) {
      _systemPrompt = savedPrompt;
    }
    if (savedConv != null && savedConv.isNotEmpty) {
      _conversationId = savedConv;
    }
    try {
      _sharedApiKey = await _fetchSharedApiKey();
      if (!_hasUserOverride && (_sharedApiKey?.isNotEmpty ?? false)) {
        _apiKey = _sharedApiKey!;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load shared Gemini key: $e');
      }
    }
    await _configureModelAndChat();
    // After configuring model, ensure Firestore conversation and subscribe
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await _ensureConversationAndSubscribe();
      }
    } catch (e) {
      // Common cause: Firestore rules not deployed → permission-denied
      _initError = 'Could not initialize chat (check Firestore rules).';
    }
    setState(() {
      _loadingPrefs = false;
    });
  }

  Future<String?> _fetchSharedApiKey() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('config')
          .doc('ai')
          .get();
      final data = snapshot.data();
      final key = data?['geminiApiKey'];
      if (key is String) {
        final trimmed = key.trim();
        if (trimmed.isNotEmpty) {
          return trimmed;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Shared Gemini key fetch error: $e');
      }
    }
    return null;
  }

  Future<void> _configureModelAndChat() async {
    if (_apiKey.isEmpty) {
      if (mounted) {
        setState(() {
          _model = null;
          _chat = null;
          _initError = 'Gemini key missing. Add one in settings or create field config/ai.geminiApiKey.';
        });
      }
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(_systemPromptWithTitleGuidance),
    );
    _chat = null;
    if (mounted) {
      setState(() {
        _initError = null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _messagesSub?.cancel();
    _convSub?.cancel();
    widget.tabActiveNotifier?.removeListener(_onTabActiveChanged);
    super.dispose();
  }

  Future<void> _ensureConversationAndSubscribe() async {
    if (_conversationId == null) {
      // Create a new conversation for this session
      _conversationId = await _repo.createConversation(
        title: 'New chat',
        model: 'gemini-2.5-flash',
        systemPrompt: _systemPrompt,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsConversationIdKey, _conversationId!);
    }
    _messagesSub?.cancel();
    _messagesSub = _repo.watchMessages(_conversationId!).listen((items) {
      // Map Firestore messages to UI messages
      final mapped = items
          .where((m) => m.role == 'user' || m.content.trim().isNotEmpty)
          .map((m) => _Message(m.content, m.role == 'user'))
          .toList(growable: false);
      setState(() {
        _messages
          ..clear()
          ..addAll(mapped);
      });
      _scrollToBottom();
    });
    // Watch the conversation doc for title updates
    _convSub?.cancel();
    _convSub = _repo.watchConversation(_conversationId!).listen((c) {
      final title = (c == null) ? '' : (c.title).trim();
      setState(() {
        _appBarTitle = title.isNotEmpty ? title : 'New chat';
      });
    });
    // Prime the model with existing conversation history for context
    if (_model != null) {
      final historyMsgs = await _repo.fetchAllMessages(_conversationId!);
      final historyContent = <Content>[];
      for (final msg in historyMsgs) {
        final txt = msg.content.trim();
        if (txt.isEmpty) continue;
        historyContent.add(Content(
          msg.role == 'user' ? 'user' : 'model',
          [TextPart(txt)],
        ));
      }
      _chat = _model!.startChat(history: historyContent.isEmpty ? null : historyContent);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _chat == null || _conversationId == null) return;
    setState(() {
      _isLoading = true;
    });
    final convId = _conversationId!;
    final userMessage = text.trim();
    _controller.clear();
    _scrollToBottom();

    final buffer = StringBuffer();
    String? assistantMessageId;
    DateTime lastWrite = DateTime.fromMillisecondsSinceEpoch(0);
    String? pendingTitle;

    try {
      // Persist user message
      await _repo.addUserMessage(convId, userMessage);
      // Create assistant placeholder
      assistantMessageId = await _repo.addAssistantPlaceholder(convId);

      final formattedForModel = _formatUserMessageForModel(userMessage);
      final stream = _chat!.sendMessageStream(Content.text(formattedForModel));
      await for (final response in stream) {
        final chunk = response.text ?? '';
        if (chunk.isEmpty) continue;
        if (kDebugMode) {
          debugPrint('AI chunk for $convId: $chunk');
        }
        buffer.write(chunk);
        final parsed = _splitAssistantResponse(buffer.toString());
        final cleanText = parsed.cleaned;
        if (parsed.title != null && parsed.title!.isNotEmpty) {
          pendingTitle = parsed.title;
        }
        final now = DateTime.now();
        if (now.difference(lastWrite) > const Duration(milliseconds: 150)) {
          lastWrite = now;
          await _repo.updateAssistantMessage(convId, assistantMessageId!, cleanText);
        }
        _scrollToBottom();
      }
      // Finalize assistant message
      if (assistantMessageId != null) {
        if (kDebugMode) {
          debugPrint('AI full response for $convId: ${buffer.toString()}');
        }
        final parsed = _splitAssistantResponse(buffer.toString());
        final cleanText = parsed.cleaned;
        if (parsed.title != null && parsed.title!.isNotEmpty) {
          pendingTitle = parsed.title;
        }
        await _repo.updateAssistantMessage(convId, assistantMessageId, cleanText, isFinal: true);
      }
      if (pendingTitle != null && pendingTitle!.isNotEmpty) {
        await _repo.renameConversation(convId, pendingTitle!);
      }
    } catch (e) {
      // Write error state to message if placeholder exists
      if (assistantMessageId != null) {
        await _repo.updateAssistantMessage(convId, assistantMessageId, 'Error: $e', isFinal: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _appBarTitle,
          style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            tooltip: 'Conversations',
            icon: const Icon(Icons.history),
            onPressed: _openConversationPicker,
            color: Colors.black87,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: _openSettingsSheet,
            color: Colors.black87,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/green-brush-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            if (_initError != null)
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _initError!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Builder(builder: (context) {
                final bool showThinking = _isLoading && (_messages.isEmpty || _messages.last.isUser);
                final int count = _messages.length + (showThinking ? 1 : 0);
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(
                    12,
                    MediaQuery.of(context).padding.top + kToolbarHeight - 12,
                    12,
                    12,
                  ),
                  itemCount: count,
                  itemBuilder: (context, index) {
                    // Ephemeral in-thread thinking bubble at the end while streaming
                    if (showThinking && index == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  child: _TypingIndicator(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final m = _messages[index];
                    final isUser = m.isUser;
                    return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: isUser
                        ? GlassmorphicContainer(
                            borderRadius: 20,
                            blur: 10,
                            color: Theme.of(context).colorScheme.primary,
                            opacity: 0.08,
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              width: 1,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              child: SelectableText(
                                m.text,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.black87),
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  child: MarkdownBody(
                                    data: m.text,
                                    styleSheet: MarkdownStyleSheet.fromTheme(
                                      Theme.of(context),
                                    ).copyWith(
                                      p: Theme.of(context)
                                          .textTheme
                                          .bodyLarge,
                                      h1: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(fontSize: 28),
                                      h2: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                      code: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            fontFamily: 'monospace',
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                );
                  },
                );
              }),
            ),
            SafeArea(
              top: false,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: GlassmorphicContainer(
                blur: 10,
                borderRadius: 20,
                color: Colors.white,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted:
                              _isLoading ? null : (v) => _sendMessage(v),
                          decoration: const InputDecoration(
                            hintText: 'Ask a question...',
                            filled: true,
                            fillColor: Color(0xFFF7F6F4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : () => _sendMessage(_controller.text),
                        icon: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : const Icon(Icons.arrow_upward_rounded, size: 28),
                        tooltip: 'Send',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _MissingApiKeyView extends StatelessWidget {
  const _MissingApiKeyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Gemini API key required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'To enable the AI chat, run the app with your Gemini API key:\n\n'
            'flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY',
          ),
          SizedBox(height: 12),
          Text(
            'You can obtain an API key from Gemini AI Studio. Do not hardcode the key into the source code.',
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  const _Message(this.text, this.isUser);
  factory _Message.user(String text) => _Message(text, true);
  factory _Message.assistant(String text) => _Message(text, false);
}

extension on _ChatPageState {
  void _onTabActiveChanged() {
    // Titles are now handled inline via assistant responses; no action needed here.
  }

  ({String cleaned, String? title}) _splitAssistantResponse(String raw) {
    String? title;
    String cleaned = raw;
    try {
      final titleRegex = RegExp(r'\[title:([^\]]+)\]', caseSensitive: false);
      final matches = titleRegex.allMatches(raw);
      if (matches.isNotEmpty) {
        final last = matches.last;
        title = _sanitizeTitle(last.group(1) ?? '');
      }
      final intermediate = raw.replaceAll(titleRegex, '');
      cleaned = intermediate.replaceAll(RegExp(r'\[current_title:[^\]]*\]', caseSensitive: false), '').trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Title parsing failed: $e for raw: $raw');
      }
      cleaned = raw.replaceAll(RegExp(r'\[current_title:[^\]]*\]', caseSensitive: false), '').trim();
    }
    return (cleaned: cleaned, title: title);
  }

  String _formatUserMessageForModel(String text) {
    final title = _appBarTitle.trim().isEmpty ? 'New chat' : _appBarTitle.trim();
    return '[current_title:$title]\n$text'.trim();
  }

  String _sanitizeTitle(String raw) {
    var t = raw.trim();
    if (t.isEmpty) return '';
    // take the first non-empty line
    t = t.split('\n').map((s) => s.trim()).firstWhere((s) => s.isNotEmpty, orElse: () => '');
    // strip bullets/markdown markers and prefixes
    t = t.replaceAll(RegExp(r'^[-*•\s]+'), '');
    t = t.replaceAll(RegExp(r'^(title\s*:\s*)', caseSensitive: false), '');
    // remove surrounding quotes and trailing punctuation
    t = t.replaceAll(RegExp("^[\"']|[\"']\$"), '').replaceAll(RegExp(r'[\.:!?]$'), '');
    // limit to 6 words
    final words = t.split(RegExp('\\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    t = words.take(6).join(' ');
    // Title Case
    return _toTitleCase(t);
  }

  String _toTitleCase(String input) {
    final small = {'a','an','the','and','or','but','for','nor','on','at','to','from','by','of'};
    final words = input.toLowerCase().split(RegExp('\\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      if (i == 0 || !small.contains(w)) {
        words[i] = w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : '');
      }
    }
    return words.join(' ');
  }

  int _wordCount(String s) => s.trim().isEmpty ? 0 : s.trim().split(RegExp('\\s+')).length;
  int _userMessageCount(List<model.Message> msgs) =>
      msgs.where((m) => m.role == 'user' && m.content.trim().isNotEmpty).length;

  Future<void> _openConversationPicker() async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: StreamBuilder(
            stream: _repo.watchConversations(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];
              return Column(
                children: [
                  ListTile(
                    title: const Text('Conversations', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final id = await _repo.createConversation(
                          title: 'New chat',
                          model: 'gemini-2.5-flash',
                          systemPrompt: _systemPrompt,
                        );
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(_prefsConversationIdKey, id);
                        setState(() {
                          _conversationId = id;
                        });
                        await _ensureConversationAndSubscribe();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final convo.Conversation c = items[index];
                        final selected = c.id == _conversationId;
                        return ListTile(
                          title: Text(c.title.isEmpty ? 'Untitled' : c.title),
                          subtitle: Text(c.updatedAt?.toLocal().toString() ?? ''),
                          leading: Icon(
                            selected ? Icons.chat_bubble : Icons.chat_bubble_outline,
                            color: selected ? Theme.of(context).colorScheme.primary : null,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Rename',
                                icon: const Icon(Icons.edit),
                                onPressed: () => _promptRenameConversation(c),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDeleteConversation(c),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final prev = _conversationId;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(_prefsConversationIdKey, c.id);
                            setState(() {
                              _conversationId = c.id;
                            });
                            await _ensureConversationAndSubscribe();
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _promptRenameConversation(convo.Conversation c) async {
    final controller = TextEditingController(text: c.title);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                await _repo.renameConversation(c.id, title);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteConversation(convo.Conversation c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text('This will delete all messages in this conversation.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    await _repo.deleteConversation(c.id);
    // If current deleted, pick the most recent remaining or create new
    if (_conversationId == c.id) {
      final remaining = await _repo.watchConversations().first;
      if (remaining.isNotEmpty) {
        final next = remaining.first;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsConversationIdKey, next.id);
        setState(() => _conversationId = next.id);
        await _ensureConversationAndSubscribe();
      } else {
        setState(() => _conversationId = null);
        await _ensureConversationAndSubscribe(); // creates a new one
      }
    }
    if (context.mounted) Navigator.pop(context);
  }
  void _openSettingsSheet() {
    final apiController = TextEditingController(text: _hasUserOverride ? _apiKey : '');
    final promptController = TextEditingController(text: _systemPrompt);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'AI Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: apiController,
                decoration: const InputDecoration(
                  labelText: 'Gemini API Key',
                ),
              ),
              if (_sharedApiKey != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Leave blank to use the shared key managed in Firebase.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: promptController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'System Prompt',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final newKey = apiController.text.trim();
                    final newPrompt = promptController.text.trim().isEmpty
                        ? _defaultSystemPrompt
                        : promptController.text.trim();
                    if (newKey.isEmpty) {
                      await prefs.remove(_prefsApiKeyKey);
                      _hasUserOverride = false;
                      _apiKey = _sharedApiKey ?? '';
                    } else {
                      await prefs.setString(_prefsApiKeyKey, newKey);
                      _hasUserOverride = true;
                      _apiKey = newKey;
                    }
                    await prefs.setString(_prefsSystemPromptKey, newPrompt);
                    setState(() {
                      _systemPrompt = newPrompt;
                      _messages.clear();
                    });
                    await _configureModelAndChat();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
