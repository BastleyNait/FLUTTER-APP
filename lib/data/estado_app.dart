import 'package:flutter/material.dart';

import 'modelos.dart';

/// Estado global de la aplicación. Se mantiene en memoria y notifica a los
/// widgets que dependen de él cada vez que cambia.
class EstadoApp extends ChangeNotifier {
  EstadoApp() : _tareas = _tareasIniciales();

  final List<Curso> cursos = _cursosIniciales();
  final List<Clase> clases = _clasesIniciales;
  final List<Tarea> _tareas;
  int minutosEnfoqueHoy = 0;
  int sesionesHoy = 0;

  List<Tarea> get tareas => List.unmodifiable(_tareas);

  Curso curso(String id) => cursos.firstWhere((c) => c.id == id);

  List<Tarea> tareasFiltradas({required bool completadas, String? cursoId}) {
    final lista =
        _tareas
            .where((t) => t.completada == completadas)
            .where((t) => cursoId == null || t.cursoId == cursoId)
            .toList()
          ..sort((a, b) => a.entrega.compareTo(b.entrega));
    return lista;
  }

  int get pendientes => _tareas.where((t) => !t.completada).length;

  /// Tareas pendientes que vencen en los próximos [dias] días.
  List<Tarea> proximasEntregas({int dias = 7}) =>
      tareasFiltradas(completadas: false)
          .where((t) => t.diasRestantes <= dias)
          .toList();

  List<Clase> clasesDelDia(int dia) =>
      clases.where((c) => c.dia == dia).toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

  /// Día (1-7) con clases más cercano a partir de [desde], incluido.
  int? proximoDiaConClases(int desde) {
    for (var i = 0; i < 7; i++) {
      final dia = (desde - 1 + i) % 7 + 1;
      if (clases.any((c) => c.dia == dia)) return dia;
    }
    return null;
  }

  double? get promedioGeneral {
    final promedios = cursos.map((c) => c.promedio).whereType<double>();
    if (promedios.isEmpty) return null;
    return promedios.reduce((a, b) => a + b) / promedios.length;
  }

  void agregarTarea(Tarea tarea) {
    _tareas.add(tarea);
    notifyListeners();
  }

  void alternarTarea(Tarea tarea) {
    tarea.completada = !tarea.completada;
    notifyListeners();
  }

  void eliminarTarea(Tarea tarea) {
    _tareas.remove(tarea);
    notifyListeners();
  }

  void restaurarTarea(Tarea tarea) {
    _tareas.add(tarea);
    notifyListeners();
  }

  void registrarNota(Evaluacion evaluacion, double? nota) {
    evaluacion.nota = nota;
    notifyListeners();
  }

  void registrarSesionEnfoque(int minutos) {
    minutosEnfoqueHoy += minutos;
    sesionesHoy++;
    notifyListeners();
  }
}

/// Expone [EstadoApp] a todo el árbol de widgets. Los widgets que llaman a
/// [AppScope.of] se reconstruyen automáticamente cuando el estado notifica.
class AppScope extends InheritedNotifier<EstadoApp> {
  const AppScope({super.key, required EstadoApp estado, required super.child})
    : super(notifier: estado);

