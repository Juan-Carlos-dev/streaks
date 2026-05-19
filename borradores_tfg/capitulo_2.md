# CAPÍTULO 2: ESTADO DEL ARTE Y MARCO TECNOLÓGICO

---

## 2.1 Ecosistemas Móviles: Nativo vs. Multiplataforma
A la hora de abordar el desarrollo de una aplicación móvil moderna, una de las decisiones estratégicas más críticas reside en la selección del paradigma de desarrollo. Históricamente, el desarrollo **nativo** ha sido considerado el estándar de oro en cuanto a rendimiento y acceso al hardware. Sin embargo, el surgimiento y la maduración de los frameworks **multiplataforma** ha redefinido el panorama tecnológico, ofreciendo alternativas altamente competitivas que reducen drásticamente los costes y los tiempos de salida al mercado (*time-to-market*).

A continuación, se realiza un análisis comparativo de las tres grandes vertientes actuales: desarrollo nativo independiente, desarrollo híbrido interpretado (React Native) y desarrollo multiplataforma compilado (Flutter).

### Tabla 2.1: Comparativa de Paradigmas de Desarrollo Móvil

| Criterio | Desarrollo Nativo (Swift / Kotlin) | React Native (Bridge / JS) | Flutter (Compilación Nativa / Engine) |
| :--- | :--- | :--- | :--- |
| **Lenguaje de Programación** | Swift (iOS) / Kotlin (Android) | JavaScript / TypeScript | Dart |
| **Rendimiento General** | Excelente (Nativo Directo) | Bueno (Fricción en el *Bridge*) | Excelente (Compilación AOT) |
| **Arquitectura de Interfaz** | OEM Widgets del Sistema | Mapeo a OEM Widgets | Renderizado Propio (Canvas 2D) |
| **Tasa de Refresco (FPS)** | 60 - 120 FPS | Variable (Posibles caídas) | 60 - 120 FPS Estables |
| **Coste de Mantenimiento** | Alto (Dos bases de código) | Medio (Una base + puentes nativos) | Bajo (Una única base de código) |
| **Hot Reload** | Limitado (Xcode/Android Studio) | Rápido (Metro Bundler) | Extremadamente rápido (Dart JIT) |

### 1. Desarrollo Nativo
El desarrollo nativo exige la implementación y el mantenimiento de dos proyectos independientes: uno para iOS utilizando Swift/Objective-C y la API de Cocoa Touch, y otro para Android haciendo uso de Kotlin/Java y el SDK de Android. Este enfoque garantiza el máximo rendimiento posible del dispositivo y soporte inmediato para cualquier actualización de la API del sistema operativo. No obstante, plantea graves desventajas de negocio: el coste financiero se duplica debido a la necesidad de contar con equipos de desarrollo diferenciados, y la sincronización de funcionalidades entre plataformas suele presentar desfases y desajustes.

### 2. React Native (Paradigma Interpretado)
Propuesto por Meta, React Native unifica el desarrollo móvil usando JavaScript/TypeScript. En lugar de compilar el código a binario de máquina para la interfaz, React Native ejecuta un hilo de JavaScript y se comunica con los widgets nativos del sistema a través de un puente de comunicación (*bridge*). Si bien esta arquitectura permite reutilizar componentes de React web, el *bridge* introduce un cuello de botella asíncrono. Cuando la UI requiere transiciones complejas o procesamiento intensivo de gestos en tiempo real, la serialización de datos a través de este puente puede provocar una degradación perceptible en la fluidez de la app (caídas de FPS).

### 3. Flutter (Paradigma de Renderizado Directo)
Flutter, el framework de Google, propone un enfoque innovador. En lugar de comunicarse con los widgets nativos del sistema o depender de un puente interpretado, Flutter **dibuja cada píxel directamente en la pantalla** del dispositivo a través de su propio motor de renderizado (Impeller o Skia), utilizando aceleración gráfica por hardware (Metal en iOS y Vulkan/OpenGL en Android). Esto otorga a Flutter un rendimiento gráfico equiparable al nativo y una consistencia visual absoluta: la aplicación se verá exactamente igual en cualquier versión de Android o iOS, aislando al desarrollador de las diferencias de diseño del fabricante (*fragmentación*).

---

