# Gestor de tareas con SQLite

Aplicación Flutter multiplataforma para administrar tareas con persistencia local real en SQLite. Fue desarrollada como práctica de la materia Programación de Dispositivos Móviles de la UAA.

## Tecnología de persistencia

Se eligió **Drift + drift_flutter** porque permiten compartir la misma capa de datos entre Android, iOS, Windows, Linux, macOS y web. En plataformas nativas se usa un archivo SQLite y en web se usa WebAssembly con el worker de Drift y almacenamiento del navegador (OPFS o IndexedDB).

La base se abre desde `lib/data/app_database.dart` con `driftDatabase(name: 'gestor_tareas')`. En Windows el archivo queda en la carpeta de documentos del usuario como `gestor_tareas.sqlite`.

### Esquema de la tabla

```sql
CREATE TABLE "tareas" (
  "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "titulo" TEXT NOT NULL,
  "completada" INTEGER NOT NULL DEFAULT 0
    CHECK ("completada" IN (0, 1))
);
```

El modelo usa `id` entero autoincremental, `titulo` de texto y `completada` como booleano almacenado como 0/1.

## Funcionalidades

- Alta de tareas con validación de títulos vacíos o solo con espacios.
- Consulta reactiva mediante `StreamBuilder` y `watchTareas()`.
- Edición del título con diálogo y validación.
- Cambio de estado completada/pendiente.
- Eliminación con confirmación por identificador.
- Mensajes de error comprensibles si falla el almacenamiento.
- Consultas fuera de `build()` y cierre de la base al liberar la pantalla.
- Datos persistentes al cerrar y volver a abrir la aplicación.

## Estructura

```text
lib/
  main.dart
  data/
    app_database.dart
    app_database.g.dart
  screens/
    tareas_page.dart
test/
  database_test.dart
  widget_test.dart
web/
  sqlite3.wasm
  drift_worker.dart.js
evidencias/
```

## Requisitos

- Flutter stable (probado con 3.47.7 y Dart 3.13.5).
- Chrome para la versión web.
- Visual Studio Build Tools para Windows.
- Xcode para iOS/macOS y Android SDK para Android si se compilan esas plataformas.

## Cómo ejecutar

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Si se modifica la tabla hay que regenerar el código de Drift:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Para web:

```bash
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
```

Para una compilación web de producción:

```bash
flutter build web
```

El servidor debe entregar `sqlite3.wasm` con `Content-Type: application/wasm` y, para usar OPFS, agregar los encabezados COOP/COEP. Si no se agregan, Drift usa IndexedDB como respaldo y la persistencia también funciona en el mismo origen y perfil.

Los archivos `web/sqlite3.wasm` y `web/drift_worker.dart.js` corresponden a la versión de Drift 2.35.4 registrada en `pubspec.lock`. No deben eliminarse.

## Pruebas automatizadas

```bash
flutter test
```

Se incluyen 10 pruebas, todas aprobadas:

- 6 pruebas de base de datos: alta, consulta, edición, cambio de estado, eliminación, validación y persistencia después de cerrar y abrir la base.
- 4 pruebas de interfaz: apertura de la pantalla, rechazo de título vacío, alta de tarea y edición de título.

`flutter analyze` no reporta problemas.

## Comprobación manual P1–P6

| Prueba | Windows nativo | Web (Chrome) |
| --- | --- | --- |
| P1. Agregar tres tareas y reiniciar | Las tres permanecen | Las tres permanecen |
| P2. Marcar completada y reiniciar | El estado se conserva | El estado se conserva |
| P3. Editar título y reiniciar | El nuevo título se conserva | El nuevo título se conserva |
| P4. Eliminar tarea y reiniciar | No reaparece | No reaparece |
| P5. Intentar agregar título vacío | No se registra y muestra aviso | No se registra y muestra aviso |
| P6. Recargar o cerrar/abrir en web | No aplica | Los datos permanecen en el mismo origen y perfil |

En web se verificó que Drift crea la carpeta `drift_db/gestor_tareas` en OPFS y que los datos sobreviven a recargar la página y a cerrar y abrir el navegador. En Windows se verificó el archivo `gestor_tareas.sqlite` y su contenido con una consulta SQLite externa.

## Plataformas

Probadas en ejecución:

- **Windows 11**: compilación nativa, operaciones CRUD y persistencia después de cerrar y reabrir.
- **Web**: Chrome, con `sqlite3.wasm` y `drift_worker.dart.js`, recarga y reinicio del navegador.

Diseñadas y previstas con el mismo código, pero no ejecutadas en este entorno:

- Android e iOS: requieren Android SDK y macOS con Xcode.
- Linux y macOS: requieren esos sistemas para compilar.

Limitaciones web: la información queda ligada al origen y al perfil del navegador. En modo privado o al borrar los datos del sitio se puede perder. Sin los encabezados COOP/COEP la persistencia usa IndexedDB en lugar de OPFS y puede ser más lenta.

## Evidencias

La carpeta `evidencias/` contiene capturas de las pruebas P1–P6 en Windows y web, la salida de las pruebas automatizadas, el análisis estático y la consulta a la base SQLite.

## Uso de IA

Se usó un asistente de IA como apoyo para consultar dudas de Drift, revisar errores y proponer fragmentos pequeños de código. La verificación se hizo con `flutter analyze`, las 10 pruebas automatizadas, ejecución manual en Windows y Chrome y consultas directas a la base SQLite. El reporte de la práctica incluye el detalle del uso de IA.
