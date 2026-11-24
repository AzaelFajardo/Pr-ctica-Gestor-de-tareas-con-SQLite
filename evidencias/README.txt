Evidencias de la practica Gestor de tareas con SQLite
Alumno: Angel Azael Fajardo Espino
Fecha: 23 de noviembre de 2026

Ambiente de prueba
- Windows 11, Flutter 3.47.7, Dart 3.13.5 y Visual Studio Build Tools.
- Chrome 157 con servidor local y encabezados COOP/COEP.

Pruebas manuales
- P1 tres tareas y reinicio
  windows_00_p1_antes.png y windows_00_p1_despues.png
  web_00_p1_antes.png y web_00_p1_despues.png
  En web el reinicio fue cerrando y abriendo el navegador con el mismo perfil.
- P2 marcar completada
  windows_02_completada.png y web_02_completada.png
- P3 editar titulo
  windows_03_editada.png y web_03_editada.png
- P4 eliminar tarea
  windows_04_eliminada.png y web_04_eliminada.png
- P5 titulo vacio
  windows_05_validacion.png y web_05_validacion.png
- P6 recargar y cerrar/abrir en web
  web_06_reinicio_navegador.png
- Reinicio completo de la app nativa
  windows_06_reinicio_app.png

Pruebas automatizadas
- pruebas_automatizadas.txt: 10 pruebas aprobadas.
- analisis_estatico.txt: flutter analyze sin problemas.

Base de datos
- consulta_sqlite.txt: esquema y datos del archivo SQLite de Windows.
- En web Drift crea la carpeta drift_db/gestor_tareas en OPFS.
- comparativa_web_windows.png: captura comparativa de web y Windows.

Comandos usados
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter build web
flutter run -d chrome --web-header=Cross-Origin-Opener-Policy=same-origin --web-header=Cross-Origin-Embedder-Policy=require-corp
