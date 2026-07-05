import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/residentes/controllers/residente_controller.dart';
import 'features/unidades/controllers/unidad_controller.dart';
import 'features/cuotas/controllers/cuota_controller.dart';
import 'features/incidencias/controllers/incidencia_controller.dart';
import 'features/avisos/controllers/aviso_controller.dart';
import 'features/notificaciones/controllers/notificacion_controller.dart';
import 'features/reservas/controllers/reserva_controller.dart';
import 'features/visitas/controllers/visita_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // BORRAR TODO EL CACHÉ Y CUENTAS PARA PRUEBAS LIMPIAS
  await const FlutterSecureStorage().deleteAll();

  // Inicializar locale español para DateFormat / NumberFormat
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('es_MX', null);

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicializar Hive (cache local)
  await Hive.initFlutter();

  // Orientación preferida
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CondoAdminApp());
}

class CondoAdminApp extends StatelessWidget {
  const CondoAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ResidenteController()),
        ChangeNotifierProvider(create: (_) => UnidadController()),
        ChangeNotifierProvider(create: (_) => CuotaController()),
        ChangeNotifierProvider(create: (_) => IncidenciaController()),
        ChangeNotifierProvider(create: (_) => AvisoController()),
        ChangeNotifierProvider(create: (_) => NotificacionController()),
        ChangeNotifierProvider(create: (_) => ReservaController()),
        ChangeNotifierProvider(create: (_) => VisitaController()),
      ],
      child: Builder(
        builder: (context) {
          final authController = context.watch<AuthController>();
          final router = AppRouter.createRouter(authController);

          return MaterialApp.router(
            title: 'CondoAdmin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router,
            locale: const Locale('es', 'ES'),
          );
        },
      ),
    );
  }
}
