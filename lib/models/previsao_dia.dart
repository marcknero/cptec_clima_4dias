import 'package:xml/xml.dart';

class PrevisaoDia {
  final String dia;
  final String tempoSigla;
  final double? maxima;
  final double? minima;
  final double? iuv;

  const PrevisaoDia({
    required this.dia,
    required this.tempoSigla,
    this.maxima,
    this.minima,
    this.iuv,
  });

  factory PrevisaoDia.fromXmlElement(XmlElement element) {
    String texto(String tag) =>
        element.getElement(tag)?.innerText.trim() ?? '';

    double? parseDouble(String tag) {
      final raw = texto(tag).replaceAll(',', '.');
      if (raw.isEmpty || raw.toLowerCase() == 'null' || raw == '-') {
        return null;
      }
      return double.tryParse(raw);
    }

    return PrevisaoDia(
      dia: texto('dia'),
      tempoSigla: texto('tempo'),
      maxima: parseDouble('maxima'),
      minima: parseDouble('minima'),
      iuv: parseDouble('iuv'),
    );
  }

  Map<String, dynamic> toJson() => {
        'dia': dia,
        'tempoSigla': tempoSigla,
        'maxima': maxima,
        'minima': minima,
        'iuv': iuv,
      };

  factory PrevisaoDia.fromJson(Map<String, dynamic> json) => PrevisaoDia(
        dia: (json['dia'] ?? '').toString(),
        tempoSigla: (json['tempoSigla'] ?? '').toString(),
        maxima: json['maxima'] != null
            ? double.tryParse(json['maxima'].toString())
            : null,
        minima: json['minima'] != null
            ? double.tryParse(json['minima'].toString())
            : null,
        iuv: json['iuv'] != null ? double.tryParse(json['iuv'].toString()) : null,
      );
}