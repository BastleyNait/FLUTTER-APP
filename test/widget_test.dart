import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agenda_u/data/estado_app.dart';
import 'package:agenda_u/main.dart';

void main() {
  Future<void> abrir(WidgetTester tester, Size tamano) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AgendaUApp(estado: EstadoApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('En teléfono usa NavigationBar', (tester) async {
    await abrir(tester, const Size(400, 850));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Tareas pendientes'), findsOneWidget);
  });

  testWidgets('En tablet usa NavigationRail', (tester) async {
    await abrir(tester, const Size(1100, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Marcar una tarea la mueve a completadas', (tester) async {
    await abrir(tester, const Size(400, 850));
    await tester.tap(find.text('Tareas').last);
    await tester.pumpAndSettle();
    expect(find.text('Pendientes (4)'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('Pendientes (3)'), findsOneWidget);
  });

  test('Promedio ponderado considera solo notas registradas', () {
    final estado = EstadoApp();
    // Plataformas Emergentes: (17*30 + 15*30) / 60 = 16.0
    expect(estado.curso('pe').promedio, 16.0);
    expect(estado.curso('pe').avance, closeTo(0.6, 1e-9));
  });
}
