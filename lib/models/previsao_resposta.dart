import 'dart:convert';
import 'package:xml/xml.dart';
import 'previsao_dia.dart';

class PrevisaoResposta {
  final String nomeCidade;
  final String uf;
  final String atualizacao;
  final List<PrevisaoDia> dias;

  const PrevisaoResposta({
    required this.nomeCidade,
    required this.uf,
    required this.atualizacao,
    required this.dias,
  });

  factory PrevisaoResposta.fromXmlString(String xmlString) {
    final doc = XmlDocument.parse(xmlString);
    final root = doc.rootElement;

    if (root.name.local.toLowerCase() != 'cidade') {
      throw const FormatException('Estrutura XML de previsão inesperada.');
    }

    String texto(String tag) =>
        root.getElement(tag)?.innerText.trim() ?? '';

    final previsoesElement = root.findElements('previsao').take(4).toList();
    final dias = previsoesElement
        .map((el) => PrevisaoDia.fromXmlElement(el))
        .where((d) => d.dia.isNotEmpty)
        .toList();

    return PrevisaoResposta(
      nomeCidade: texto('nome'),
      uf: texto('uf'),
      atualizacao: texto('atualizacao'),
      dias: dias,
    );
  }

  Map<String, dynamic> toJson() => {
        'nomeCidade': nomeCidade,
        'uf': uf,
        'atualizacao': atualizacao,
        'dias': dias.map((d) => d.toJson()).toList(),
      };

  factory PrevisaoResposta.fromJson(Map<String, dynamic> json) {
    final rawDias = (json['dias'] as List<dynamic>? ?? []);
    return PrevisaoResposta(
      nomeCidade: (json['nomeCidade'] ?? '').toString(),
      uf: (json['uf'] ?? '').toString(),
      atualizacao: (json['atualizacao'] ?? '').toString(),
      dias: rawDias
          .map((item) => PrevisaoDia.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory PrevisaoResposta.fromJsonString(String source) =>
      PrevisaoResposta.fromJson(jsonDecode(source) as Map<String, dynamic>);
}