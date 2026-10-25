import 'package:flutter/material.dart';

import 'data/estado_app.dart';
import 'screens/shell_principal.dart';

void main() {
  runApp(AgendaUApp(estado: EstadoApp()));
}

/// Raíz de la aplicación: define el tema Material 3 (claro y oscuro) y
/// coloca [AppScope] por encima de [MaterialApp] para que el estado sea
/// accesible desde cualquier pantalla, incluidas las rutas apiladas.
class AgendaUApp extends StatelessWidget {
  const AgendaUApp({super.key, required this.estado});

  final EstadoApp estado;

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFF6A1B9A);
    return AppScope(
      estado: estado,
      child: MaterialApp(
        title: 'AgendaU',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: semilla,
          useMaterial3: true,
          cardTheme: const CardThemeData(margin: EdgeInsets.zero),
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: semilla,
          brightness: Brightness.dark,
          useMaterial3: true,
          cardTheme: const CardThemeData(margin: EdgeInsets.zero),
        ),
        home: const ShellPrincipal(),
      ),
    );
  }
}
