# ⚡ Streaks – Gamified Habit Tracker & Social Productivity App

**Streaks** es una aplicación móvil multiplataforma desarrollada en **Flutter** orientada al seguimiento de hábitos y la mejora de la productividad personal. Combina mecánicas de **gamificación** con una **red social** integrada para fomentar el compromiso, la constancia y la motivación entre usuarios.

Este proyecto ha sido diseñado y desarrollado como el **Proyecto Fin de Grado (TFG)** para el Grado Superior en **Desarrollo de Aplicaciones Multiplataforma (DAM)**.

---

## 🌟 Características Principales

- 🔄 **Seguimiento de Hábitos y Rachas:** Creación, registro diario y analítica visual del cumplimiento de hábitos (*streaks*).
- 🎮 **Gamificación:** Sistema de recompensas y progresión para incentivar el cumplimiento de objetivos.
- 👥 **Red Social e Interacción:** Feed comunitario donde compartir avances, celebrar rachas y motivar a otros usuarios.
- 🔔 **Notificaciones y Recordatorios:** Configuración de alertas para no perder el hábito diario.
- 🌐 **Soporte Multiplataforma:** Arquitectura adaptada para ejecución en dispositivos iOS y Android.

---

## 🛠️ Stack Tecnológico

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Gestión de Estado:** [Riverpod](https://riverpod.dev/)
- **Backend & Cloud:** [Firebase](https://firebase.google.com/) (Authentication, Cloud Firestore)
- **Patrón de Arquitectura:** Clean Architecture
- **Control de Versiones:** Git / GitHub (siguiendo la convención de *Conventional Commits*)

---

## 📐 Estructura del Proyecto (Clean Architecture)

El código fuente principal dentro del directorio `lib/` está organizado de manera modular mediante **Clean Architecture** para garantizar la mantenibilidad, escalabilidad y separación de responsabilidades:

```text
lib/
├── core/                  # Recursos globales, utilidades, temas de la app y componentes transversales
├── data/                  # Fuentes de datos remotas (Firebase), repositorios y modelos
├── domain/                # Entidades de negocio, validaciones y lógica de dominio desacoplada
├── presentation/          # Vistas (UI), widgets reusables y gestión de estado (Riverpod)
├── firebase_options.dart  # Configuración e integración con servicios de Firebase
└── main.dart              # Punto de entrada principal de la aplicación

Instalación y Ejecución Local
Requisitos previos
Flutter SDK

Dart SDK

Dispositivo físico o emulador (Android / iOS)

Pasos para clonar y ejecutar
Clonar el repositorio:

Bash
git clone [https://github.com/Juan-Carlos-dev/streaks.git](https://github.com/Juan-Carlos-dev/streaks.git)
cd streaks
Obtener las dependencias de Flutter:

Bash
flutter pub get
Ejecutar la aplicación:

Bash
flutter run
👤 Autor
Juan Carlos Pérez Simarro – Desarrollador Full Stack / Mobile

GitHub: @Juan-Carlos-dev

Email: jcpsdev@gmail.com
