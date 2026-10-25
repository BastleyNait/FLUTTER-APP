import 'package:flutter/material.dart';

import '../data/estado_app.dart';
import '../data/formato.dart';
import '../data/modelos.dart';
import '../widgets/comunes.dart';

/// Panel de resumen: responde a la causa "falta de una visión general de las
/// actividades académicas". Está construido con slivers para que la cabecera
/// se contraiga al desplazar.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key, required this.onVerTareas});

  final VoidCallback onVerTareas;

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);
    final tema = Theme.of(context);
    final hoy = DateTime.now();
    // Si hoy no hay clases se muestran las del siguiente día que tenga.
    final diaClases = estado.proximoDiaConClases(hoy.weekday);
    final clasesHoy = diaClases == null
        ? const <Clase>[]
        : estado.clasesDelDia(diaClases);
    final tituloClases = diaClases == hoy.weekday
        ? 'Clases de hoy'
        : 'Próximas clases · ${diasLargos[(diaClases ?? 1) - 1]}';
    final proximas = estado.proximasEntregas();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 180,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
              start: 16,
              bottom: 14,
            ),
            title: const Text('AgendaU'),
            background: _Cabecera(fecha: hoy),
          ),
        ),

        // Indicadores en una cuadrícula que ajusta el número de columnas
        // al ancho disponible (máx. 220 px por tarjeta).
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverGrid.extent(
            maxCrossAxisExtent: 220,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              TarjetaIndicador(
                icono: Icons.pending_actions,
                valor: '${estado.pendientes}',
                etiqueta: 'Tareas pendientes',
                color: Colors.orange,
              ),
              TarjetaIndicador(
                icono: Icons.event_busy,
                valor: '${proximas.length}',
                etiqueta: 'Vencen esta semana',
                color: Colors.red,
              ),
              TarjetaIndicador(
                icono: Icons.grade,
                valor: nota(estado.promedioGeneral),
                etiqueta: 'Promedio general',
                color: Colors.indigo,
              ),
              TarjetaIndicador(
                icono: Icons.timer,
                valor: '${estado.minutosEnfoqueHoy} min',
                etiqueta: 'Enfoque de hoy',
                color: Colors.teal,
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(child: TituloSeccion(tituloClases)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 112,
            child: clasesHoy.isEmpty
                ? const Center(child: Text('No tienes clases registradas'))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: clasesHoy.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final clase = clasesHoy[i];
                      final curso = estado.curso(clase.cursoId);
                      return SizedBox(
                        width: 220,
                        child: Card.filled(
                          color: curso.color.withValues(alpha: 0.12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${hora(clase.horaInicio)} - '
                                  '${hora(clase.horaFin)}',
                                  style: tema.textTheme.labelLarge?.copyWith(
                                    color: curso.color,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  curso.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tema.textTheme.titleSmall,
                                ),
                                Text(
                                  '${clase.tipo} · ${clase.aula}',
                                  style: tema.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: TituloSeccion(
            'Próximas entregas',
            accion: TextButton(
              onPressed: onVerTareas,
              child: const Text('Ver todas'),
            ),
          ),
        ),
        if (proximas.isEmpty)
          const SliverToBoxAdapter(
            child: EstadoVacio(
              icono: Icons.celebration,
              mensaje: 'No hay entregas en los próximos 7 días',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: proximas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => TareaTile(tarea: proximas[i]),
            ),
          ),
      ],
    );
  }
}

/// Fondo de la cabecera: degradado con un ícono decorativo superpuesto
/// mediante [Stack] y [Positioned].
class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.fecha});

  final DateTime fecha;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [esquema.primaryContainer, esquema.tertiaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          right: -20,
          top: -10,
          child: Icon(
            Icons.auto_stories,
            size: 160,
            color: esquema.onPrimaryContainer.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 52,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, Sebastian!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                fechaLarga(fecha),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
