import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // IMPORTANTE: Para ler o .env
import 'package:url_launcher/url_launcher.dart'; 
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; 
import 'resultado_screen.dart';
import 'dados_perguntas.dart';
import 'dados_perguntas_parte2.dart';
import 'dados_perguntas_2024_parte1.dart';
import 'dados_perguntas_2024_parte2.dart';
import 'dados_2023_opcaoB_parte1.dart';
import 'dados_2023_opcaoB_parte2.dart';
import 'dados_2024_opcaoB_parte1.dart';
import 'dados_2024_opcaoB_parte2.dart';
import 'home_screen.dart';
import 'dados_artigos.dart';
import 'dados_plano_contas.dart'; 
import 'estado_manager.dart';
import 'chat_ia_screen.dart'; 

// Carrega o ficheiro .env antes de arrancar a app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class Pergunta {
  final int id;
  final String enunciado;
  final List<String> opcoes;
  final String respostaCorreta;
  final String justificacao;

  Pergunta({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.justificacao,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCAM Exames',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006633)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class SimuladorScreen extends StatefulWidget {
  final List<Pergunta> perguntas;
  final String tituloExame;

  const SimuladorScreen({
    super.key,
    required this.perguntas,
    required this.tituloExame,
  });

  @override
  State<SimuladorScreen> createState() => _SimuladorScreenState();
}

class _SimuladorScreenState extends State<SimuladorScreen> {
  int _perguntaAtual = 0;
  final Map<int, String> _respostasSelecionadas = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProgresso();
  }

  Future<void> _carregarProgresso() async {
    int progressoSalvo = await EstadoManager.obterProgresso(widget.tituloExame);
    setState(() {
      if (progressoSalvo >= widget.perguntas.length) {
        _perguntaAtual = 0;
      } else {
        _perguntaAtual = progressoSalvo;
      }
      _carregando = false;
    });
  }

  void _mudarPergunta(int index) {
    setState(() {
      _perguntaAtual = index;
      EstadoManager.guardarProgresso(widget.tituloExame, index);
    });
  }

  void _abrirGrelha() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Escolher Pergunta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: widget.perguntas.length,
                  itemBuilder: (context, index) {
                    bool respondida = _respostasSelecionadas.containsKey(widget.perguntas[index].id);
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: respondida ? const Color(0xFF006633) : Colors.grey[300],
                        foregroundColor: respondida ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        _mudarPergunta(index);
                        Navigator.pop(context);
                      },
                      child: Text('${index + 1}'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _obterExplicacao(String justificacao) {
    if (bibliotecaArtigos.containsKey(justificacao)) {
      return bibliotecaArtigos[justificacao];
    }

    String justificacaoLimpa = justificacao.replaceAll(RegExp(r'[^0-9]'), '');
    
    for (var chaveConta in planoDeContas.keys) {
      String chaveLimpa = chaveConta.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (justificacaoLimpa.contains(chaveLimpa) && chaveLimpa.isNotEmpty) {
        if (chaveLimpa.length > 1) {
           return "CONTA $chaveConta:\n\n${planoDeContas[chaveConta]}";
        }
      }
    }
    return null;
  }

  void _abrirMenuPDF(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book, color: Color(0xFF006633)),
                title: const Text('Decreto 70/2009 (Completo)'),
                subtitle: const Text('Boletim da República'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PdfViewerScreen(
                        caminhoPdf: 'assets/pgc.pdf',
                        titulo: 'Decreto 70/2009',
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.format_list_bulleted, color: Colors.blue),
                title: const Text('Plano de Contas (Resumido)'),
                subtitle: const Text('Lista de contas e nomes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PdfViewerScreen(
                        caminhoPdf: 'assets/pgc2.pdf',
                        titulo: 'Plano de Contas',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pergunta = widget.perguntas[_perguntaAtual];
    bool jaRespondeuEsta = _respostasSelecionadas.containsKey(pergunta.id);

    Color corFundoJustificacao = Colors.grey[200]!;
    Color corTextoJustificacao = Colors.black87;
    IconData iconeResultado = Icons.info_outline;
    Color corIconeResultado = Colors.grey;

    if (jaRespondeuEsta) {
      bool acertou = _respostasSelecionadas[pergunta.id] == pergunta.respostaCorreta;
      if (acertou) {
        corFundoJustificacao = Colors.green[50]!;
        corTextoJustificacao = Colors.green[900]!;
        iconeResultado = Icons.check_circle;
        corIconeResultado = Colors.green;
      } else {
        corFundoJustificacao = Colors.red[50]!;
        corTextoJustificacao = Colors.red[900]!;
        iconeResultado = Icons.cancel;
        corIconeResultado = Colors.red;
      }
    }

    String? explicacaoFinal = _obterExplicacao(pergunta.justificacao);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tituloExame} - Q${_perguntaAtual + 1}/${widget.perguntas.length}'),
        backgroundColor: const Color(0xFF006633),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Abrir Documentos (PDF)',
            onPressed: () => _abrirMenuPDF(context),
          ),
          IconButton(
            icon: const Icon(Icons.smart_toy),
            tooltip: 'Pedir ajuda à IA',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatIAScreen(contextoPergunta: pergunta.enunciado),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: _abrirGrelha,
            tooltip: 'Ir para pergunta',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              pergunta.enunciado,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            
            Expanded(
              child: ListView(
                children: List.generate(pergunta.opcoes.length, (index) {
                  String letra = String.fromCharCode(97 + index);
                  bool eOpcaoSelecionada = _respostasSelecionadas[pergunta.id] == letra;
                  bool eOpcaoCorreta = pergunta.respostaCorreta == letra;

                  Color? corTile;
                  Color? corTexto;
                  if (jaRespondeuEsta) {
                    if (eOpcaoCorreta) {
                      corTile = Colors.green[100];
                      corTexto = Colors.green[900];
                    } else if (eOpcaoSelecionada && !eOpcaoCorreta) {
                      corTile = Colors.red[100];
                      corTexto = Colors.red[900];
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: corTile,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: jaRespondeuEsta && (eOpcaoCorreta || eOpcaoSelecionada) 
                            ? (eOpcaoCorreta ? Colors.green : Colors.red) 
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        '${letra.toUpperCase()}) ${pergunta.opcoes[index]}',
                        style: TextStyle(
                          color: corTexto,
                          fontWeight: jaRespondeuEsta && (eOpcaoCorreta || eOpcaoSelecionada) 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                      value: letra,
                      groupValue: _respostasSelecionadas[pergunta.id],
                      activeColor: const Color(0xFF006633),
                      onChanged: jaRespondeuEsta ? null : (value) {
                        setState(() {
                          _respostasSelecionadas[pergunta.id] = value!;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),

            if (jaRespondeuEsta)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: corFundoJustificacao,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: corIconeResultado.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(iconeResultado, color: corIconeResultado),
                        const SizedBox(width: 8),
                        Text(
                          _respostasSelecionadas[pergunta.id] == pergunta.respostaCorreta 
                              ? 'Resposta Correcta!' 
                              : 'Resposta Errada',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: corTextoJustificacao,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Justificação:", style: TextStyle(fontWeight: FontWeight.bold, color: corTextoJustificacao)),
                    const SizedBox(height: 4),
                    Text(pergunta.justificacao, style: TextStyle(color: corTextoJustificacao)),
                    
                    if (explicacaoFinal != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton.icon(
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Explicação da Matéria'),
                                content: SingleChildScrollView(child: Text(explicacaoFinal!)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book, color: Color(0xFF006633)),
                          label: const Text('Ler Explicação', style: TextStyle(color: Color(0xFF006633), fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _perguntaAtual > 0
                      ? () => _mudarPergunta(_perguntaAtual - 1)
                      : null,
                  child: const Text('Anterior'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006633),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_perguntaAtual < widget.perguntas.length - 1) {
                      _mudarPergunta(_perguntaAtual + 1);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultadoScreen(
                            perguntas: widget.perguntas,
                            respostasUtilizador: _respostasSelecionadas,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(_perguntaAtual < widget.perguntas.length - 1 ? 'Próxima' : 'Terminar Exame'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ECRÃ DO LEITOR DE PDF (Versão Híbrida: Web e Telemóvel)
class PdfViewerScreen extends StatefulWidget {
  final String caminhoPdf;
  final String titulo;

  const PdfViewerScreen({
    super.key,
    required this.caminhoPdf,
    required this.titulo,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  bool _isSearching = false;
  bool _documentoCarregado = false;
  String _ultimoTermo = '';
  Uint8List? _pdfBytes;
  String? _erroCarregamento;
  
  String? _modoEscolhido; 

  @override
  void initState() {
    super.initState();
    _carregarPdf();
  }

  Future<void> _carregarPdf() async {
    try {
      final ByteData data = await rootBundle.load(widget.caminhoPdf);
      setState(() {
        _pdfBytes = data.buffer.asUint8List();
      });
    } catch (e) {
      setState(() {
        _erroCarregamento = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _searchResult.removeListener(_aoMudarPesquisa);
    _searchResult.clear();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _abrirPesquisa() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _fecharPesquisa() {
    _searchResult.removeListener(_aoMudarPesquisa);
    _searchResult.clear();
    _searchController.clear();
    _ultimoTermo = '';
    _searchFocus.unfocus();
    setState(() => _isSearching = false);
  }

  void _pesquisar(String texto) {
    final termo = texto.trim();
    if (termo.isEmpty || !_documentoCarregado) return;

    if (termo == _ultimoTermo && _searchResult.hasResult) {
      _searchResult.nextInstance();
      return;
    }

    _searchResult.removeListener(_aoMudarPesquisa);
    _searchResult.clear();

    _ultimoTermo = termo;
    _searchResult = _pdfController.searchText(termo);
    _searchResult.addListener(_aoMudarPesquisa);
    setState(() {});
  }

  void _aoMudarPesquisa() {
    if (!mounted) return;
    setState(() {});
  }

  PreferredSizeWidget _construirAppBar() {
    final mostrarNavegacao = _isSearching && _searchResult.hasResult;

    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Pesquisar no documento…',
                border: InputBorder.none,
              ),
              onSubmitted: _pesquisar,
            )
          : Text(widget.titulo, overflow: TextOverflow.ellipsis),
      backgroundColor: const Color(0xFF006633),
      foregroundColor: Colors.white,
      actions: [
        if (!_isSearching)
          IconButton(
            tooltip: 'Pesquisar',
            icon: const Icon(Icons.search),
            onPressed: _abrirPesquisa,
          ),
        if (_isSearching)
          IconButton(
            tooltip: 'Fechar pesquisa',
            icon: const Icon(Icons.close),
            onPressed: _fecharPesquisa,
          ),
      ],
      bottom: mostrarNavegacao
          ? PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_searchResult.currentInstanceIndex} de ${_searchResult.totalInstanceCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                    onPressed: _searchResult.previousInstance,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: _searchResult.nextInstance,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Future<void> _abrirPdfNoNavegador() async {
    final url = Uri.parse(widget.caminhoPdf); 
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o PDF em: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_modoEscolhido == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo),
          backgroundColor: const Color(0xFF006633),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xFF006633)),
              const SizedBox(height: 20),
              const Text(
                'Como queres abrir este PDF?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.web),
                label: const Text('Abrir no Navegador (Web)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  setState(() => _modoEscolhido = 'web');
                  _abrirPdfNoNavegador();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.phone_android),
                label: const Text('Abrir no Leitor Nativo (Telemóvel)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  setState(() => _modoEscolhido = 'telemovel');
                },
              ),
            ],
          ),
        ),
      );
    }

    if (_modoEscolhido == 'web') {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo),
          backgroundColor: const Color(0xFF006633),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'O PDF foi aberto numa nova aba do navegador.\n\nUsa o zoom e a pesquisa nativos do Chrome!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _construirAppBar(),
      body: _erroCarregamento != null
          ? Center(child: Text('Erro ao ler ficheiro: $_erroCarregamento'))
          : _pdfBytes == null
              ? const Center(child: CircularProgressIndicator())
              : SfPdfViewer.memory(
                  _pdfBytes!,
                  controller: _pdfController,
                  onDocumentLoaded: (details) {
                    if (mounted) setState(() => _documentoCarregado = true);
                  },
                  onDocumentLoadFailed: (details) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao abrir o PDF: ${details.description}')),
                    );
                  },
                ),
    );
  }
}