import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/main.dart';

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pumpAndSettle();

    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Todavia no hay tareas guardadas'), findsOneWidget);

    await db.close();
  });

  testWidgets('No registra una tarea con titulo vacio', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Escribe un titulo valido'), findsOneWidget);
    expect(find.text('Todavia no hay tareas guardadas'), findsOneWidget);

    await db.close();
  });

  testWidgets('Agrega una tarea y la muestra en la lista', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Estudiar para el examen');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Estudiar para el examen'), findsOneWidget);
    expect(find.text('Todavia no hay tareas guardadas'), findsNothing);

    await db.close();
  });

  testWidgets('Edita el titulo de una tarea existente', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Titulo original');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Titulo corregido');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Titulo corregido'), findsOneWidget);
    expect(find.text('Titulo original'), findsNothing);

    await db.close();
  });
}
