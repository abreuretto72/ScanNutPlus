import 'package:flutter/material.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_ai_repository.dart';
import 'package:scannutplus/l10n/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scannutplus/core/services/remote_config_service.dart';

class PetAiChatView extends StatefulWidget {
  final String petUuid;
  final String petName;

  const PetAiChatView({
    super.key,
    required this.petUuid,
    required this.petName,
  });

  @override
  State<PetAiChatView> createState() => _PetAiChatViewState();
}

class _PetAiChatViewState extends State<PetAiChatView> {
  final PetAiRepository _repository = PetAiRepository();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  // Gemini Model
  late GenerativeModel _model;
  bool _isGeminiReady = false;

  List<Map<String, String>> _messages = []; // {'sender': 'user'|'ai', 'text': '...'}
  bool _isListening = false;
  bool _isLoadingContext = true;
  String _ragContext = '';
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _loadContext();
    _initSpeech();
    _initGemini();
  }

  Future<void> _initGemini() async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        print('SCAN_NUT_ERROR: GEMINI_API_KEY not found in .env');
        return;
      }
      
      // Dynamic Model Configuration (Remote Fetch)
      // Uses SITE_BASE_URL -> food_config.json -> active_model
      String modelName = 'gemini-pro'; // Default Fallback
      try {
        modelName = await RemoteConfigService().getActiveModel();
        print('SCAN_NUT_TRACE: AI Model initialized with: $modelName');
      } catch (e) {
        print('SCAN_NUT_WARN: Failed to fetch remote model config. Using default ($modelName). Error: $e');
      }

      _model = GenerativeModel(
        model: modelName, 
        apiKey: apiKey,
        // Safety settings can be adjusted here if needed
      );
      setState(() => _isGeminiReady = true);
    } catch (e) {
      print('SCAN_NUT_ERROR: Failed to init Gemini: $e');
    }
  }

  Future<void> _loadContext() async {
    _ragContext = await _repository.getPetContext(widget.petUuid);
    setState(() {
      _isLoadingContext = false;
      // Optional: Add initial AI greeting
      _messages.add({
        'sender': 'ai',
        'text': 'Hello! I have analyzed ${widget.petName}\'s data. How can I help?' 
      });
    });
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (errorNotification) => print('STT Error: $errorNotification'),
    );
    if (!available) {
      print('STT not available');
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isThinking = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
       if (!_isGeminiReady) {
         throw Exception('AI Brain not ready. Check Internet or API Key.');
       }

       // RAG PROMPT ENGINEERING
       final prompt = '''
You are an advanced Veterinary AI Assistant for the ScanNut+ App.
Your goal is to assist the owner of the pet named "${widget.petName}".

SYSTEM TIME:
CURRENT DATE: ${DateTime.now().toLocal()}

CONTEXT (RAG DATA):
$_ragContext

INSTRUCTIONS (STRICT GROUNDING):
- **FACTUAL QUESTIONS:** Answer ONLY based on the "CONTEXT" provided above. If the info is missing, say "I don't find that in the records."
- **RECOMMENDATIONS/SUGGESTIONS:** If the user explicitly asks for advice (e.g., "What should I feed?", "Tips for this breed?"), you MAY use your general veterinary knowledge.
  - *Constraint 1:* You must clearly state: "This is a general suggestion, not specific to [Pet Name]'s data."
  - *Constraint 2 (MANDATORY):* You **MUST** cite the source of your general knowledge (e.g., "According to general veterinary consensus...", "Based on AAHA guidelines...", "Common practice suggests...").
- **PROHIBITED:** Do not hallucinate data (weight, dates, exams) that are not in the CONTEXT.
- **DATE HANDLING:**
  - Compare all dates with CURRENT DATE.
  - Future dates = "Scheduled Event" or "Data Error".
- Language: Respond in the same language as the user (English/Portuguese).

USER QUESTION:
$text
       ''';

       final content = [Content.text(prompt)];
       final response = await _model.generateContent(content);
       final aiResponse = response.text ?? 'I am having trouble thinking right now. Please try again.';

       if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add({
            'sender': 'ai',
            'text': aiResponse
          });
          _scrollToBottom();
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
           _isThinking = false;
           _messages.add({
            'sender': 'ai',
            'text': 'Connection Error: $e'
          });
          _scrollToBottom();
        });
      }
    }
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

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) {
              setState(() {
                _textController.text = val.recognizedWords;
                if (val.finalResult) {
                  _isListening = false;
                }
              });
            },
            localeId: Localizations.localeOf(context).toString(),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.ai_error_mic)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appL10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.petBackgroundDark,
      appBar: AppBar(
        title: Text(
          appL10n.ai_assistant_title(widget.petName),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat List
            Expanded(
              child: _isLoadingContext
                  ? const Center(child: CircularProgressIndicator(color: AppColors.petPrimary))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isThinking ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('🤖 Thinking...', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                            ),
                          );
                        }
                        
                        final msg = _messages[index];
                        final isUser = msg['sender'] == 'user';
                        
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isUser ? AppColors.petPrimary : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              msg['text']!,
                              style: TextStyle(
                                color: isUser ? Colors.black : Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _isListening ? appL10n.ai_listening : appL10n.ai_input_hint,
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.white54,
                          ),
                          onPressed: _toggleListening,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send Button
                  CircleAvatar(
                    backgroundColor: AppColors.petPrimary,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: () => _sendMessage(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
