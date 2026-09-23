const _nomesMeses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

/// Mesma lógica do data_por_extenso() da versão de PC.
String dataPorExtenso(String cidade) {
  final hoje = DateTime.now();
  final texto = '${hoje.day} de ${_nomesMeses[hoje.month - 1]} de ${hoje.year}';
  return cidade.trim().isEmpty ? texto : '${cidade.trim()}, $texto';
}