## 2.2 Estudio del Ecosistema de Flutter y Dart
La elección de Flutter como framework principal para el desarrollo de **Streaks** responde a su arquitectura interna y al lenguaje de programación sobre el que se apoya: **Dart**.

```
+-------------------------------------------------------------+
|                     CAPA DE APLICACIÓN                      |
|           Widgets del Desarrollador (Código Dart)           |
+-------------------------------------------------------------+
|                     FLUTTER FRAMEWORK                       |
|  Gestos - Animaciones - Pintado - Layout - Material/Cupertino|
+-------------------------------------------------------------+
|                       FLUTTER ENGINE                        |
|   Motor Gráfico (Impeller/Skia) - Dart VM - Text Rendering   |
+-------------------------------------------------------------+
|                      PLATAFORMA FÍSICA                      |
|                GPU (Metal / Vulkan) - Canvas                |
+-------------------------------------------------------------+
```

### El Motor Gráfico (Rendering Pipeline)
La principal ventaja competitiva de Flutter es que no actúa como un mero envoltorio de APIs nativas. El framework incluye su propio motor gráfico escrito en C++. La canalización de renderizado (*rendering pipeline*) funciona de la siguiente manera:
1.  **Layout**: Se calcula el tamaño y posición geométrica de cada elemento del árbol de widgets.
2.  **Painting**: Se registran las operaciones de dibujo en capas virtuales.
3.  **Compositing**: Se combinan las capas y se envían las instrucciones de dibujado a la GPU.
4.  **Rasterization**: El motor gráfico traduce estas operaciones en píxeles físicos sobre la pantalla a través de Metal o Vulkan.

Esta independencia respecto a los componentes visuales del sistema operativo garantiza que las animaciones de Streaks (como el estallido de la estrella en el like gestual) mantengan una suavidad y latencia mínimas.

### Las Dos Compilaciones de Dart
Dart es un lenguaje multiparadigma optimizado para el diseño de interfaces de usuario. Su éxito radica en su flexibilidad de compilación:
*   **Compilación Just-In-Time (JIT)**: Utilizada exclusivamente durante la fase de desarrollo. Permite la ejecución de código dinámico en una máquina virtual de Dart. Esto habilita la funcionalidad de **Hot Reload** (Recarga Rápida), la cual inyecta los cambios realizados en el código fuente directamente en la app en menos de un segundo sin perder el estado actual de la pantalla.
*   **Compilación Ahead-Of-Time (AOT)**: Utilizada para compilar la versión definitiva de producción. Traduce el código Dart directamente a binario nativo de arquitectura ARM o x86/x64. Esto elimina el tiempo de arranque de máquinas virtuales y optimiza el uso de CPU y batería del terminal.

---

## 2.3 Paradigmas de Gestión de Estado: Riverpod, Provider y BLoC
El estado en una aplicación móvil define en todo momento qué información se presenta al usuario en pantalla (cargando, éxito, error, datos del usuario, feeds, etc.). En aplicaciones reactivas de tiempo real como Streaks, el control de la consistencia del estado es sumamente complejo debido a la naturaleza asíncrona de las interacciones.

A continuación, se analiza la justificación técnica de la selección de **Riverpod** frente a sus alternativas en Flutter:

### 1. Provider (El Modelo Heredado)
Provider fue durante años el gestor recomendado por Google. Funciona envolviendo el árbol de widgets y exponiendo datos mediante `InheritedWidget`. Su limitación radica en que depende estrictamente de que los proveedores existan dentro de la estructura visual del widget. Intentar leer un proveedor fuera del árbol o antes de su inicialización provoca excepciones en tiempo de ejecución. Además, no es seguro contra errores de tipo de datos similares en runtime.

### 2. BLoC (Business Logic Component)
BLoC es un patrón arquitectónico rígido basado en programación reactiva orientada a eventos. Separa la lógica mediante flujos de entrada (*events*) y flujos de salida (*states*). Ofrece un control absoluto y es excelente para grandes corporaciones informáticas con equipos masivos. No obstante, introduce una enorme complejidad de desarrollo (*boilerplate code*): añadir una simple consulta requiere escribir múltiples clases de evento, estado y bloc. Para un proyecto individual, esto ralentiza la velocidad de desarrollo.

