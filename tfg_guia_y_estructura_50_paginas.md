# Guía Estructural y Contenido para Memoria de TFG (50 Páginas)
Esta guía detalla la estructura y el contenido página por página para redactar una memoria académica completa de aproximadamente 50 páginas para el Trabajo de Fin de Grado (TFG) de la aplicación **Streaks**.

---

## ÍNDICE DE PÁGINAS ESTIMADAS (ESTRUCTURA DE 50 PÁGINAS)
* **Páginas 1-2**: Portada, Agradecimientos y Resumen (Abstract).
* **Página 3**: Índice General, Índice de Figuras e Índice de Tablas.
* **Páginas 4-8**: **Capítulo 1: Introducción y Objetivos** (Motivación, objetivos generales y específicos, alcance del proyecto).
* **Páginas 9-15**: **Capítulo 2: Estado del Arte y Marco Tecnológico** (Comparativas de Frameworks: Flutter vs React Native vs Nativo; Gestión de estados: Riverpod vs BLoC; Backend: Firebase vs API custom).
* **Páginas 16-23**: **Capítulo 3: Análisis de Requisitos y Modelado** (Casos de uso, requisitos funcionales/no funcionales, modelado de datos Firestore NoSQL, diagramas entidad-relación).
* **Páginas 24-32**: **Capítulo 4: Diseño del Sistema y Arquitectura** (Clean Architecture, desacoplamiento, inversión de dependencias, patrones de diseño aplicados, flujo de datos).
* **Páginas 33-43**: **Capítulo 5: Implementación de Módulos Críticos** (Gesto contextual Drag-to-Like con matemáticas de colisión, buscador adaptativo de seguidores, resiliencia ante fallos del SDK de Firebase Auth).
* **Páginas 44-47**: **Capítulo 6: Plan de Pruebas y Validación** (Pruebas unitarias, pruebas de UI, rendimiento de renders).
* **Páginas 48-50**: **Capítulo 7: Conclusión, Presupuesto y Líneas Futuras** (Lecciones aprendidas, costes de infraestructura y desarrollo, futuras integraciones).

---

## CAPÍTULO 1: INTRODUCCIÓN Y OBJETIVOS (Pág. 4-8)
### Página 4: Contexto y Motivación
* **Qué escribir**: Explica el auge de las redes sociales enfocadas en la productividad y la mejora personal (habit tracking). Habla de cómo la gamificación e interacciones sociales (compartir rachas) aumentan la adherencia a hábitos saludables.
* **Párrafo de plantilla académica**:
  > *"El desarrollo del software móvil contemporáneo ha transitado desde la mera digitalización de procesos hacia la creación de ecosistemas interactivos orientados a la modificación conductual. En este marco de referencia, 'Streaks' nace de la necesidad de fusionar dos áreas clave de la interacción digital: la gamificación del progreso personal y la validación social a través de feeds interactivos de usuario..."*

### Página 5: Planteamiento del Problema
* **Qué escribir**: Detalla el problema que soluciona la app: la falta de motivación continuada y el abandono de los objetivos anuales/diarios. Justifica por qué las apps existentes de hábitos fallan al no incluir un componente social y por qué las redes sociales generalistas fallan al carecer de herramientas de seguimiento de progreso estructurado.

### Página 6: Objetivos del Proyecto (General y Específicos)
* **Objetivo General**: Desarrollar una aplicación móvil multiplataforma que integre el seguimiento de hábitos diarios con un feed social interactivo en tiempo real.
* **Objetivos Específicos (Redactar en formato académico)**:
  1. Diseñar una base de datos NoSQL escalable en tiempo real para albergar relaciones complejas de usuario y publicaciones.
  2. Implementar una arquitectura móvil modular y limpia (Clean Architecture) que garantice el desacoplamiento y facilite la inyección de dependencias.
  3. Crear interfaces de usuario interactivas con gestos de alta fidelidad similares a los estándares comerciales actuales (ej. Instagram drag-to-like).
  4. Proveer un sistema seguro de gestión de perfiles de usuario.

### Páginas 7-8: Alcance y Limitaciones
* **Alcance**: Delimita qué funciones se cubren (autenticación, creación de hábitos, posts con foto, likes, sistema de followers/following).
* **Limitaciones**: Indica qué queda fuera de este proyecto por tiempo (ej. notificaciones push avanzadas, integración con wearables, analíticas de inteligencia artificial).

---

## CAPÍTULO 2: ESTADO DEL ARTE Y MARCO TECNOLÓGICO (Pág. 9-15)
### Páginas 9-10: Comparativa de Tecnologías Multiplataforma (Móvil)
Crea una sección donde analices de forma rigurosa las opciones de desarrollo:
1. **Desarrollo Nativo (Swift / Kotlin)**: Excelente rendimiento pero duplica el coste y el tiempo de desarrollo.
2. **React Native**: Basado en JavaScript/TypeScript. Utiliza un puente (*bridge*) en runtime para comunicarse con componentes nativos, lo que puede degradar el rendimiento en animaciones complejas de UI.
3. **Flutter**: Compila directamente a código máquina nativo. Dibuja la UI usando un motor gráfico propio (Impeller), lo que garantiza 60/120 FPS estables sin importar la fragmentación del sistema operativo.

