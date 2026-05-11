# IES Ítaca – 2º DAM
## Proyecto de Titulación – Seguimiento del Proyecto
### Primera Entrega

---

## 1. Título del proyecto

**Streaks** – Seguimiento Social de Hábitos

---

## 2. Integrantes

| Nombre y apellidos | Rol |
|--------------------|-----|
| Juan Carlos (jc)   | Desarrollador full-stack / Diseñador UI |

---

## 3. Idea general del proyecto

**Streaks** es una aplicación móvil multiplataforma para el seguimiento de hábitos diarios con un componente social. El usuario crea hábitos personales, registra su cumplimiento diario subiendo una foto como evidencia y acumula rachas (*streaks*) continuas. La red de amigos puede ver las publicaciones de los hábitos completados en un feed social similar a BeReal, fomentando la motivación a través de la responsabilidad social.

**Problema que resuelve:** la falta de constancia en la adquisición de hábitos saludables. Al añadir el componente social y la gamificación por rachas, se aumenta significativamente la adherencia al hábito.

---

## 4. Descripción detallada

### Funcionalidades principales

- **Gestión de hábitos:** el usuario puede crear, editar y eliminar hábitos personalizados con nombre, icono, color, frecuencia semanal, hora de recordatorio y visibilidad (público/privado).
- **Registro diario con foto:** para completar un hábito en un día concreto, el usuario sube una fotografía desde la galería junto a un texto descriptivo, generando una publicación (*post*) asociada al hábito.
- **Sistema de rachas (streaks):** el sistema calcula automáticamente la racha actual y la racha máxima de cada hábito, así como una racha global del usuario.
- **Feed social:** pantalla principal estilo red social con dos pestañas: "Para ti" (publicaciones globales) y "Siguiendo" (publicaciones de usuarios seguidos). Las publicaciones muestran la foto, el caption, el hábito al que pertenecen y la racha en ese momento.
- **Calendario de hábitos:** vista de calendario mensual con selector de día horizontal que muestra qué hábitos hay que completar cada día y su estado.
- **Estadísticas:** pantalla de estadísticas personal con racha global, número de publicaciones, heatmap de actividad y progreso por hábito.
- **Perfil de usuario:** perfil personalizable con foto, bio, gradiente de fondo, y cuadrícula de posts. Permite ver el perfil de otros usuarios y seguirlos.
- **Autenticación:** registro e inicio de sesión con email y contraseña mediante Firebase Auth.

### Público objetivo

Jóvenes de 16-35 años interesados en mejorar su productividad, bienestar o rutinas deportivas, que ya utilizan redes sociales y se benefician de la gamificación y la presión social positiva para mantener la constancia.

### Qué lo hace interesante o útil

La combinación de seguimiento de hábitos con red social es el elemento diferenciador: no es solo un tracker privado ni solo una red social, sino que fusiona ambos conceptos. La evidencia fotográfica fuerza una rendición de cuentas real. El diseño visual oscuro con glassmorphism y gradientes ofrece una experiencia premium desde el primer momento.

---

## 5. Tecnologías previstas

### Lenguajes
- **Dart** (lenguaje principal de Flutter)

### Frameworks / librerías

| Librería | Versión | Uso |
|---|---|---|
| **Flutter** | ≥ 3.2 | Framework UI multiplataforma |
| **flutter_riverpod** | ^2.5.1 | Gestión de estado reactivo |
| **go_router** | ^13.2.0 | Navegación declarativa con guards de autenticación |
| **dartz** | ^0.10.1 | Programación funcional (Either / Failure) |
| **equatable** | ^2.0.5 | Comparación de objetos en entidades de dominio |
| **fl_chart** | ^0.66.2 | Gráficas de estadísticas y heatmap de actividad |
| **table_calendar** | ^3.1.0 | Calendario mensual interactivo |
| **image_picker** | ^1.0.7 | Selección de imágenes desde la galería |
| **cached_network_image** | ^3.3.1 | Caché de imágenes remotas |
| **uuid** | ^4.3.3 | Generación de IDs únicos para posts |
| **timeago** | ^3.6.1 | Fechas relativas localizadas en español |
| **intl** | ^0.19.0 | Internacionalización y formateo de fechas |

### Base de datos / Backend

| Servicio | Uso |
|---|---|
| **Firebase Auth** | Autenticación de usuarios (email/contraseña) |
| **Cloud Firestore** | Base de datos NoSQL en tiempo real (usuarios, hábitos, posts, seguidores) |
| **Firebase Storage** | Almacenamiento de fotografías de los posts |

