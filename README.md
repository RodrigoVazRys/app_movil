# 🎵 KAZE Studio

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Clean_Architecture-Feature_First-success?style=for-the-badge)
![Provider](https://img.shields.io/badge/State_Management-Provider-blue?style=for-the-badge)

**KAZE Studio** es una plataforma móvil de gestión de contenidos diseñada específicamente para la administración de portafolios, tecnologías y activos musicales. Construida con **Flutter**, esta aplicación se comunica con un backend personalizado para mantener todo el ecosistema digital de KAZE actualizado.


## ✨ Características Principales

La aplicación está modularizada en características (*Features*) independientes:

* 🔐 **Autenticación Segura (`auth`)**: Flujos completos de inicio de sesión y registro.
* 🎧 **Gestor Musical (`music_manager`)**: Administración de pistas de audio y reproducción nativa fluida.
* 💼 **Portafolio de Proyectos (`projects`)**: Control y visualización de trabajos, integraciones y desarrollos destacados.
* 🛠️ **Tech Stack (`tech_stack`)**: Panel para actualizar y mostrar las herramientas y lenguajes dominados.
* 🎨 **UI/UX Consistente**: Sistema de diseño basado en Material 3, tipografía dinámica (Google Fonts) y un tema oscuro elegante (`KazeTheme`).

## 🏗️ Arquitectura y Patrones

Este proyecto destaca por implementar **Clean Architecture** con una estricta organización **Feature-First**. Esto garantiza que el código sea escalable, testeable y fácil de mantener.

Cada característica en `lib/features/` se divide en:
1.  **Domain (Dominio)**: La lógica de negocio pura (`Entities` y abstracciones de `Repositories`).
2.  **Data (Datos)**: Modelos, fuentes de datos remotas (`Datasources` usando `http`) e implementaciones de repositorios.
3.  **Presentation (Presentación)**: Gestión de estado reactiva con `ViewModels` (usando `ChangeNotifier` de `provider`) y vistas UI (Widgets).

## 🛠️ Stack Tecnológico

* **Framework:** [Flutter](https://flutter.dev/)
* **Lenguaje:** Dart
* **Gestor de Estado:** [`provider`](https://pub.dev/packages/provider)
* **Peticiones HTTP:** [`http`](https://pub.dev/packages/http) con fábricas personalizadas para compatibilidad I/O y Web.
* **Reproducción de Audio:** [`just_audio`](https://pub.dev/packages/just_audio)
* **Diseño:** `google_fonts`, `cupertino_icons`

## 📂 Estructura del Proyecto

Una vista rápida de la organización del código central (`lib/`):

```text
lib/
├── app.dart                    # Configuración de MaterialApp y Providers raíz
├── core/                       # Núcleo de la app (Network, Theme, Constants, Errors)
├── features/                   # Módulos de la aplicación
│   ├── auth/                   # -> Login, Register, User Session
│   ├── music_manager/          # -> Gestión y reproducción de pistas
│   ├── projects/               # -> Administración del portafolio
│   └── tech_stack/             # -> Gestión de habilidades técnicas
├── shared/                     # Componentes visuales y utilidades reutilizables
└── main.dart                   # Punto de entrada

```

## 🚀 Instalación y Uso

Para correr este proyecto en tu entorno local, asegúrate de tener el [SDK de Flutter instalado](https://docs.flutter.dev/get-started/install).

1. **Clona este repositorio:**
```bash
git clone [https://github.com/rodrigovazrys/app_movil.git](https://github.com/rodrigovazrys/app_movil.git)

```


2. **Ve al directorio del proyecto:**
```bash
cd app_movil

```


3. **Instala las dependencias:**
```bash
flutter pub get

```


4. **Ejecuta la aplicación:**
```bash
flutter run
```

## 👨‍💻 Autor

Desarrollado y mantenido por **Rodrigo Vázquez Reyes** para el ecosistema KAZE.
