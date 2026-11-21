import 'package:flutter/material.dart';
import 'models/cidade.dart';
import 'screens/busca_cidade_screen.dart';
import 'screens/previsao_screen.dart';
import 'services/local_storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CptecClimaApp());
}

class CptecClimaApp extends StatelessWidget {
  const CptecClimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo — CPTEC/INPE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const _TelaInicial(),
    );
  }
}

class _TelaInicial extends StatefulWidget {
  const _TelaInicial();

  @override
  State<_TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<_TelaInicial> {
  final LocalStorageService _storage = LocalStorageService();
  Cidade? _ultimaCidade;
  bool _verificando = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cidade = await _storage.obterUltimaCidade();
    if (!mounted) return;
    setState(() {
      _ultimaCidade = cidade;
      _verificando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_verificando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ultimaCidade != null) {
      return PrevisaoScreen(cidade: _ultimaCidade!);
    }

    return const BuscaCidadeScreen();
  }
}