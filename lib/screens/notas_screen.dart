import 'package:flutter/material.dart';

import '../data/estado_app.dart';
import '../data/formato.dart';
import '../data/modelos.dart';

/// Seguimiento de calificaciones: responde a la causa "desconocimiento del
/// avance académico". Calcula promedios ponderados en escala vigesimal y
/// permite registrar notas tocando la celda correspondiente.
class NotasScreen extends StatelessWidget {
  const NotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis notas')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ResumenPromedio(promedio: estado.promedioGeneral),
              const SizedBox(height: 16),
              for (final curso in estado.cursos) ...[
                _TarjetaCurso(curso: curso),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenPromedio extends StatelessWidget {
  const _ResumenPromedio({required this.promedio});

  final double? promedio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final aprobado = (promedio ?? 0) >= 10.5;
    return Card.filled(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Stack superpone el texto sobre el indicador circular.
            SizedBox.square(
              dimension: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: (promedio ?? 0) / 20,
                    strokeWidth: 10,
                    backgroundColor: tema.colorScheme.surface,
                  ),
                  Center(
                    child: Text(
                      nota(promedio),
                      style: tema.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Promedio general', style: tema.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Calculado con las evaluaciones ya registradas '
                    '(escala de 0 a 20).',
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: Icon(
                      aprobado ? Icons.check_circle : Icons.warning,
                      color: aprobado ? Colors.green : Colors.red,
                    ),
                    label: Text(aprobado ? 'Aprobando' : 'En riesgo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaCurso extends StatelessWidget {
  const _TarjetaCurso({required this.curso});

  final Curso curso;

  Future<void> _editarNota(BuildContext context, Evaluacion ev) async {
    final estado = AppScope.of(context);
    final controlador = TextEditingController(
      text: ev.nota?.toStringAsFixed(0) ?? '',
    );
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ev.nombre),
        content: TextField(
          controller: controlador,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Nota (0 - 20)',
            helperText: 'Déjalo vacío para quitar la nota',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controlador.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controlador.dispose();
    if (resultado == null) return;
    final valor = double.tryParse(resultado.replaceAll(',', '.'));
    if (valor == null || (valor >= 0 && valor <= 20)) {
      estado.registrarNota(ev, valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final promedio = curso.promedio;

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: curso.color,
          foregroundColor: Colors.white,
          child: Text(curso.nombre.substring(0, 1)),
        ),
        title: Text(curso.nombre),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: curso.avance,
                  color: curso.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(curso.avance * 100).round()}% evaluado',
                style: tema.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        trailing: Text(
          nota(promedio),
          style: tema.textTheme.titleLarge?.copyWith(
            color: promedio != null && promedio < 10.5 ? Colors.red : null,
          ),
        ),
        children: [
          // El scroll horizontal evita desbordes de la tabla en
          // pantallas estrechas.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Evaluación')),
                DataColumn(label: Text('Peso'), numeric: true),
                DataColumn(label: Text('Nota'), numeric: true),
              ],
              rows: [
                for (final ev in curso.evaluaciones)
                  DataRow(
                    cells: [
                      DataCell(Text(ev.nombre)),
                      DataCell(Text('${ev.peso.round()}%')),
                      DataCell(
                        Text(nota(ev.nota)),
                        showEditIcon: true,
                        onTap: () => _editarNota(context, ev),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Docente: ${curso.docente}',
                style: tema.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
