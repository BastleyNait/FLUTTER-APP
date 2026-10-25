import 'package:flutter/material.dart';

import '../data/estado_app.dart';
import '../data/formato.dart';
import '../data/modelos.dart';

/// Formulario para registrar una tarea. Devuelve la [Tarea] creada al hacer
/// `Navigator.pop`, o nada si el usuario cancela.
class NuevaTareaScreen extends StatefulWidget {
  const NuevaTareaScreen({super.key});

  @override
  State<NuevaTareaScreen> createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  String? _cursoId;
  DateTime _entrega = DateUtils.dateOnly(DateTime.now())
      .add(const Duration(days: 1));
  Prioridad _prioridad = Prioridad.media;

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final fecha = await showDatePicker(
      context: context,
      initialDate: _entrega,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 180)),
      helpText: 'Fecha de entrega',
    );
    if (fecha != null) setState(() => _entrega = fecha);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Tarea(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        titulo: _titulo.text.trim(),
        descripcion: _descripcion.text.trim(),
        cursoId: _cursoId!,
        entrega: _entrega,
        prioridad: _prioridad,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cursos = AppScope.of(context).cursos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
        actions: [
          TextButton(onPressed: _guardar, child: const Text('Guardar')),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        // Center + ConstrainedBox limita el ancho del formulario en
        // pantallas grandes para que los campos no se estiren demasiado.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titulo,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa un título'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _cursoId,
                  decoration: const InputDecoration(
                    labelText: 'Curso',
                    prefixIcon: Icon(Icons.class_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final c in cursos)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (v) => setState(() => _cursoId = v),
                  validator: (v) => v == null ? 'Selecciona un curso' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _elegirFecha,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de entrega',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(fechaCorta(_entrega)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Prioridad',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<Prioridad>(
                  segments: [
                    for (final p in Prioridad.values)
                      ButtonSegment(value: p, label: Text(p.etiqueta)),
                  ],
                  selected: {_prioridad},
                  onSelectionChanged: (s) =>
                      setState(() => _prioridad = s.first),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descripcion,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar tarea'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
