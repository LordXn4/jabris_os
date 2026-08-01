import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:avatar_glow/avatar_glow.dart';
void main() => runApp(JabrisApp());
class JabrisApp extends StatelessWidget { @override Widget build(BuildContext context) { return MaterialApp(debugShowCheckedModeBanner: false, home: JarvisPage(), theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black)); } }
class JarvisPage extends StatefulWidget { @override _JarvisPageState createState() => _JarvisPageState(); }
class _JarvisPageState extends State<JarvisPage> {
  final stt.SpeechToText _speech = stt.SpeechToText(); final FlutterTts _tts = FlutterTts(); bool _listening = false; String _text = "Aguardando tarefas..."; String _response = "";
  static const API_KEY = String.fromEnvironment('GEMINI_API_KEY');
  @override void initState() { super.initState(); _init(); }
  Future<void> _init() async { await Permission.microphone.request(); await _speech.initialize(); await _tts.setLanguage("pt-BR"); _speak("Sistemas online. Bem vindo senhor."); }
  Future<void> _speak(String t) async { setState(() => _response = t); await _tts.speak(t); }
  Future<void> _listen() async {
    if (!_listening) { bool ok = await _speech.initialize(); if (ok) { setState(() => _listening = true); _speech.listen(localeId: "pt_BR", onResult: (v) => setState(() => _text = v.recognizedWords)); } }
    else { setState(() => _listening = false); _speech.stop(); if (_text.isNotEmpty) _askGemini(_text); }
  }
  Future<void> _askGemini(String p) async {
    setState(() => _response = "Processando...");
    try { if (API_KEY.isEmpty) { _speak("Chave nao configurada."); return; } final m = GenerativeModel(model: 'gemini-1.5-flash', apiKey: API_KEY); final r = await m.generateContent([Content.text("Voce e o JARVIS. Curto, elegante, chame de Senhor. PT-BR. Pergunta: $p")]); _speak(r.text ?? "Falha."); } catch (e) { _speak("Erro de conexao."); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: RadialGradient(colors: [Colors.cyanAccent.withOpacity(0.15), Colors.black], radius: 1.2)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 60), Text("J.A.B.R.I.S OS", style: TextStyle(letterSpacing: 8, color: Colors.cyanAccent)),
      Spacer(),
      AvatarGlow(animate: _listening, glowColor: Colors.cyanAccent, child: GestureDetector(onTap: _listen, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent, width: 2)), child: Icon(_listening ? Icons.mic : Icons.mic_none, size: 60, color: Colors.cyanAccent)))),
      SizedBox(height: 20), Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(_listening ? "Ouvindo..." : _text, style: TextStyle(color: Colors.white70))),
      Spacer(),
      Container(margin: EdgeInsets.all(20), padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: Text(_response, style: TextStyle(color: Colors.cyanAccent), textAlign: TextAlign.center)),
      SizedBox(height: 40)
    ])));
  }
}
