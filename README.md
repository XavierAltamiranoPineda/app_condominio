# CondoAdmin — App Móvil de Gestión de Condominios

> Flutter + Dart · Arquitectura MVC · Material 3

Sistema integral de administración de condominios migrado desde el sistema desktop Python/PyQt6 hacia una aplicación móvil (Android / iOS).

---

## 🚀 Requisitos del sistema

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.22+ (stable) |
| Dart SDK | 3.5+ |
| Android SDK | API 24 (Android 7.0+) |
| JDK | 17+ |
| Xcode (iOS) | 15+ (opcional) |

---

## 📦 Instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-org/app_condominio.git
cd app_condominio

# 2. Copiar variables de entorno
cp .env.example .env
# Editar .env con tus valores

# 3. Instalar dependencias
flutter pub get

# 4. Verificar configuración
flutter doctor
```

---

## ⚙️ Variables de entorno

Copia `.env.example` → `.env` y configura:

```env
APP_ENV=development
API_BASE_URL=http://10.0.2.2:8000/api/v1   # Emulador Android
# API_BASE_URL=http://192.168.1.x:8000/api/v1  # Dispositivo físico
API_TIMEOUT=30000

JWT_SECRET_KEY=tu_clave_secreta
TOKEN_REFRESH_THRESHOLD=300

FCM_SERVER_KEY=tu_fcm_key
GOOGLE_MAPS_KEY=tu_maps_key
```

> **Nota**: Para dispositivo físico, reemplaza `10.0.2.2` con la IP de tu máquina en la red local.

---

## ▶️ Ejecución por ambiente

```bash
# Desarrollo (hot reload activo)
flutter run

# Con flavor específico
flutter run --dart-define=ENV=development
flutter run --dart-define=ENV=staging
flutter run --dart-define=ENV=production

# Dispositivo específico
flutter devices                  # listar dispositivos
flutter run -d <device_id>

# Web (demo)
flutter run -d chrome
```

---

## 🏗️ Build para distribución

```bash
# ─── Android ───────────────────────────────────────────────────

# APK debug
flutter build apk --debug

# APK release (firmado)
flutter build apk --release

# AAB (para Google Play)
flutter build appbundle --release

# Split por ABI (menor tamaño)
flutter build apk --split-per-abi --release

# ─── iOS ───────────────────────────────────────────────────────

# Build iOS (requiere Mac + Xcode)
flutter build ios --release
```

---

## 🗂️ Estructura del proyecto

```
lib/
├── main.dart                    # Entrada principal
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart   # Endpoints REST centralizados
│   │   └── storage_keys.dart    # Claves de almacenamiento
│   ├── models/
│   │   ├── usuario.dart         # Entidad usuario global
│   │   └── auth_response.dart
│   ├── network/
│   │   ├── dio_client.dart      # Cliente HTTP singleton
│   │   ├── api_exception.dart   # Excepciones tipadas
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart     # JWT + refresh
│   │       ├── error_interceptor.dart    # Mapeo de errores
│   │       └── logging_interceptor.dart
│   ├── router/
│   │   └── app_router.dart      # Rutas go_router + guard
│   └── theme/
│       └── app_theme.dart       # Material 3 Design System
│
├── features/                    # Feature-first organización
│   ├── auth/
│   │   ├── controllers/auth_controller.dart
│   │   ├── models/
│   │   ├── repositories/auth_repository.dart
│   │   └── views/
│   │       ├── splash_view.dart
│   │       ├── login_view.dart
│   │       └── forgot_password_view.dart
│   ├── home/
│   │   ├── views/
│   │   │   ├── home_admin_view.dart
│   │   │   ├── home_residente_view.dart
│   │   │   └── home_guardia_view.dart
│   │   └── widgets/
│   ├── residentes/
│   │   ├── controllers/residente_controller.dart
│   │   ├── models/residente.dart
│   │   └── views/
│   ├── unidades/
│   ├── cuotas/
│   ├── incidencias/
│   ├── avisos/
│   ├── reservas/
│   ├── visitas/
│   └── perfil/
│
└── shared/
    └── widgets/                 # Componentes reutilizables
        ├── app_text_field.dart
        ├── app_button.dart
        └── loading_overlay.dart
