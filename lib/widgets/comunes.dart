import 'package:flutter/material.dart';

import '../data/estado_app.dart';
import '../data/formato.dart';
import '../data/modelos.dart';

/// Título de sección con acción opcional alineada a la derecha.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.accion});

  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?accion,
        ],
      ),
    );
  }
}

/// Tarjeta de indicador para el panel de inicio.
class TarjetaIndicador extends StatelessWidget {
  const TarjetaIndicador({
    super.key,
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icono, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(valor, style: tema.textTheme.headlineMedium),
                ),
                Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta compacta de prioridad.
class EtiquetaPrioridad extends StatelessWidget {
  const EtiquetaPrioridad(this.prioridad, {super.key});

  final Prioridad prioridad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: prioridad.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        prioridad.etiqueta,
        style: TextStyle(
          color: prioridad.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Fila de una tarea: casilla para completarla, curso, plazo y prioridad.
class TareaTile extends StatelessWidget {
  const TareaTile({super.key, required this.tarea});

  final Tarea tarea;

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);
    final curso = estado.curso(tarea.cursoId);
    final tema = Theme.of(context);
    final vencida = !tarea.completada && tarea.diasRestantes < 0;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      // Franja izquierda con el color del curso.
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: curso.color, width: 6)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 4, right: 12),
          leading: Checkbox(
            value: tarea.completada,
            onChanged: (_) => estado.alternarTarea(tarea),
          ),
          title: Text(
            tarea.titulo,
            style: tarea.completada
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: Wrap(
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(curso.nombre),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: vencida ? tema.colorScheme.error : null,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${fechaCorta(tarea.entrega)} · '
                      '${plazo(tarea.diasRestantes)}',
                      overflow: TextOverflow.ellipsis,
                      style: vencida
                          ? TextStyle(color: tema.colorScheme.error)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: EtiquetaPrioridad(tarea.prioridad),
        ),
      ),
    );
  }
}

/// Mensaje centrado para listas vacías.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.icono, required this.mensaje});

  final IconData icono;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outline;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: color),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
