import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/cidade.dart';
import '../models/previsao_dia.dart';
import '../models/previsao_resposta.dart';
import '../services/cptec_service.dart';
import '../services/local_storage_service.dart';
import '../utils/condicoes_tempo.dart';
import 'busca_cidade_screen.dart';

class PrevisaoScreen extends StatefulWidget {
  final Cidade cidade;

  const PrevisaoScreen({
    super.key,
    required this.cidade,
  });

  @override
  State<PrevisaoScreen> createState() => _PrevisaoScreenState();
}

class _PrevisaoScreenState extends State<PrevisaoScreen> {
  final CptecService _cptecService = CptecService();
  final LocalStorageService _storage = LocalStorageService();

  PrevisaoResposta? _previsao;
  bool _carregando = true;
  bool _usandoCache = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPrevisao();
  }

  Future<void> _carregarPrevisao() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _usandoCache = false;
    });

    try {
      final resultado =
          await _cptecService.buscarPrevisao4Dias(widget.cidade.id);
      await _storage.salvarPrevisaoCache(widget.cidade.id, resultado);

      if (!mounted) return;
      setState(() {
        _previsao = resultado;
        _carregando = false;
      });
    } on CptecException catch (e) {
      final cache = await _storage.obterPrevisaoCache(widget.cidade.id);
      if (!mounted) return;

      if (cache != null && cache.dias.isNotEmpty) {
        setState(() {
          _previsao = cache;
          _usandoCache = true;
          _carregando = false;
          _erro = '${e.mensagem} Exibindo última previsão salva localmente.';
        });
      } else {
        setState(() {
          _erro = e.mensagem;
          _carregando = false;
        });
      }
    }
  }

  Widget _construirGrafico(List<PrevisaoDia> dias) {
    final validos = dias
        .where((d) => d.minima != null || d.maxima != null)
        .toList();

    if (validos.length < 2) {
      return const SizedBox.shrink();
    }

    final spotsMin = <FlSpot>[];
    final spotsMax = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var i = 0; i < validos.length; i++) {
      final d = validos[i];
      if (d.minima != null) {
        spotsMin.add(FlSpot(i.toDouble(), d.minima!));
        if (d.minima! < minY) minY = d.minima!;
      }
      if (d.maxima != null) {
        spotsMax.add(FlSpot(i.toDouble(), d.maxima!));
        if (d.maxima! > maxY) maxY = d.maxima!;
      }
    }

    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 40;
    minY = (minY - 3).floorToDouble();
    maxY = (maxY + 3).ceilToDouble();

    final linhas = <LineChartBarData>[];
    if (spotsMax.isNotEmpty) {
      linhas.add(
        LineChartBarData(
          spots: spotsMax,
          isCurved: true,
          color: Colors.deepOrange,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      );
    }
    if (spotsMin.isNotEmpty) {
      linhas.add(
        LineChartBarData(
          spots: spotsMin,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Temperaturas (°C) — Próximos ${validos.length} dias',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.circle, size: 10, color: Colors.deepOrange),
                SizedBox(width: 4),
                Text('Máxima', style: TextStyle(fontSize: 12)),
                SizedBox(width: 14),
                Icon(Icons.circle, size: 10, color: Colors.blue),
                SizedBox(width: 4),
                Text('Mínima', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}°',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= validos.length) {
                            return const SizedBox.shrink();
                          }
                          final dataStr = validos[idx].dia;
                          final rotulo = dataStr.length >= 5
                              ? dataStr.substring(dataStr.length - 5)
                              : dataStr;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              rotulo,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: linhas,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCardDia(PrevisaoDia dia) {
    final condicao = CondicoesTempo.obter(dia.tempoSigla);
    final minTexto =
        dia.minima != null ? '${dia.minima!.toStringAsFixed(0)}°C' : '--';
    final maxTexto =
        dia.maxima != null ? '${dia.maxima!.toStringAsFixed(0)}°C' : '--';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: condicao.cor.withOpacity(0.15),
          child: Icon(condicao.icone, color: condicao.cor),
        ),
        title: Text(
          dia.dia.isNotEmpty ? dia.dia : 'Data não informada',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(condicao.descricao),
            if (dia.iuv != null) ...[
              const SizedBox(height: 2),
              Text(
                'Índice UV: ${dia.iuv!.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Máx: $maxTexto',
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mín: $minTexto',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cidade.exibicao),
        actions: [
          IconButton(
            tooltip: 'Buscar outra cidade',
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const BuscaCidadeScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Atualizar previsão',
            icon: const Icon(Icons.refresh),
            onPressed: _carregando ? null : _carregarPrevisao,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _carregarPrevisao,
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (_erro != null)
                    Card(
                      color: _usandoCache
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.errorContainer,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _erro!,
                          style: TextStyle(
                            color: _usandoCache
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  if (_previsao != null && _previsao!.dias.isNotEmpty) ...[
                    if (_previsao!.atualizacao.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Atualizado pelo CPTEC/INPE em: ${_previsao!.atualizacao}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    _construirGrafico(_previsao!.dias),
                    const SizedBox(height: 14),
                    Text(
                      'Previsão para os próximos dias',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._previsao!.dias.map(_construirCardDia),
                  ] else if (_erro == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'Não há previsão disponível para esta cidade.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
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