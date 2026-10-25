import 'package:flutter/material.dart';

import '../data/estado_app.dart';
import '../data/formato.dart';
import '../data/modelos.dart';
import 'shell_principal.dart';

/// Horario semanal: responde a la causa "escasa planificación del tiempo".
///
/// En teléfonos se muestra un día por pestaña (línea de tiempo vertical).
/// En pantallas anchas se muestra la semana completa en una [Table].
class HorarioScreen extends StatelessWidget {
  const HorarioScreen({super.key});

  static const _dias = 6; // lunes a sábado

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now().weekday;
    return DefaultTabController(
      length: _dias,
      initialIndex: hoy <= _dias ? hoy - 1 : 0,
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final ancho = restricciones.maxWidth >= anchoTablet;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Horario semanal'),
              bottom: ancho
                  ? null
                  : TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        for (var d = 0; d < _dias; d++)
                          Tab(text: diasCortos[d]),
                      ],
                    ),
            ),
            body: ancho
                ? const _TablaSemanal(dias: _dias)
                : TabBarView(
                    children: [
                      for (var d = 1; d <= _dias; d++) _LineaDelDia(dia: d),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// Vista de un día como línea de tiempo: la hora a la izquierda y la
/// tarjeta de la clase ocupando el resto del ancho con [Expanded].
class _LineaDelDia extends StatelessWidget {
  const _LineaDelDia({required this.dia});

  final int dia;

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);
    final clases = estado.clasesDelDia(dia);
    final tema = Theme.of(context);

    if (clases.isEmpty) {
      return const Center(child: Text('Sin clases este día'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clases.length,
      itemBuilder: (context, i) {
        final clase = clases[i];
        final curso = estado.curso(clase.cursoId);
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    Text(
                      hora(clase.horaInicio),
                      style: tema.textTheme.labelLarge,
                    ),
                    Expanded(
                      child: VerticalDivider(
                        thickness: 2,
                        color: curso.color.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(hora(clase.horaFin), style: tema.textTheme.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _BloqueClase(clase: clase, curso: curso),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BloqueClase extends StatelessWidget {
  const _BloqueClase({
    required this.clase,
    required this.curso,
    this.compacto = false,
  });

  final Clase clase;
  final Curso curso;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(compacto ? 8 : 16),
      decoration: BoxDecoration(
        color: curso.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: curso.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            curso.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                (compacto
                        ? tema.textTheme.labelMedium
                        : tema.textTheme.titleSmall)
                    ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.room_outlined, size: 14, color: curso.color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  compacto ? clase.aula : '${clase.tipo} · ${clase.aula}',
                  overflow: TextOverflow.ellipsis,
                  style: tema.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (!compacto) ...[
            const SizedBox(height: 4),
            Text(curso.docente, style: tema.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Cuadrícula semanal. [Table] alinea filas (franjas horarias) y columnas
/// (días) sin que cada celda tenga que conocer el tamaño de las demás.
class _TablaSemanal extends StatelessWidget {
  const _TablaSemanal({required this.dias});

  final int dias;

  static const _franjas = [7, 9, 11, 14, 16, 18];

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);
    final tema = Theme.of(context);
    final borde = tema.colorScheme.outlineVariant;

    Widget celda(int dia, int horaInicio) {
      final clase = estado.clases
          .where((c) => c.dia == dia && c.horaInicio == horaInicio)
          .firstOrNull;
      return Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 76,
          child: clase == null
              ? null
              : _BloqueClase(
                  clase: clase,
                  curso: estado.curso(clase.cursoId),
                  compacto: true,
                ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {0: FixedColumnWidth(64)},
        defaultColumnWidth: const FlexColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: borde),
          verticalInside: BorderSide(color: borde),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: tema.colorScheme.surfaceContainerHighest,
            ),
            children: [
              const SizedBox(height: 40),
              for (var d = 0; d < dias; d++)
                Center(
                  child: Text(diasCortos[d], style: tema.textTheme.labelLarge),
                ),
            ],
          ),
          for (final h in _franjas)
            TableRow(
              children: [
                Center(child: Text(hora(h), style: tema.textTheme.labelMedium)),
                for (var d = 1; d <= dias; d++) celda(d, h),
              ],
            ),
        ],
      ),
    );
  }
}