### Otras herramientas

| Herramienta | Uso |
|---|---|
| **GitHub** | Control de versiones y colaboración |
| **Figma** | Diseño UI/UX y prototipado |
| **Android Studio / VS Code** | IDEs de desarrollo |
| **Firebase Console** | Gestión del backend y reglas de seguridad |

### Justificación de las tecnologías elegidas

**Flutter** se ha elegido porque permite desarrollar una aplicación nativa de alta calidad para iOS y Android desde una única base de código en Dart, reduciendo el tiempo de desarrollo a la mitad respecto a desarrollar dos apps nativas. **Firebase** es la plataforma de backend más integrada con Flutter y ofrece autenticación, base de datos en tiempo real y almacenamiento sin necesidad de administrar servidores. **Riverpod** es el gestor de estado más robusto y testeable del ecosistema Flutter, con soporte nativo para streams de Firestore. La arquitectura limpia (*Clean Architecture*) con **dartz** garantiza código desacoplado, mantenible y testeable.

---

## 6. Plataformas de desarrollo

**Aplicación móvil multiplataforma (iOS y Android)**

Desarrollada con Flutter, la aplicación genera binarios nativos para ambas plataformas desde una única base de código. Se ha seguido un diseño *mobile-first* con interfaz adaptada a pantallas de teléfono.

- **Android:** compilación con Gradle / Kotlin, compatible desde Android 5.0+
- **iOS:** compilación con Xcode / Swift bridging, compatible desde iOS 12+
- La arquitectura interna sigue **Clean Architecture** (3 capas: `domain`, `data`, `presentation`), con navegación declarativa mediante GoRouter y gestión de estado reactiva con Riverpod.

---

## 7. Recursos o necesidades especiales

- **Firebase (suite completa):** se necesita un proyecto activo en Firebase Console con Auth, Firestore y Storage habilitados y configurados con reglas de seguridad personalizadas (ya implementadas en `firestore.rules` y `storage.rules`).
- **Cámara / Galería del dispositivo:** la app solicita permisos para acceder a la galería de imágenes del usuario para subir fotos como evidencia de los hábitos completados.
- **Conexión a internet:** la aplicación requiere conectividad para sincronizar datos en tiempo real con Firestore y cargar imágenes desde Firebase Storage.
- **Cuenta de Google (opcional, futuro):** se prevé añadir inicio de sesión con Google en fases posteriores.
- No se requiere hardware especial ni APIs de terceros de pago.

---

## 8. Plan inicial o fases del proyecto

| Fase | Descripción | Período estimado |
|---|---|---|
| **Fase 0 – Diseño** | Definición de requisitos, wireframes en Figma, diseño del modelo de datos en Firestore y arquitectura del proyecto. | Semanas 1-2 |
| **Fase 1 – Core / MVP** | Autenticación, CRUD de hábitos, registro diario de hábitos (sin foto), sistema de rachas básico, navegación entre pantallas. | Semanas 3-5 |
| **Fase 2 – Social** | Creación de posts con foto (Firebase Storage), feed social (Siguiendo / Para ti), sistema de seguidores, perfiles de usuario. | Semanas 6-8 |
| **Fase 3 – Estadísticas y pulido** | Pantalla de estadísticas con heatmap y gráficas, calendario de actividad, notificaciones de recordatorio, refinamiento UI. | Semanas 9-11 |
| **Fase 4 – Pruebas y documentación** | Tests unitarios y de widget, corrección de bugs, documentación técnica completa (memoria, manual de usuario), preparación de la presentación final. | Semanas 12-13 |

### Hitos principales

- **Entrega 1 (23/03/2026):** este documento de seguimiento.
- **Entrega 2:** MVP funcional con autenticación y CRUD de hábitos.
- **Entrega 3:** versión beta con feed social y posts con foto.
- **Entrega final:** aplicación completa + documentación + presentación.

---

## 9. Comentarios o dudas

- Se plantea si el proyecto necesita pasar por el proceso de publicación en App Store / Google Play o si es suficiente con una APK instalable para la evaluación.
- ¿Se valorará positivamente la implementación de notificaciones push (Firebase Cloud Messaging) aunque añadan complejidad?
- Se consultará al tutor sobre los requisitos exactos de la memoria técnica final (extensión, apartados obligatorios, formato).

---

## 10. Observaciones del profesor/a

*(Espacio reservado para la revisión y comentarios del profesorado.)*

---

*Documento generado el 23 de marzo de 2026 – IES Ítaca, 2º DAM*
