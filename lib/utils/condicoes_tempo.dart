import 'package:flutter/material.dart';

class CondicaoTempoInfo {
  final String descricao;
  final IconData icone;
  final Color cor;

  const CondicaoTempoInfo({
    required this.descricao,
    required this.icone,
    required this.cor,
  });
}

class CondicoesTempo {
  static const Map<String, CondicaoTempoInfo> _mapa = {
    'ec': CondicaoTempoInfo(
      descricao: 'Encoberto com chuvas isoladas',
      icone: Icons.grain,
      cor: Colors.blueGrey,
    ),
    'ci': CondicaoTempoInfo(
      descricao: 'Chuvas isoladas',
      icone: Icons.water_drop_outlined,
      cor: Colors.blue,
    ),
    'c': CondicaoTempoInfo(
      descricao: 'Chuva',
      icone: Icons.umbrella,
      cor: Colors.indigo,
    ),
    'in': CondicaoTempoInfo(
      descricao: 'Instável',
      icone: Icons.cloud_sync,
      cor: Colors.teal,
    ),
    'pp': CondicaoTempoInfo(
      descricao: 'Possibilidade de pancadas de chuva',
      icone: Icons.thunderstorm_outlined,
      cor: Colors.blue,
    ),
    'cm': CondicaoTempoInfo(
      descricao: 'Chuva pela manhã',
      icone: Icons.wb_twilight,
      cor: Colors.blue,
    ),
    'cn': CondicaoTempoInfo(
      descricao: 'Chuva à noite',
      icone: Icons.nights_stay,
      cor: Colors.indigo,
    ),
    'pt': CondicaoTempoInfo(
      descricao: 'Pancadas de chuva a qualquer hora',
      icone: Icons.thunderstorm,
      cor: Colors.deepPurple,
    ),
    'pm': CondicaoTempoInfo(
      descricao: 'Pancadas de chuva pela manhã',
      icone: Icons.grain,
      cor: Colors.blue,
    ),
    'np': CondicaoTempoInfo(
      descricao: 'Nublado e pancadas de chuva',
      icone: Icons.cloud_queue,
      cor: Colors.blueGrey,
    ),
    'pc': CondicaoTempoInfo(
      descricao: 'Pancadas de chuva',
      icone: Icons.thunderstorm,
      cor: Colors.blue,
    ),
    'pn': CondicaoTempoInfo(
      descricao: 'Parcialmente nublado',
      icone: Icons.wb_cloudy,
      cor: Colors.lightBlue,
    ),
    'cv': CondicaoTempoInfo(
      descricao: 'Chuvisco',
      icone: Icons.grain,
      cor: Colors.lightBlue,
    ),
    'ch': CondicaoTempoInfo(
      descricao: 'Chuvoso',
      icone: Icons.umbrella,
      cor: Colors.blue,
    ),
    'ao': CondicaoTempoInfo(
      descricao: 'Chuva forte',
      icone: Icons.thunderstorm,
      cor: Colors.indigo,
    ),
    'ps': CondicaoTempoInfo(
      descricao: 'Predomínio de sol',
      icone: Icons.wb_sunny,
      cor: Colors.orange,
    ),
    'e': CondicaoTempoInfo(
      descricao: 'Encoberto',
      icone: Icons.cloud,
      cor: Colors.grey,
    ),
    'n': CondicaoTempoInfo(
      descricao: 'Nublado',
      icone: Icons.filter_drama,
      cor: Colors.blueGrey,
    ),
    'cl': CondicaoTempoInfo(
      descricao: 'Céu claro',
      icone: Icons.wb_sunny_outlined,
      cor: Colors.amber,
    ),
    'nv': CondicaoTempoInfo(
      descricao: 'Nevoeiro',
      icone: Icons.foggy,
      cor: Colors.blueGrey,
    ),
    'g': CondicaoTempoInfo(
      descricao: 'Geada',
      icone: Icons.ac_unit,
      cor: Colors.cyan,
    ),
    'ne': CondicaoTempoInfo(
      descricao: 'Neve',
      icone: Icons.snowing,
      cor: Colors.lightBlueAccent,
    ),
    'nd': CondicaoTempoInfo(
      descricao: 'Não definido',
      icone: Icons.help_outline,
      cor: Colors.grey,
    ),
    'pnt': CondicaoTempoInfo(
      descricao: 'Pancadas de chuva à noite',
      icone: Icons.nights_stay,
      cor: Colors.indigo,
    ),
    'psc': CondicaoTempoInfo(
      descricao: 'Possibilidade de chuva',
      icone: Icons.cloud_queue,
      cor: Colors.blue,
    ),
    'pcm': CondicaoTempoInfo(
      descricao: 'Possibilidade de chuva pela manhã',
      icone: Icons.wb_twilight,
      cor: Colors.blue,
    ),
    'pct': CondicaoTempoInfo(
      descricao: 'Possibilidade de chuva à tarde',
      icone: Icons.wb_sunny,
      cor: Colors.orange,
    ),
    'pcn': CondicaoTempoInfo(
      descricao: 'Possibilidade de chuva à noite',
      icone: Icons.nights_stay,
      cor: Colors.indigo,
    ),
    'npt': CondicaoTempoInfo(
      descricao: 'Nublado com pancadas à tarde',
      icone: Icons.thunderstorm_outlined,
      cor: Colors.blueGrey,
    ),
    'npn': CondicaoTempoInfo(
      descricao: 'Nublado com pancadas à noite',
      icone: Icons.nights_stay,
      cor: Colors.blueGrey,
    ),
    'ncn': CondicaoTempoInfo(
      descricao: 'Nublado com possibilidade de chuva à noite',
      icone: Icons.cloud_queue,
      cor: Colors.blueGrey,
    ),
    'nct': CondicaoTempoInfo(
      descricao: 'Nublado com possibilidade de chuva à tarde',
      icone: Icons.cloud_queue,
      cor: Colors.blueGrey,
    ),
    'ncm': CondicaoTempoInfo(
      descricao: 'Nublado com possibilidade de chuva pela manhã',
      icone: Icons.cloud_queue,
      cor: Colors.blueGrey,
    ),
    'npm': CondicaoTempoInfo(
      descricao: 'Nublado com pancadas de manhã',
      icone: Icons.grain,
      cor: Colors.blueGrey,
    ),
    'npp': CondicaoTempoInfo(
      descricao: 'Nublado com possibilidade de pancadas',
      icone: Icons.cloud_queue,
      cor: Colors.blueGrey,
    ),
    'vn': CondicaoTempoInfo(
      descricao: 'Variação de nebulosidade',
      icone: Icons.cloud_sync,
      cor: Colors.blueGrey,
    ),
    'ct': CondicaoTempoInfo(
      descricao: 'Chuva à tarde',
      icone: Icons.wb_sunny,
      cor: Colors.blue,
    ),
    'ppn': CondicaoTempoInfo(
      descricao: 'Possibilidade de pancadas de chuva à noite',
      icone: Icons.nights_stay,
      cor: Colors.indigo,
    ),
    'ppt': CondicaoTempoInfo(
      descricao: 'Possibilidade de pancadas de chuva à tarde',
      icone: Icons.wb_sunny,
      cor: Colors.orange,
    ),
    'ppm': CondicaoTempoInfo(
      descricao: 'Possibilidade de pancadas de chuva pela manhã',
      icone: Icons.wb_twilight,
      cor: Colors.blue,
    ),
  };

  static CondicaoTempoInfo obter(String? sigla) {
    if (sigla == null || sigla.trim().isEmpty) {
      return const CondicaoTempoInfo(
        descricao: 'Condição não informada',
        icone: Icons.help_outline,
        cor: Colors.grey,
      );
    }
    final chave = sigla.trim().toLowerCase();
    return _mapa[chave] ??
        CondicaoTempoInfo(
          descricao: 'Condição ($sigla)',
          icone: Icons.cloud_outlined,
          cor: Colors.blueGrey,
        );
  }
}