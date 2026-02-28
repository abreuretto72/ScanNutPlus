import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:scannutplus/core/theme/app_colors.dart';
import 'package:scannutplus/features/pet/data/pet_ai_repository.dart';
import 'package:scannutplus/features/pet/data/pet_constants.dart';
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

  final List<Map<String, String>> _messages = []; // Structure: {KEY_SENDER: ..., KEY_TEXT: ...}
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
      final apiKey = dotenv.env[PetConstants.envGeminiApiKey];
      if (apiKey == null || apiKey.isEmpty) {
        if (kDebugMode) debugPrint(PetConstants.logErrorGeminiEnv);
        return;
      }
      
      // Dynamic Model Configuration (Remote Fetch)
      // Uses SITE_BASE_URL -> food_config.json -> active_model
      String modelName = 'gemini-pro'; // Default Fallback
      try {
        modelName = await RemoteConfigService().getActiveModel();
        if (kDebugMode) debugPrint('${PetConstants.logTraceAiModel}$modelName');
      } catch (e) {
        if (kDebugMode) debugPrint('${PetConstants.logWarnAiModel}$modelName. Error: $e');
      }

      _model = GenerativeModel(
        model: modelName, 
        apiKey: apiKey,
        // Safety settings can be adjusted here if needed
      );
      setState(() => _isGeminiReady = true);
    } catch (e) {
      if (kDebugMode) debugPrint('${PetConstants.logErrorGeminiInit}$e');
    }
  }

  Future<void> _loadContext() async {
    _ragContext = await _repository.getPetContext(widget.petUuid);
    setState(() {
      _isLoadingContext = false;
      // Optional: Add initial AI greeting
      // Optional: Add initial AI greeting
      _messages.add({
        PetConstants.keySender: PetConstants.keyAi,
        PetConstants.keyText: AppLocalizations.of(context)!.pet_ai_greeting(widget.petName)
      });
    });
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => kDebugMode ? debugPrint('${PetConstants.logSttStatus}$status') : null,
      onError: (errorNotification) => kDebugMode ? debugPrint('${PetConstants.logSttError}$errorNotification') : null,
    );
    if (!available) {
      if (!mounted) return;
      if (kDebugMode) debugPrint(AppLocalizations.of(context)!.pet_stt_not_available);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({PetConstants.keySender: PetConstants.keyUser, PetConstants.keyText: text});
      _isThinking = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
       if (!_isGeminiReady) {
         throw Exception(AppLocalizations.of(context)!.pet_ai_brain_not_ready);
       }

       // RAG PROMPT ENGINEERING
       final prompt = PetPrompts.chatSystemContext
          .replaceFirst('{petName}', widget.petName)
          .replaceFirst('{date}', DateTime.now().toLocal().toString())
          .replaceFirst('{context}', _ragContext)
          .replaceFirst('{question}', text);

       final content = [Content.text(prompt)];
       final response = await _model.generateContent(content).timeout(const Duration(seconds: 60)); // Global Timeout 60s
       
       if (!mounted) return;
       final aiResponse = response.text ?? AppLocalizations.of(context)!.pet_ai_trouble_thinking;

       if (mounted) {
        setState(() {
          _isThinking = false;
          _messages.add({
            PetConstants.keySender: PetConstants.keyAi,
            PetConstants.keyText: aiResponse
          });
          _scrollToBottom();
        });
      }

    } catch (e) {
      if (mounted) {
        String errorMessage = AppLocalizations.of(context)!.pet_ai_connection_error(e.toString());
        
        // Protocol 2026: Error 500 Handling
        if (e.toString().contains(PetConstants.err500) || e.toString().contains(PetConstants.errInternal) || e.toString().contains(PetConstants.errOverloaded) || e.toString().contains(PetConstants.errTimeout)) {
             if (e.toString().contains(PetConstants.errTimeout)) {
                // Handle timeout specifically if needed, or group with overload
             }
             errorMessage = AppLocalizations.of(context)!.pet_ai_overloaded_message;
             
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(errorMessage), 
                 backgroundColor: Colors.amber[900], 
                 behavior: SnackBarBehavior.floating,
               ),
             );
        }

        setState(() {
           _isThinking = false;
           _messages.add({
            PetConstants.keySender: PetConstants.keyAi,
            PetConstants.keyText: errorMessage
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
      final localeId = Localizations.localeOf(context).toString();
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
            localeId: localeId,
          );
        }
      } else {
        if (!mounted) return;
        final appL10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appL10n.ai_error_mic)),
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
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('🤖 ${appL10n.pet_ai_thinking_status}', style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                            ),
                          );
                        }
                        
                        final msg = _messages[index];
                        final isUser = msg[PetConstants.keySender] == PetConstants.keyUser;
                        
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
                              msg[PetConstants.keyText]!,
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
                            color: _isListening ? Colors.redAccent : Colors.blue,
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
