import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirConexion() {
    return driftDatabase(
      name: 'gestor_tareas',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  Stream<List<Tarea>> watchTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  Future<int> crearTarea(String titulo) {
    return into(tareas).insert(
      TareasCompanion.insert(titulo: _validarTitulo(titulo)),
    );
  }

  Future<bool> actualizarTitulo(int id, String titulo) async {
    final filas = await (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(titulo: Value(_validarTitulo(titulo))),
    );
    return filas > 0;
  }

  Future<bool> cambiarEstado(int id, bool completada) async {
    final filas = await (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );
    return filas > 0;
  }

  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }

  String _validarTitulo(String titulo) {
    final limpio = titulo.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('El titulo no puede estar vacio');
    }
    if (limpio.length > 200) {
      throw ArgumentError('El titulo no puede superar los 200 caracteres');
    }
    return limpio;
  }
}