### Páginas 11-12: Comparativa de Gestores de Estado en Flutter
Analiza académicamente por qué se eligió Riverpod sobre BLoC o Provider estándar:
* **Provider**: Sufre de debilidad en tipados en tiempo de ejecución (errores de tipo `ProviderNotFoundException`). Depende estrictamente del árbol de widgets (`BuildContext`).
* **BLoC (Business Logic Component)**: Extremadamente estructurado y seguro, pero requiere una alta cantidad de código repetitivo (*boilerplate*) para operaciones sencillas.
* **Riverpod**: Creado por el mismo autor de Provider. Elimina la dependencia del `BuildContext`, permitiendo leer estados desde fuera de los widgets. Ofrece control de dependencias seguro y dinámico en tiempo de compilación.

### Páginas 13-15: Arquitectura Serverless vs Servidor Propio
Compara el uso de **BaaS (Backend as a Service) como Firebase** versus construir una API propia (ej. Node.js + PostgreSQL):
* **BaaS (Firebase)**: Permite centrarse en la experiencia de usuario y arquitectura del frontend. Firestore provee sincronización de datos mediante Websockets (*snapshots*), ideal para feeds interactivos.
* **API Propia**: Mayor control del hardware y las consultas SQL, pero requiere mayor esfuerzo de despliegue, seguridad y mantenimiento de infraestructura.

---

## CAPÍTULO 3: ANÁLISIS DE REQUISITOS Y MODELADO (Pág. 16-23)
### Páginas 16-17: Tabla de Requisitos Funcionales (RF) y No Funcionales (RNF)
Crea tablas estructuradas.
* **RF-01 (Gestión de Usuarios)**: El sistema debe permitir el registro, login y actualización de perfil (incluyendo email y fotos).
* **RF-02 (Social Feed)**: Los usuarios deben poder subir fotos de su progreso diario con pie de foto.
* **RF-03 (Interacción por gestos)**: Posibilidad de destacar publicaciones haciendo doble tap o arrastrando el dedo a la barra flotante.
* **RNF-01 (Rendimiento)**: La interfaz debe mantener una tasa de refresco mínima de 60 FPS en animaciones.

### Páginas 18-19: Diagrama y Casos de Uso
Dibuja o documenta los diagramas de casos de uso (Actor: Usuario del Sistema; Casos de Uso: Crear Post, Seguir Usuario, Cambiar Email).

### Páginas 20-23: Modelado de Datos NoSQL (Firestore)
Explica la estructura de colecciones de Firestore, justificando por qué se usa una estructura desnormalizada para optimizar costes de lectura:

```json
// Colección: users (Document: uid)
{
  "uid": "USER_ID_123",
  "username": "juan_carlos",
  "displayName": "Juan Carlos",
  "email": "juan@example.com",
  "photoUrl": "https://storage.googleapis...",
  "profileGradientIndex": 2,
  "followersCount": 42,
  "followingCount": 10
}

// Colección: posts (Document: auto-gen id)
{
  "id": "POST_ID_789",
  "userId": "USER_ID_123",
  "imageUrl": "https://storage.googleapis...",
  "caption": "¡Entrenamiento de hoy completado!",
  "createdAt": "2026-05-19T12:00:00Z",
  "likesCount": 5,
  "likedBy": ["USER_ID_123", "USER_ID_456"]
}

// Colección: follows (Relación N:M)
// Document: "USER_ID_123_USER_ID_456"
{
  "followerId": "USER_ID_123",
  "followingId": "USER_ID_456",
  "createdAt": "2026-05-19T10:00:00Z"
}
```

---

## CAPÍTULO 4: DISEÑO DEL SISTEMA Y ARQUITECTURA (Pág. 24-32)
### Páginas 24-27: Estructura de Capas en Código
Detalla cómo se organiza el árbol de directorios del proyecto y qué función cumple cada subcarpeta:
* `lib/core`: Utilidades del sistema, constantes de color y temas.
* `lib/domain`: Entidades puras (`Post`, `User`, `Follow`) y repositorios abstractos.
* `lib/data`: Implementaciones concretas de llamadas de red y base de datos.
* `lib/presentation`: Widgets de Flutter organizados por pantallas (`screens`) y controladores del estado.

