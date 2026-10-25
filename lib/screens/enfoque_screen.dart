import 'dart:async';

import 'package:flutter/material.dart';

import '../data/estado_app.dart';

enum _Modo {
  enfoque('Enfoque', 25, Icons.psychology),
  descanso('Descanso', 5, Icons.coffee);

  const _Modo(this.etiqueta, this.minutos, this.icono);
  final String etiqueta;
  final int minutos;
  final IconData icono;
}

/// Temporizador Pomodoro: responde a la causa "procrastinación y
/// distracciones durante el estudio".
class EnfoqueScreen extends StatefulWidget {
  const EnfoqueScreen({super.key});

  @override
  State<EnfoqueScreen> createState() => _EnfoqueScreenState();
}

class _EnfoqueScreenState extends State<EnfoqueScreen> {
  _Modo _modo = _Modo.enfoque;
  late int _restante = _modo.minutos * 60;
  Timer? _timer;
  bool _avisar = true;

  bool get _corriendo => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _alternar() {
    if (_corriendo) {
      _timer!.cancel();
      setState(() {});
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restante > 1) {
        setState(() => _restante--);
      } else {
        _terminar();
      }
    });
    setState(() {});
  }

  void _terminar() {
    _timer?.cancel();
    if (_modo == _Modo.enfoque) {
      AppScope.of(context).registrarSesionEnfoque(_Modo.enfoque.minutos);
    }
    if (_avisar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modo == _Modo.enfoque
                ? '¡Sesión completada! Toma un descanso.'
                : 'Descanso terminado. ¡A seguir!',
          ),
        ),
      );
    }
    _cambiarModo(_modo == _Modo.enfoque ? _Modo.descanso : _Modo.enfoque);
  }

  void _cambiarModo(_Modo modo) {
    _timer?.cancel();
    setState(() {
      _modo = modo;
      _restante = modo.minutos * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final estado = AppScope.of(context);
    final total = _modo.minutos * 60;
    final mm = (_restante ~/ 60).toString().padLeft(2, '0');
    final ss = (_restante % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Modo enfoque')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<_Modo>(
                  segments: [
                    for (final m in _Modo.values)
                      ButtonSegment(
                        value: m,
                        icon: Icon(m.icono),
                        label: Text('${m.etiqueta} ${m.minutos}′'),
                      ),
                  ],
                  selected: {_modo},
                  onSelectionChanged: (s) => _cambiarModo(s.first),
                ),
                const SizedBox(height: 32),
                // Reloj: indicador circular con el tiempo centrado encima.
                SizedBox.square(
                  dimension: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _restante / total,
                        strokeWidth: 14,
                        strokeCap: StrokeCap.round,
                        backgroundColor:
                            tema.colorScheme.surfaceContainerHighest,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$mm:$ss',
                              style: tema.textTheme.displayMedium,
                            ),
                            Text(
                              _modo.etiqueta,
                              style: tema.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Reiniciar',
                      onPressed: () => _cambiarModo(_modo),
                      icon: const Icon(Icons.replay),
                    ),
                    const SizedBox(width: 24),
                    SizedBox.square(
                      dimension: 80,
                      child: FloatingActionButton.large(
                        heroTag: 'enfoque',
                        onPressed: _alternar,
                        child: Icon(
                          _corriendo ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton.filledTonal(
                      tooltip: 'Saltar',
                      onPressed: _terminar,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card.outlined(
                    child: Column(
                      children: [
                        // Switch.adaptive usa el estilo Cupertino en iOS y
                        // Material en Android.
                        SwitchListTile.adaptive(
                          title: const Text('Avisar al terminar'),
                          value: _avisar,
                          onChanged: (v) => setState(() => _avisar = v),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.local_fire_department),
                          title: Text('Sesiones de hoy: ${estado.sesionesHoy}'),
                          subtitle: Text(
                            '${estado.minutosEnfoqueHoy} minutos de estudio',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Wrap(
                            spacing: 6,
                            children: [
                              for (var i = 0; i < 4; i++)
                                Icon(
                                  i < estado.sesionesHoy.clamp(0, 4)
                                      ? Icons.circle
                                      : Icons.circle_outlined,
                                  size: 16,
                                  color: tema.colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
