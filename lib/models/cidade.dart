import 'dart:convert';
import 'package:xml/xml.dart';

class Cidade {
  final String id;
  final String nome;
  final String uf;

  const Cidade({
    required this.id,
    required this.nome,
    required this.uf,
  });

  String get exibicao => uf.isNotEmpty ? '$nome - $uf' : nome;

  factory Cidade.fromXmlElement(XmlElement element) {
    String texto(String tag) =>
        element.getElement(tag)?.innerText.trim() ?? '';

    return Cidade(
      id: texto('id'),
      nome: texto('nome'),
      uf: texto('uf'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'uf': uf,
      };

  factory Cidade.fromJson(Map<String, dynamic> json) => Cidade(
        id: (json['id'] ?? '').toString(),
        nome: (json['nome'] ?? '').toString(),
        uf: (json['uf'] ?? '').toString(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory Cidade.fromJsonString(String source) =>
      Cidade.fromJson(jsonDecode(source) as Map<String, dynamic>);
}