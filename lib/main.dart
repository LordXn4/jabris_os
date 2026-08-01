import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() => runApp(JabrisApp());

class JabrisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JABRIS OS',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: JarvisPage(),
    );
  }
}

class JarvisPage extends StatefulWidget {
  @override
  _JarvisPageState createState() => _JarvisPageState();
}

class _JarvisPageState extends State<JarvisPage> with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  late AnimationController _pulse;
  
  bool _listening = false;
  String _text = "Aguardando tarefas...";
  String _response = "";
  
  // COLA TUA CHAVE AQUI
  static const String API_KEY = "COLA_TUA_CHAVE_GEMINI_AQUI";

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))..repeat(reverse: true);
    _init();
  }

  Future<void> _init() async {
    await Permission.microphone.request();
    await _speech.initialize();
    await _tts.setLanguage("pt-BR");
    await _tts.setSpeechRate(0.9);
    await _tts.setPitch(0.9);
    _speak("Sistemas online. Bem vindo, senhor. JABRIS operacional.");
  }

  Future<void> _speak(String text) async {
    setState(() => _response = text);
    await _tts.speak(text);
  }

  Future<void> _listen() async {
    if (!_listening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _listening = true);
        _speech.listen(
          localeId: "pt_BR",
          onResult: (val) => setState(() => _text = val.recognizedWords),
        );
      }
    } else {
      setState(() => _listening = false);
      _speech.stop();
      if (_text.isNotEmpty && _text != "Aguardando tarefas...") {
        _askGemini(_text);
      }
    }
  }

  Future<void> _askGemini(String prompt) async {
    setState(() => _response = "Processando...");
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: API_KEY);
      final content = [Content.text("Você é o JARVIS, assistente do Homem de Ferro. Seja curto, elegante, chame de Senhor. Responda em PT-BR. Pergunta: $prompt")];
      final response = await model.generateContent(content);
      final answer = response.text ?? "Desculpe senhor, falha nos sistemas.";
      _speak(answer);
    } catch (e) {
      _speak("Erro de conexão com a rede neural, senhor. Verifique sua chave API.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            colors: [Colors.cyanAccent.withOpacity(0.15), Colors.black],
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Text("J.A.B.R.I.S  OS", style: TextStyle(letterSpacing: 8, color: Colors.cyanAccent, fontSize: 20)),
            Spacer(),
            AvatarGlow(
              animate: _listening,
              glowColor: Colors.cyanAccent,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              child: GestureDetector(
                onTap: _listen,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black, border: Border.all(color: Colors.cyanAccent, width: 2), boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.6), blurRadius: 30)]),
                  child: Icon(_listening ? Icons.mic : Icons.mic_none, size: 60, color: Colors.cyanAccent),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(_listening ? "Ouvindo..." : _text, style: TextStyle(color: Colors.white70, fontSize: 18), textAlign: TextAlign.center),
            Spacer(),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
              child: Text(_response, style: TextStyle(color: Colors.cyanAccent, fontSize: 16), textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            Text("Toque no reator para falar", style: TextStyle(color: Colors.white30)),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