```

---

## 🏛️ Arquitectura MVC

```
┌─────────────────────────────────────────────────┐
│                    VIEW (UI)                     │
│         StatelessWidget / StatefulWidget         │
│    Observa Controller vía context.watch()        │
└─────────────┬──────────────────────────┬────────┘
              │ llama métodos            │ Provider
              ▼                          ▼ notifyListeners
┌─────────────────────────────────────────────────┐
│               CONTROLLER (Lógica)                │
│            ChangeNotifier + Provider             │
│    Coordina Model, valida reglas de negocio      │
└─────────────┬──────────────────────────┬────────┘
              │                          │
              ▼                          ▼
┌────────────────────┐      ┌────────────────────────┐
│  MODEL (Entidades) │      │   REPOSITORY (Datos)   │
│  Clases Dart puras │      │   Dio + API REST        │
│  fromJson/toJson   │      │   + Hive (cache local)  │
└────────────────────┘      └────────────────────────┘
```

---

## 👤 Roles y permisos

| Rol | Acceso |
|---|---|
| **Admin** | Todo: CRUD residentes, unidades, cuotas, incidencias, avisos, reservas, visitas |
| **Residente** | Ver su unidad, estado de cuenta, incidencias propias, avisos, solicitar reservas |
| **Guardia** | Registrar/ver visitas, reportar incidencias, ver directorio y avisos |

---

## 🧪 Pruebas

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Todos los tests con coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📋 Checklist de funcionalidades

### ✅ Implementado (MVP)
- [x] Splash screen con animaciones
- [x] Login con validación
- [x] Recuperar contraseña
- [x] Guard de rutas por autenticación
- [x] Redirección por rol (Admin / Residente / Guardia)
- [x] Dashboard Admin con estadísticas
- [x] CRUD Residentes (lista, detalle, crear, editar)
- [x] CRUD Unidades (grid, crear, editar)
- [x] Módulo Cuotas / Pagos
- [x] Estado de cuenta por residente
- [x] Reporte de morosidad
- [x] CRUD Incidencias con workflow de estados
- [x] CRUD Avisos/Comunicados
- [x] Módulo Reservas con aprobación/rechazo
- [x] Módulo Visitas (ingreso/salida)
- [x] Perfil de usuario
- [x] Configuración (notificaciones, apariencia)
- [x] Interceptor JWT + refresh automático
- [x] Manejo centralizado de errores
- [x] Design System Material 3
- [x] Soporte Light/Dark mode

### 🔄 En desarrollo (Fase 2)
- [ ] Cache offline con Hive
- [ ] Notificaciones push (Firebase)
- [ ] Scanner QR para visitas
- [ ] Generación de PDF (reportes)
- [ ] Exportar estado de cuenta
- [ ] Biometría en login
- [ ] Internacionalización completa (i18n)
- [ ] Widget tests completos
- [ ] CI/CD con GitHub Actions

### 📌 Backlog (Fase 3)
- [ ] Chat interno (incidencias)
- [ ] Mapa de áreas comunes
- [ ] Pagos en línea (Stripe/PayPal)
- [ ] Geolocalización visitas
- [ ] Acceso por huella/rostro al condominio

---

## 🔒 Supuestos del backend

El sistema original es una app desktop Python/PyQt6 con SQLite. Para la app móvil se asume:

1. **API REST** implementada en FastAPI o Django REST Framework
2. **Autenticación** JWT Bearer con refresh token
3. **Base URL** configurable vía `.env`
4. **Endpoints** definidos en `lib/core/constants/api_endpoints.dart`
5. El backend expone `/auth/login` con `{ email, password }` retornando `{ access_token, refresh_token, usuario }`

