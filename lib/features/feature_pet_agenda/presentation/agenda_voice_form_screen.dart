import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../models/parsed_agenda_intent.dart';
import '../logic/agenda_tts_service.dart';
import '../logic/agenda_voice_parser.dart';

class AgendaVoiceFormScreen extends StatefulWidget {
  final String petName;
  const AgendaVoiceFormScreen({super.key, required this.petName});

  @override
  State<AgendaVoiceFormScreen> createState() => _AgendaVoiceFormScreenState();
}

class _AgendaVoiceFormScreenState extends State<AgendaVoiceFormScreen> {
  final SpeechToText _speechToText = SpeechToText();
  late AgendaTTSService _ttsService;
  late AgendaVoiceParser _voiceParser;

  bool _isListening = false;
  bool _isProcessing = false;
  String _lastWords = '';

  ParsedAgendaIntent _currentIntent = const ParsedAgendaIntent();

  final TextEditingController _categoryCtrl = TextEditingController();
  final TextEditingController _dateCtrl = TextEditingController();
  final TextEditingController _timeCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ttsService = AgendaTTSService();
    _voiceParser = AgendaVoiceParser(dotenv.env['GEMINI_API_KEY'] ?? '');
    _initSpeech();
  }

  void _initSpeech() async {
    bool hasSpeech = await _speechToText.initialize();
    if (hasSpeech && mounted) {
      _startVoiceFirstFlow();
    }
  }

  void _startVoiceFirstFlow() async {
    // Foco Empático: Iniciar via áudio diretamente.
    final l10n = AppLocalizations.of(context)!;
    await _ttsService.speak(l10n.agenda_voice_greeting);
    
    // Aguardar terminar de falar... 
    // Como simplificação visual imediata, ligamos o microfone.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isListening) {
        _startListening();
      }
    });
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'pt_BR', // Hardcoded locale explicitly requested for the Brazilian Assistant Beli context... but dynamic via app_localizations would be better. Let's keep it simple.
    );
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });
    _processIntent();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (result.finalResult && mounted) {
      _stopListening();
    }
  }

  Future<void> _processIntent() async {
    final l10n = AppLocalizations.of(context)!;
    final intent = await _voiceParser.parseSpeech(_lastWords);

    if (mounted) {
      setState(() {
        _currentIntent = intent;
        _isProcessing = false;

        if (!intent.hasCriticalError) {
          _categoryCtrl.text = intent.category ?? '';
          if (intent.date != null) {
            _dateCtrl.text = "${intent.date!.day}/${intent.date!.month}/${intent.date!.year}";
          }
          _timeCtrl.text = intent.time ?? '';
          _descCtrl.text = intent.description ?? '';
        }
      });

      if (!intent.hasCriticalError) {
        await _ttsService.speak(l10n.agenda_voice_success_prompt);
      } else {
        await _ttsService.speak(l10n.agenda_error_voice);
      }
    }
  }

  Color _getFieldBorderColor(String value, bool hasCriticalError, bool isHighConfidence) {
    if (hasCriticalError) return Colors.redAccent;
    if (value.isNotEmpty && isHighConfidence) return const Color(0xFF10AC84); // Verde (Confiança Alta)
    if (value.isEmpty) return Colors.grey.withValues(alpha: 0.5); // Regra Consolidada ScanNut: .withValues(alpha: x)
    return Colors.black; // Padrão
  }

  @override
  void dispose() {
    _ttsService.stop();
    _speechToText.stop();
    _categoryCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF101213), // Diretriz UI: Fundo Preto
      appBar: AppBar(
        title: Text(l10n.pet_agenda_add_event_dynamic(widget.petName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Diretriz: SM A256E Ergonomia (Sempre SingleChildScrollView)
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Voice Command Banner
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.petPrimary, // Rosa Pastel #FFD1DC
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 64,
                      color: _isListening ? Colors.redAccent : Colors.black,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isListening ? l10n.agenda_voice_listening : _isProcessing ? l10n.agenda_voice_processing : l10n.agenda_voice_greeting,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (_lastWords.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '"$_lastWords"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildField(l10n.agenda_field_category, _categoryCtrl, Icons.category),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField(l10n.agenda_field_date, _dateCtrl, Icons.calendar_today)),
                const SizedBox(width: 16),
                Expanded(child: _buildField(l10n.agenda_field_time, _timeCtrl, Icons.access_time)),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(l10n.agenda_field_desc, _descCtrl, Icons.edit, maxLines: 3),

            const SizedBox(height: 48),

            // Save Button
            InkWell(
              onTap: () {
                // Ao salvar, devovemos o formulário para quem chamou criar o PetEvent
                Navigator.pop(context, _currentIntent.copyWith(
                  category: _categoryCtrl.text,
                  time: _timeCtrl.text,
                  description: _descCtrl.text,
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.petPrimary, // Rosa Pastel
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.agenda_btn_save.toUpperCase(),
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    final borderColor = _getFieldBorderColor(controller.text, _currentIntent.hasCriticalError, _currentIntent.isHighConfidence);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.petPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: controller.text.isNotEmpty ? 3 : 2), // Borda destaque se cheio e aprovado
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
          prefixIcon: Icon(icon, color: Colors.black),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
