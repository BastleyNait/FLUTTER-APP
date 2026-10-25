import 'package:flutter/material.dart';

import '../data/estado_app.dart';
import '../data/modelos.dart';
import '../widgets/comunes.dart';
import 'nueva_tarea_screen.dart';

/// Gestión centralizada de tareas: responde a la causa "información de
/// tareas y fechas de entrega dispersa".
class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  String? _cursoFiltro;

  Future<void> _nuevaTarea() async {
    final tarea = await Navigator.of(context).push<Tarea>(
      MaterialPageRoute(
        builder: (_) => const NuevaTareaScreen(),
        fullscreenDialog: true,
      ),
    );
    if (tarea != null && mounted) {
      AppScope.of(context).agregarTarea(tarea);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarea "${tarea.titulo}" agregada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tareas'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pendientes (${estado.pendientes})'),
              const Tab(text: 'Completadas'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Filtro por curso: fila de chips con desplazamiento horizontal
            // para que no ocupe varias líneas en pantallas estrechas.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Todos'),
                    selected: _cursoFiltro == null,
                    onSelected: (_) => setState(() => _cursoFiltro = null),
                  ),
                  for (final c in estado.cursos)
                    ChoiceChip(
                      avatar: CircleAvatar(backgroundColor: c.color),
                      label: Text(c.nombre),
                      selected: _cursoFiltro == c.id,
                      onSelected: (_) => setState(() => _cursoFiltro = c.id),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ListaTareas(completadas: false, cursoId: _cursoFiltro),
                  _ListaTareas(completadas: true, cursoId: _cursoFiltro),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _nuevaTarea,
          icon: const Icon(Icons.add),
          label: const Text('Nueva tarea'),
        ),
      ),
    );
  }
}

class _ListaTareas extends StatelessWidget {
  const _ListaTareas({required this.completadas, this.cursoId});

  final bool completadas;
  final String? cursoId;

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);
    final tareas = estado.tareasFiltradas(
      completadas: completadas,
      cursoId: cursoId,
    );

    if (tareas.isEmpty) {
      return EstadoVacio(
        icono: completadas ? Icons.inbox : Icons.task_alt,
        mensaje: completadas
            ? 'Aún no completas tareas'
            : '¡Todo al día! No tienes tareas pendientes',
      );
    }

    // ListView.builder solo construye los elementos visibles.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: tareas.length,
      itemBuilder: (context, i) {
        final tarea = tareas[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          // Deslizar hacia la izquierda elimina la tarea (con opción de
          // deshacer).
          child: Dismissible(
            key: ValueKey(tarea.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline),
            ),
            onDismissed: (_) {
              estado.eliminarTarea(tarea);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: const Text('Tarea eliminada'),
                    action: SnackBarAction(
                      label: 'Deshacer',
                      onPressed: () => estado.restaurarTarea(tarea),
                    ),
                  ),
                );
            },
            child: TareaTile(tarea: tarea),
          ),
        );
      },
    );
  }
}
