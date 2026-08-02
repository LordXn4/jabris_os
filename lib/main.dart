import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(ODASApp());
}

class ODASApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: ODASPage(),
    );
  }
}

class ODASPage extends StatefulWidget {
  @override
  State<ODASPage> createState() => _ODASPageState();
}

class _ODASPageState extends State<ODASPage> {

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _listening = false;

  String _text = "Aguardando tarefas...";
  String _response = "";

  // NÃO coloque sua chave aqui.
  // Configure pelo GitHub Actions.
  static const API_KEY = String.fromEnvironment(
    'GEMINI_API_KEY',
  );


  @override
  void initState() {
    super.initState();
    _init();
  }


 Future<void> _init() async {
  await Permission.microphone.request();

  await _speech.initialize();

  // Configuração da voz do ODAS
  await _tts.setLanguage("pt-BR");
  await _tts.setSpeechRate(0.38);
  await _tts.setPitch(0.75);
  await _tts.setVolume(1.0);

  _speak("Sistemas online. Bem vindo senhor.");
}

  Future<void> _speak(String text) async {

    setState(() {
      _response = text;
    });

    await _tts.speak(text);
  }



  Future<void> _listen() async {

    if (!_listening) {

      bool available = await _speech.initialize();

      if (available) {

        setState(() {
          _listening = true;
        });


        await _speech.listen(
          localeId: "pt_BR",
          onResult: (result){

            setState(() {
              _text = result.recognizedWords;
            });

          },
        );

      }


    } else {

      setState(() {
        _listening = false;
      });


      await _speech.stop();


      if (_text.isNotEmpty){

        _askGemini(_text);

      }

    }

  }



  Future<void> _askGemini(String pergunta) async {


    setState(() {

      _response = "Processando...";

    });



    if(API_KEY.isEmpty){

      _speak(
        "Chave do sistema não configurada.",
      );

      return;

    }



    try{


      final model = GenerativeModel(

        model: 'gemini-1.5-flash',

        apiKey: API_KEY,

      );


      final resposta = await model.generateContent([

        Content.text(

          """
Você é o ODAS.
Você é um assistente inteligente.
Responda curto, elegante e chame o usuário de Senhor.

Pergunta:
$pergunta
"""

        )

      ]);



      _speak(

        resposta.text ?? "Não encontrei resposta."

      );



    }catch(e){

      _speak(
        "Erro de conexão."
      );

    }

  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: Container(

        decoration: BoxDecoration(

          gradient: RadialGradient(

            colors: [

              Colors.cyanAccent.withOpacity(0.15),

              Colors.black,

            ],

          ),

        ),


        child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [

    Text(
      "O.D.A.S OS",
      textAlign: TextAlign.center,
      style: TextStyle(
        letterSpacing: 8,
        color: Colors.cyanAccent,
        fontSize: 28,
      ),
    ),

    SizedBox(height: 70),

    Center(
      child: AvatarGlow(
        animate: _listening,
        glowColor: Colors.cyanAccent,
        child: GestureDetector(
          onTap: _listen,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyanAccent,
                width: 3,
              ),
            ),

            child: Icon(
              _listening
                  ? Icons.mic
                  : Icons.mic_none,

              size: 70,
              color: Colors.cyanAccent,
            ),
          ),
        ),
      ),
    ),

    SizedBox(height: 35),

    Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),

      child: Text(
        _listening
            ? "Ouvindo..."
            : _text,

        textAlign: TextAlign.center,

        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
        ),
      ),
    ),

    SizedBox(height: 40),

    Padding(
      padding: EdgeInsets.all(20),

      child: Text(
        _response,

        textAlign: TextAlign.center,

        style: TextStyle(
          color: Colors.cyanAccent,
          fontSize: 18,
        ),
      ),
    ),
  ],
)



            Spacer(),



            Container(

              margin:EdgeInsets.all(20),

              padding:EdgeInsets.all(16),


              decoration:BoxDecoration(

                color:Colors.white.withOpacity(0.05),

                borderRadius:BorderRadius.circular(16),

              ),



              child:Text(

                _response,

                textAlign:TextAlign.center,

                style:TextStyle(

                  color:Colors.cyanAccent,

                  fontSize:16,

                ),

              ),

            ),



            SizedBox(height:40),


          ],

        ),

      ),

    );

  }

}