import 'package:flutter/material.dart';

import 'enfoque_screen.dart';
import 'horario_screen.dart';
import 'inicio_screen.dart';
import 'notas_screen.dart';
import 'tareas_screen.dart';

/// Punto de corte (en píxeles lógicos) a partir del cual la navegación pasa
/// de una barra inferior a un riel lateral.
const anchoTablet = 640.0;

class _Destino {
  const _Destino(this.etiqueta, this.icono, this.iconoActivo);
  final String etiqueta;
  final IconData icono;
  final IconData iconoActivo;
}

const _destinos = [
  _Destino('Inicio', Icons.dashboard_outlined, Icons.dashboard),
  _Destino('Tareas', Icons.task_alt_outlined, Icons.task_alt),
  _Destino(
    'Horario',
    Icons.calendar_view_week_outlined,
    Icons.calendar_view_week,
  ),
  _Destino('Notas', Icons.school_outlined, Icons.school),
  _Destino('Enfoque', Icons.timer_outlined, Icons.timer),
];

/// Estructura de navegación adaptable.
///
/// * Ancho < 640: [Scaffold] + [NavigationBar] inferior (teléfono).
/// * Ancho >= 640: [Row] con [NavigationRail] + contenido (tablet).
/// * Ancho >= 1000: el riel se muestra extendido con etiquetas (escritorio).
///
/// Las pantallas viven dentro de un [IndexedStack] para conservar su estado
/// (por ejemplo, el temporizador de enfoque sigue corriendo al cambiar de
/// pestaña).
class ShellPrincipal extends StatefulWidget {
  const ShellPrincipal({super.key});

  @override
  State<ShellPrincipal> createState() => _ShellPrincipalState();
}

class _ShellPrincipalState extends State<ShellPrincipal> {
  int _indice = 0;

  void _irA(int i) => setState(() => _indice = i);

  @override
  Widget build(BuildContext context) {
    final paginas = IndexedStack(
      index: _indice,
      children: [
        InicioScreen(onVerTareas: () => _irA(1)),
        const TareasScreen(),
        const HorarioScreen(),
        const NotasScreen(),
        const EnfoqueScreen(),
      ],
    );

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth < anchoTablet) {
          return Scaffold(
            body: paginas,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: _irA,
              destinations: [
                for (final d in _destinos)
                  NavigationDestination(
                    icon: Icon(d.icono),
                    selectedIcon: Icon(d.iconoActivo),
                    label: d.etiqueta,
                  ),
              ],
            ),
          );
        }

        final extendido = restricciones.maxWidth >= 1000;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _indice,
                onDestinationSelected: _irA,
                extended: extendido,
                labelType: extendido
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: const Icon(Icons.auto_stories),
                  ),
                ),
                destinations: [
                  for (final d in _destinos)
                    NavigationRailDestination(
                      icon: Icon(d.icono),
                      selectedIcon: Icon(d.iconoActivo),
                      label: Text(d.etiqueta),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: paginas),
            ],
          ),
        );
      },
    );
  }
}
