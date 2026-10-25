/// Utilidades de formato en español sin dependencias externas.
library;

const diasCortos = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const diasLargos = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
const _mesesLargos = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];
const _meses = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Ej.: "Lun 27 oct".
String fechaCorta(DateTime f) =>
    '${diasCortos[f.weekday - 1]} ${f.day} ${_meses[f.month - 1]}';

/// Ej.: "Domingo 25 de octubre".
String fechaLarga(DateTime f) =>
    '${diasLargos[f.weekday - 1]} ${f.day} de ${_mesesLargos[f.month - 1]}';

String hora(int h) => '${h.toString().padLeft(2, '0')}:00';

/// Texto relativo para una entrega: "Hoy", "Mañana", "En 3 días", "Venció".
String plazo(int dias) => switch (dias) {
  < 0 => 'Venció hace ${-dias} d',
  0 => 'Hoy',
  1 => 'Mañana',
  _ => 'En $dias días',
};

String nota(double? n) => n == null ? '--' : n.toStringAsFixed(1);