### Páginas 28-30: Flujo de Datos y Reactive Caching
Explica cómo Riverpod maneja el flujo de datos reactivo:
* `StreamProvider` escucha directamente los documentos de Firestore.
* Cuando ocurre una modificación física en la base de datos (ej. un nuevo Like o un nuevo seguidor), Firestore emite un snapshot, Riverpod reconstruye automáticamente el Provider afectado, y la UI se actualiza sin requerir intervención del usuario.

---

## CAPÍTULO 5: IMPLEMENTACIÓN DE MÓDULOS CRÍTICOS (Pág. 33-43)
Este es el capítulo técnico más importante de tu TFG. Debe contener fragmentos de código comentados y explicaciones teóricas profundas de cómo resolviste los problemas de interacción y robustez de datos.

### Páginas 33-37: Algoritmo de Detección de Colisiones del Drag-to-Like
Explica paso a paso el cálculo de coordenadas físicas que se utiliza para determinar si el dedo del usuario está sobre la barra flotante.

#### El Concepto de Colisión en Flutter:
Dado que el gesto de arrastre se gestiona a nivel global a través del detector de la pantalla (`onLongPressMoveUpdate`), las coordenadas del dedo (`Offset globalPosition`) vienen dadas en relación a la esquina superior izquierda de la pantalla física del dispositivo móvil. Sin embargo, el botón flotante se posiciona de forma relativa en el árbol de renderizado de Flutter.
Para resolver este desfase espacial, se utiliza el siguiente algoritmo matemático implementado en la aplicación:

```dart
void updateDragPosition(Offset globalPosition) {
  // 1. Obtener la referencia de renderizado del botón
  final RenderBox? renderBox = _likeButtonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  // 2. Determinar el tamaño físico de la píldora (Width, Height)
  final size = renderBox.size;
  
  // 3. Traducir el punto de coordenadas local del botón (0,0) a coordenadas globales de la pantalla
  final position = renderBox.localToGlobal(Offset.zero);

  // 4. Aplicar tolerancia o margen de colisión (Padding) para mayor ergonomía del usuario
  const padding = 15.0;
  
  // 5. Evaluar si la posición física del dedo cae dentro de los límites ampliados del botón
  final isHovered = globalPosition.dx >= position.dx - padding &&
      globalPosition.dx <= position.dx + size.width + padding &&
      globalPosition.dy >= position.dy - padding &&
      globalPosition.dy <= position.dy + size.height + padding;
```

#### Diagrama de la Caja de Colisión:
```
                      [Y: globalPosition.dy]
                                |
                                v
      position.dx - 15         position.dx + size.width + 15
            |                               |
  ----------+-------------------------------+---------- [position.dy - 15]
            |                               |
            |      +-----------------+      |
            |      |  BOTÓN PILDORA  |      |
            |      +-----------------+      |
            |                               |
  ----------+-------------------------------+---------- [position.dy + size.height + 15]
                                ^
                                |
                      [X: globalPosition.dx]
```

### Páginas 38-40: Sistema de Búsqueda Reactiva en Relaciones dirigidas
Explica el diseño del sistema de búsqueda en la lista de seguidores.
Para evitar latencias y altos costes en Firestore (que factura por lectura de documento), la app hace una petición única del listado de seguidores. Luego, implementa un filtro reactivo en el hilo principal del cliente a través de un `StateProvider` que vigila la barra de búsqueda y recompone dinámicamente la UI sin realizar llamadas a Firebase.

### Páginas 41-43: Bypass y Resiliencia en Registro de Correos Electrónicos
Explica el problema de seguridad de Firebase Auth (Enumeración de emails y verificación forzada en entornos de desarrollo). Detalla el patrón fallback implementado para que, en caso de fallar la sincronización a nivel del servidor de autenticación por usar correos ficticios de prueba, el perfil se actualice en la base de datos de Firestore y el flujo del usuario continúe.

---

## CAPÍTULO 6: PLAN DE PRUEBAS Y VALIDACIÓN (Pág. 44-47)
* **Página 44**: Estrategia de pruebas (Pruebas unitarias para validar las clases del dominio, pruebas de integración de base de datos).
* **Páginas 45-46**: Ejemplo de Prueba de Widget (Unit testing del botón o del validador de emails).
* **Página 47**: Pruebas de rendimiento: cómo se utilizó el DevTools de Flutter para medir la memoria y la tasa de refresco durante la animación de la estrella del drag-to-like.

---

## CAPÍTULO 7: CONCLUSIÓN Y TRABAJO FUTURO (Pág. 48-50)
* **Página 48**: Evaluación del cumplimiento de objetivos. Cómo la aplicación ha fusionado con éxito el hábito social y personal.
* **Página 49**: Costes estimados de puesta en producción (Uso de Firebase Spark vs Blaze, estimación de peticiones mensuales por usuario).
* **Página 50**: Líneas futuras de desarrollo (Notificaciones Push inteligentes al perder una racha, retos semanales comunitarios, soporte offline avanzado con caché SQLite).
