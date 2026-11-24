import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('guarda y consulta tareas ordenadas por id', () async {
    await db.crearTarea('Comprar leche');
    await db.crearTarea('Terminar la practica');

    final tareas = await db.watchTareas().first;

    expect(tareas, hasLength(2));
    expect(tareas[0].titulo, 'Comprar leche');
    expect(tareas[1].titulo, 'Terminar la practica');
    expect(tareas.every((t) => !t.completada), isTrue);
  });

  test('actualiza el titulo y conserva el cambio', () async {
    final id = await db.crearTarea('Titulo original');

    final actualizado = await db.actualizarTitulo(id, 'Titulo nuevo');
    final tareas = await db.watchTareas().first;

    expect(actualizado, isTrue);
    expect(tareas.single.titulo, 'Titulo nuevo');
  });

  test('cambia el estado de una tarea', () async {
    final id = await db.crearTarea('Tarea pendiente');

    final actualizado = await db.cambiarEstado(id, true);
    final tareas = await db.watchTareas().first;

    expect(actualizado, isTrue);
    expect(tareas.single.completada, isTrue);
  });

  test('elimina una tarea por su id', () async {
    final id = await db.crearTarea('Tarea temporal');

    final eliminadas = await db.eliminarTarea(id);
    final tareas = await db.watchTareas().first;

    expect(eliminadas, 1);
    expect(tareas, isEmpty);
  });

  test('rechaza titulos vacios o solo con espacios', () async {
    expect(() => db.crearTarea('   '), throwsArgumentError);
  });

  test('los datos siguen despues de cerrar y abrir la base', () async {
    final carpeta = Directory.systemTemp.createTempSync('gestor_tareas_test');
    final archivo = File('${carpeta.path}/tareas.sqlite');

    final primera = AppDatabase.forTesting(NativeDatabase(archivo));
    final id = await primera.crearTarea('Sobrevivir al reinicio');
    await primera.cambiarEstado(id, true);
    await primera.close();

    final segunda = AppDatabase.forTesting(NativeDatabase(archivo));
    final tareas = await segunda.watchTareas().first;
    await segunda.close();

    expect(tareas, hasLength(1));
    expect(tareas.single.titulo, 'Sobrevivir al reinicio');
    expect(tareas.single.completada, isTrue);

    carpeta.deleteSync(recursive: true);
  });
}
