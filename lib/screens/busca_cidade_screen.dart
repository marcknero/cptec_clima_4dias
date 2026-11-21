import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../services/cptec_service.dart';
import '../services/local_storage_service.dart';
import 'previsao_screen.dart';

class BuscaCidadeScreen extends StatefulWidget {
  const BuscaCidadeScreen({super.key});

  @override
  State<BuscaCidadeScreen> createState() => _BuscaCidadeScreenState();
}

class _BuscaCidadeScreenState extends State<BuscaCidadeScreen> {
  final TextEditingController _controller = TextEditingController();
  final CptecService _cptecService = CptecService();
  final LocalStorageService _storage = LocalStorageService();

  List<Cidade> _resultados = [];
  List<Cidade> _historico = [];
  bool _carregando = false;
  bool _buscouAlgumaVez = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    final hist = await _storage.obterHistoricoCidades();
    if (!mounted) return;
    setState(() {
      _historico = hist;
    });
  }

  Future<void> _pesquisar() async {
    final termo = _controller.text.trim();
    if (termo.isEmpty) {
      setState(() {
        _mensagemErro = 'Digite o nome de uma cidade para pesquisar.';
        _resultados = [];
        _buscouAlgumaVez = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _mensagemErro = null;
      _buscouAlgumaVez = true;
    });

    try {
      final cidades = await _cptecService.buscarCidades(termo);
      if (!mounted) return;
      setState(() {
        _resultados = cidades;
        _carregando = false;
        if (cidades.isEmpty) {
          _mensagemErro =
              'Nenhuma cidade encontrada para "$termo". Tente outro termo.';
        }
      });
    } on CptecException catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _resultados = [];
        _mensagemErro = e.mensagem;
      });
    }
  }

  Future<void> _selecionarCidade(Cidade cidade) async {
    await _storage.salvarUltimaCidade(cidade);
    await _carregarHistorico();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrevisaoScreen(cidade: cidade),
      ),
    );
    await _carregarHistorico();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Cidade — CPTEC/INPE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _pesquisar(),
                    decoration: InputDecoration(
                      labelText: 'Nome da cidade',
                      hintText: 'Ex.: São José dos Campos, Campinas...',
                      prefixIcon: const Icon(Icons.location_city),
                      border: const OutlineInputBorder(),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {
                                  _resultados = [];
                                  _mensagemErro = null;
                                  _buscouAlgumaVez = false;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _carregando ? null : _pesquisar,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_mensagemErro != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _mensagemErro!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_carregando && _resultados.isNotEmpty) ...[
              Text(
                'Localidades encontradas (${_resultados.length}):',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _resultados.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cidade = _resultados[index];
                    return ListTile(
                      leading: const Icon(Icons.place),
                      title: Text(cidade.nome),
                      subtitle: Text('UF: ${cidade.uf} • ID: ${cidade.id}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selecionarCidade(cidade),
                    );
                  },
                ),
              ),
            ] else if (!_carregando && !_buscouAlgumaVez) ...[
              if (_historico.isNotEmpty) ...[
                Text(
                  'Consultadas recentemente (salvas no dispositivo):',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _historico
                      .map(
                        (c) => ActionChip(
                          avatar: const Icon(Icons.history, size: 18),
                          label: Text(c.exibicao),
                          onPressed: () => _selecionarCidade(c),
                        ),
                      )
                      .toList(),
                ),
              ] else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Pesquise uma cidade brasileira para consultar a previsão de 4 dias.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ] else if (!_carregando)
              const Spacer(),
            const SizedBox(height: 8),
            const Text(
              'Fonte dos dados: CPTEC/INPE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}