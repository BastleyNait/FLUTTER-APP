import 'package:flutter/material.dart';

/// Nivel de urgencia de una tarea. Cada valor define su etiqueta y su color
/// para que la interfaz no tenga que repetir esa lógica.
enum Prioridad {
  alta('Alta', Colors.red),
  media('Media', Colors.orange),
  baja('Baja', Colors.green);

  const Prioridad(this.etiqueta, this.color);
  final String etiqueta;
  final Color color;
}

/// Una evaluación de un curso (examen, práctica, proyecto...).
/// [peso] es el porcentaje sobre la nota final (0-100) y [nota] está en
/// escala vigesimal (0-20); es nula mientras no haya sido calificada.
class Evaluacion {
  Evaluacion({required this.nombre, required this.peso, this.nota});

  final String nombre;
  final double peso;
  double? nota;
}

class Curso {
  const Curso({
    required this.id,
    required this.nombre,
    required this.docente,
    required this.color,
    required this.evaluaciones,
  });

  final String id;
  final String nombre;
  final String docente;
  final Color color;
  final List<Evaluacion> evaluaciones;

  /// Promedio ponderado considerando solo las evaluaciones ya calificadas.
  double? get promedio {
    final calificadas = evaluaciones.where((e) => e.nota != null);
    final pesoTotal = calificadas.fold<double>(0, (s, e) => s + e.peso);
    if (pesoTotal == 0) return null;
    final suma = calificadas.fold<double>(0, (s, e) => s + e.nota! * e.peso);
    return suma / pesoTotal;
  }

  /// Porcentaje del curso que ya fue evaluado (0.0 - 1.0).
  double get avance {
    final total = evaluaciones.fold<double>(0, (s, e) => s + e.peso);
    final hecho = evaluaciones
        .where((e) => e.nota != null)
        .fold<double>(0, (s, e) => s + e.peso);
    return total == 0 ? 0 : hecho / total;
  }
}

class Tarea {
  Tarea({
    required this.id,
    required this.titulo,
    required this.cursoId,
    required this.entrega,
    this.descripcion = '',
    this.prioridad = Prioridad.media,
    this.completada = false,
  });

  final String id;
  String titulo;
  String cursoId;
  DateTime entrega;
  String descripcion;
  Prioridad prioridad;
  bool completada;

  /// Días que faltan para la entrega (negativo si ya venció).
  int get diasRestantes {
    final hoy = DateUtils.dateOnly(DateTime.now());
    return DateUtils.dateOnly(entrega).difference(hoy).inDays;
  }
}

/// Bloque de clase en el horario semanal. [dia] va de 1 (lunes) a 6 (sábado)
/// y las horas son enteras en formato de 24 h.
class Clase {
  const Clase({
    required this.cursoId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
    this.tipo = 'Teoría',
  });

  final String cursoId;
  final int dia;
  final int horaInicio;
  final int horaFin;
  final String aula;
  final String tipo;
}
