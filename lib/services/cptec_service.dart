import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/cidade.dart';
import '../models/previsao_resposta.dart';

class CptecException implements Exception {
  final String mensagem;
  const CptecException(this.mensagem);

  @override
  String toString() => mensagem;
}

class CptecService {
  static const String _baseUrl = 'http://servicos.cptec.inpe.br/XML';
  static const Duration _timeout = Duration(seconds: 12);

  final http.Client _client;

  CptecService({http.Client? client}) : _client = client ?? http.Client();

  String _decodificarCorpo(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      throw const CptecException('Resposta vazia recebida do serviço CPTEC/INPE.');
    }
    try {
      return utf8.decode(response.bodyBytes, allowMalformed: false);
    } catch (_) {
      return latin1.decode(response.bodyBytes);
    }
  }

  Future<List<Cidade>> buscarCidades(String nomeCidade) async {
    final termo = nomeCidade.trim();
    if (termo.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      '$_baseUrl/listaCidades?city=${Uri.encodeQueryComponent(termo)}',
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'Serviço do CPTEC/INPE indisponível no momento (HTTP ${response.statusCode}).',
        );
      }

      final xmlStr = _decodificarCorpo(response);
      final doc = XmlDocument.parse(xmlStr);
      final elementos = doc.findAllElements('cidade');

      final cidades = elementos
          .map((el) => Cidade.fromXmlElement(el))
          .where((c) => c.id.isNotEmpty && c.nome.isNotEmpty)
          .toList();

      return cidades;
    } on SocketException {
      throw const CptecException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on TimeoutException {
      throw const CptecException(
        'A consulta ao CPTEC/INPE demorou mais que o esperado. Tente novamente.',
      );
    } on XmlParserException {
      throw const CptecException(
        'Resposta XML inválida recebida ao buscar cidades.',
      );
    } on FormatException catch (e) {
      throw CptecException(e.message);
    } on CptecException {
      rethrow;
    } catch (_) {
      throw const CptecException(
        'Erro inesperado ao consultar as cidades no CPTEC/INPE.',
      );
    }
  }

  Future<PrevisaoResposta> buscarPrevisao4Dias(String codigoCidade) async {
    final id = codigoCidade.trim();
    if (id.isEmpty) {
      throw const CptecException('Código da cidade inválido.');
    }

    final uri = Uri.parse('$_baseUrl/cidade/$id/previsao.xml');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw CptecException(
          'Serviço de previsão indisponível (HTTP ${response.statusCode}).',
        );
      }

      final xmlStr = _decodificarCorpo(response);
      final previsao = PrevisaoResposta.fromXmlString(xmlStr);

      if (previsao.dias.isEmpty) {
        throw const CptecException(
          'Não há previsão disponível para a localidade selecionada.',
        );
      }

      return previsao;
    } on SocketException {
      throw const CptecException(
        'Falha de conexão ao buscar a previsão do tempo.',
      );
    } on TimeoutException {
      throw const CptecException(
        'Tempo limite esgotado ao consultar a previsão do tempo.',
      );
    } on XmlParserException {
      throw const CptecException(
        'Resposta XML inválida recebida do CPTEC/INPE.',
      );
    } on FormatException catch (e) {
      throw CptecException(e.message);
    } on CptecException {
      rethrow;
    } catch (_) {
      throw const CptecException(
        'Erro inesperado ao consultar a previsão do tempo.',
      );
    }
  }
}