  static EstadoApp of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

// ---------------------------------------------------------------------------
// Datos de ejemplo (semestre VIII - Ingeniería de Sistemas)
// ---------------------------------------------------------------------------

List<Curso> _cursosIniciales() => [
  Curso(
    id: 'pe',
    nombre: 'Plataformas Emergentes',
    docente: 'R. Fabrizio Calienes R.',
    color: Colors.indigo,
    evaluaciones: [
      Evaluacion(nombre: 'Laboratorios', peso: 30, nota: 17),
      Evaluacion(nombre: 'Examen parcial', peso: 30, nota: 15),
      Evaluacion(nombre: 'Proyecto final', peso: 40),
    ],
  ),
  Curso(
    id: 'ia',
    nombre: 'Inteligencia Artificial',
    docente: 'Docente del curso',
    color: Colors.teal,
    evaluaciones: [
      Evaluacion(nombre: 'Prácticas', peso: 25, nota: 16),
      Evaluacion(nombre: 'Examen parcial', peso: 35, nota: 13),
      Evaluacion(nombre: 'Examen final', peso: 40),
    ],
  ),
  Curso(
    id: 'gp',
    nombre: 'Gestión de Proyectos de TI',
    docente: 'Docente del curso',
    color: Colors.deepOrange,
    evaluaciones: [
      Evaluacion(nombre: 'Trabajo grupal', peso: 40, nota: 18),
      Evaluacion(nombre: 'Examen parcial', peso: 30, nota: 14),
      Evaluacion(nombre: 'Examen final', peso: 30),
    ],
  ),
  Curso(
    id: 'sd',
    nombre: 'Sistemas Distribuidos',
    docente: 'Docente del curso',
    color: Colors.purple,
    evaluaciones: [
      Evaluacion(nombre: 'Laboratorios', peso: 30, nota: 12),
      Evaluacion(nombre: 'Examen parcial', peso: 30),
      Evaluacion(nombre: 'Examen final', peso: 40),
    ],
  ),
];

List<Tarea> _tareasIniciales() {
  final hoy = DateUtils.dateOnly(DateTime.now());
  DateTime en(int dias) => hoy.add(Duration(days: dias));
  return [
    Tarea(
      id: 't1',
      titulo: 'Laboratorio 4: Framework multiplataforma',
      cursoId: 'pe',
      entrega: en(1),
      prioridad: Prioridad.alta,
      descripcion: 'Diseñar interfaces en Flutter y redactar el informe.',
    ),
    Tarea(
      id: 't2',
      titulo: 'Informe de búsqueda A*',
      cursoId: 'ia',
      entrega: en(3),
      prioridad: Prioridad.media,
    ),
    Tarea(
      id: 't3',
      titulo: 'Acta de constitución del proyecto',
      cursoId: 'gp',
      entrega: en(5),
      prioridad: Prioridad.media,
    ),
    Tarea(
      id: 't4',
      titulo: 'Práctica de sockets RPC',
      cursoId: 'sd',
      entrega: en(9),
      prioridad: Prioridad.baja,
    ),
    Tarea(
      id: 't5',
      titulo: 'Cuestionario de redes neuronales',
      cursoId: 'ia',
      entrega: en(-2),
      prioridad: Prioridad.alta,
      completada: true,
    ),
    Tarea(
      id: 't6',
      titulo: 'Laboratorio 3: Arquitectura PWA',
      cursoId: 'pe',
      entrega: en(-6),
      completada: true,
    ),
  ];
}

const _clasesIniciales = [
  Clase(cursoId: 'pe', dia: 1, horaInicio: 7, horaFin: 9, aula: 'Lab. 3'),
  Clase(cursoId: 'ia', dia: 1, horaInicio: 9, horaFin: 11, aula: 'Aula 201'),
  Clase(cursoId: 'gp', dia: 2, horaInicio: 11, horaFin: 13, aula: 'Aula 105'),
  Clase(cursoId: 'sd', dia: 2, horaInicio: 14, horaFin: 16, aula: 'Lab. 1'),
  Clase(
    cursoId: 'pe',
    dia: 3,
    horaInicio: 7,
    horaFin: 9,
    aula: 'Lab. 3',
    tipo: 'Laboratorio',
  ),
  Clase(
    cursoId: 'ia',
    dia: 3,
    horaInicio: 14,
    horaFin: 16,
    aula: 'Lab. 2',
    tipo: 'Laboratorio',
  ),
  Clase(cursoId: 'sd', dia: 4, horaInicio: 9, horaFin: 11, aula: 'Aula 302'),
  Clase(cursoId: 'gp', dia: 4, horaInicio: 16, horaFin: 18, aula: 'Aula 105'),
  Clase(cursoId: 'ia', dia: 5, horaInicio: 7, horaFin: 9, aula: 'Aula 201'),
  Clase(
    cursoId: 'sd',
    dia: 5,
    horaInicio: 11,
    horaFin: 13,
    aula: 'Lab. 1',
    tipo: 'Laboratorio',
  ),
  Clase(
    cursoId: 'gp',
    dia: 6,
    horaInicio: 9,
    horaFin: 11,
    aula: 'Aula 105',
    tipo: 'Taller',
  ),
];
