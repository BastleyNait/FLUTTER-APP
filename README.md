# AgendaU — Laboratorio 04: Framework Multiplataforma

Aplicación Flutter para organizar las actividades académicas de estudiantes universitarios.
Curso: Plataformas Emergentes (E) — UNSA, Ingeniería de Sistemas.

Las pantallas responden a las causas del árbol de problemas (`docs/img/arbol.png`):

| Causa | Pantalla |
|---|---|
| Información de tareas dispersa | Tareas / Nueva tarea |
| Escasa planificación del horario | Horario |
| Falta de seguimiento de notas | Notas |
| Procrastinación | Enfoque (Pomodoro) |
| Sin visión general de pendientes | Inicio |

Solo usa componentes del SDK (Material 3 y widgets adaptativos), sin paquetes externos.
La navegación cambia según el ancho: `NavigationBar` (< 640 px), `NavigationRail` (≥ 640 px) y riel extendido (≥ 1000 px).

## Ejecutar

```bash
flutter pub get
flutter run            # dispositivo/emulador, o: flutter run -d chrome
flutter test
```

## Estructura

```
lib/
├── main.dart
├── data/        # modelos, estado (ChangeNotifier + InheritedNotifier), formato
├── screens/     # shell de navegación y las 6 pantallas
└── widgets/     # widgets reutilizables
docs/
├── Informe_Lab04_Plataformas_Emergentes.docx
└── img/         # capturas, wireframes, árbol de problemas
```