### 3. Riverpod (La Solución Elegida)
Riverpod rediseña por completo el concepto de Provider para solventar todas sus flaquezas:
*   **Seguridad de Compilación**: Los proveedores se declaran como variables globales estáticas. Al estar fuera del árbol de widgets, el compilador de Dart puede verificar los tipos de datos en tiempo de desarrollo, eliminando las excepciones de proveedores no encontrados en runtime.
*   **Desacoplamiento Absoluto**: Permite acceder al estado de la aplicación desde componentes no visuales (como repositorios de datos o controladores de red), facilitando la separación de capas de Clean Architecture.
*   **Soporte de Caché Reactiva**: Incluye modificadores como `autoDispose` que liberan la memoria consumida por los datos en pantalla inmediatamente cuando el usuario sale de ella, y permite refrescar datos asíncronos de forma limpia mediante `AsyncValue`.

### Diagrama del Flujo de Datos con Riverpod en Streaks:

```mermaid
graph LR
    subgraph UI (Presentation)
        Widget[ConsumerWidget]
    end

    subgraph State Management (Riverpod)
        Notifier[NotifierProvider / AsyncNotifier]
        State[State / AsyncValue]
    end

    subgraph Business Logic & Data
        Repository[PostRepository Implementation]
        Source[Cloud Firestore Stream]
    end

    Widget -->|1. Invoca Acción / Lee| Notifier
    Notifier -->|2. Modifica Estado| State
    State -->|3. Escucha / Reconstruye| Widget
    Notifier -->|4. Llama método| Repository
    Repository -->|5. Escucha Updates| Source
    Source -->|6. Emite Evento| Repository
    Repository -->|7. Empuja Nuevos Datos| Notifier
```

---

## 2.4 Análisis del Backend: Arquitecturas Servidor Propias vs. BaaS (Firebase)
Para el almacenamiento de datos en la nube, la autenticación y el alojamiento de contenido multimedia, se evaluaron dos alternativas principales:

### Alternativa A: API REST propia con Node.js, Express y PostgreSQL
Este enfoque proporciona control absoluto sobre el servidor, los índices de base de datos SQL y las operaciones a nivel de base de datos física. No obstante, para un proyecto ágil, requiere un esfuerzo masivo de desarrollo en infraestructura: configurar balanceadores de carga, implementar la lógica de sockets para actualizaciones en tiempo real, programar la pasarela de autenticación con JSON Web Tokens (JWT), y asegurar el almacenamiento de imágenes mediante CDNs propias.

### Alternativa B: Backend as a Service (BaaS) con Firebase (Elegida)
Firebase delega la gestión de infraestructura en Google Cloud, permitiendo al desarrollador focalizarse plenamente en el valor funcional de la app. Los servicios integrados en Streaks son:
1.  **Cloud Firestore**: Base de datos NoSQL documental de baja latencia. Su capacidad nativa para emitir *streams* de datos a través de WebSockets permite que el feed de Streaks se actualice automáticamente en el dispositivo cuando otro usuario publica una foto de progreso, sin necesidad de realizar peticiones HTTP de refresco manual.
2.  **Firebase Storage**: Almacenamiento optimizado de objetos binarios (imágenes de posts y avatares), integrado de forma nativa con las reglas de acceso y autenticación.
3.  **Firebase Auth**: Implementa estándares seguros de encriptación y tokens de sesión de manera nativa, aislando al desarrollador de la gestión directa de contraseñas sensibles en las bases de datos.

### Tabla 2.2: Comparativa de Arquitectura de Backend

| Característica | Servidor Propio (Node.js + Postgres) | Firebase BaaS (Elegido) |
| :--- | :--- | :--- |
| **Tiempo de Despliegue** | Alto (Semanas) | Inmediato (Minutos) |
| **Sincronización en Tiempo Real** | Compleja (Requiere configurar WebSockets) | Nativa (Firestore Streams) |
| **Escalabilidad** | Manual (Docker, Kubernetes) | Automática (Google Serverless) |
| **Mantenimiento y DevOps** | Alto (Actualizaciones del S.O, parches) | Nulo (Gestionado por Google) |
| **Coste Inicial** | Fijo (Pago mensual del VPS) | Gratuito (Pago por uso / Plan Spark) |
