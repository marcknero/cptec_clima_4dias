import 'package:shared_preferences/shared_preferences.dart';
import '../models/cidade.dart';
import '../models/previsao_resposta.dart';

class LocalStorageService {
  static const String _keyUltimaCidade = 'ultima_cidade_v1';
  static const String _keyHistoricoCidades = 'historico_cidades_v1';
  static const String _prefixoPrevisao = 'previsao_cache_v1_';

  Future<void> salvarUltimaCidade(Cidade cidade) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUltimaCidade, cidade.toJsonString());
    await _adicionarAoHistorico(prefs, cidade);
  }

  Future<Cidade?> obterUltimaCidade() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUltimaCidade);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Cidade.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _adicionarAoHistorico(
    SharedPreferences prefs,
    Cidade cidade,
  ) async {
    final atual = prefs.getStringList(_keyHistoricoCidades) ?? [];
    final decodificadas = <Cidade>[];

    for (final item in atual) {
      try {
        final c = Cidade.fromJsonString(item);
        if (c.id != cidade.id) {
          decodificadas.add(c);
        }
      } catch (_) {}
    }

    decodificadas.insert(0, cidade);
    final limitadas = decodificadas.take(6).map((c) => c.toJsonString()).toList();
    await prefs.setStringList(_keyHistoricoCidades, limitadas);
  }

  Future<List<Cidade>> obterHistoricoCidades() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_keyHistoricoCidades) ?? [];
    final resultado = <Cidade>[];
    for (final item in lista) {
      try {
        resultado.add(Cidade.fromJsonString(item));
      } catch (_) {}
    }
    return resultado;
  }

  Future<void> salvarPrevisaoCache(
    String codigoCidade,
    PrevisaoResposta previsao,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefixoPrevisao$codigoCidade',
      previsao.toJsonString(),
    );
  }

  Future<PrevisaoResposta?> obterPrevisaoCache(String codigoCidade) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefixoPrevisao$codigoCidade');
    if (raw == null || raw.isEmpty) return null;
    try {
      return PrevisaoResposta.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }
}