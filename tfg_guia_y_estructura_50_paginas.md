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
Este capítulo describe la arquitectura de software seleccionada para la aplicación **Streaks**, justificando las decisiones de diseño desde una perspectiva de ingeniería del software. Se detalla la implementación de los principios Clean Architecture, el desacoplamiento de componentes y el flujo de datos reactivo gobernado por Riverpod.

---

### Página 24: Fundamentación Teórica del Diseño Arquitectónico (Clean Architecture y SOLID)
El principal desafío técnico del proyecto radica en construir un sistema móvil robusto que evite el acoplamiento rígido con el proveedor de la infraestructura en la nube (Firebase). Para resolver esto, se ha optado por implementar **Clean Architecture**, estructurando el código en capas concéntricas aisladas.

Este enfoque arquitectónico garantiza cuatro propiedades fundamentales:
1. **Independencia del Framework**: La lógica de negocio no sabe nada del motor de renderizado de Flutter. Podríamos migrar la UI a otra tecnología sin reescribir las reglas del sistema.
2. **Testeabilidad**: Las reglas de negocio se pueden probar de forma aislada sin necesidad de levantar bases de datos, servidores de red o interfaces visuales.
3. **Independencia de la Base de Datos**: La persistencia es un detalle de implementación secundario. El núcleo de la aplicación interactúa con interfaces de repositorio abstractas, aislando al sistema de si los datos provienen de Firestore, SQLite o memoria volátil.
4. **Independencia de la UI**: La interfaz gráfica puede cambiar sustancialmente (como la modificación del gesto Drag-to-Like al doble toque en imágenes en `ImagePreviewWrapper`) sin alterar en lo más mínimo las reglas operativas internas.

A nivel de principios **SOLID**, la arquitectura aprovecha intensivamente el **Principio de Inversión de Dependencias (DIP)**: las capas de mayor nivel abstracto (Dominio) no dependen de las capas de bajo nivel (Datos o Presentación), sino que todas las capas dependen de abstracciones definidas en el dominio. Asimismo, se aplica el **Principio de Responsabilidad Única (SRP)** en el diseño de los controladores de estado de Riverpod, limitando el ámbito de cada proveedor al control exclusivo de un módulo lógico del sistema (e.g., autenticación, feed de posts o gestión de seguidores).

---

### Página 25: Análisis Detallado del Núcleo del Sistema (Domain Layer)
La capa de **Dominio** se ubica en el centro de la arquitectura del software (`lib/domain`). Se encuentra escrita en Dart puro, sin importar paquetes de Flutter ni del SDK de Firebase. Su única responsabilidad es modelar el negocio de la aplicación a través de dos tipos de componentes:

1. **Entidades (`lib/domain/entities`)**: Modelos de datos del negocio libres de efectos secundarios. 
   * [post.dart](file:///Volumes/Lexar%20SL300/streaks/lib/domain/entities/post.dart): Define la entidad `Post`, que encapsula las propiedades básicas de una publicación (ID, autor, URL de imagen, caption, cantidad de estrellas y lista de UIDs que interactuaron con ella).
   * [user.dart](file:///Volumes/Lexar%20SL300/streaks/lib/domain/entities/user.dart): Estructura la entidad `User` con campos como nombre de usuario, email, índice de gradiente de perfil, contadores de seguidores y URL del avatar.
   * [habit.dart](file:///Volumes/Lexar%20SL300/streaks/lib/domain/entities/habit.dart): Modela el hábito a seguir y sus estados de racha actual e histórica.
   * [message.dart](file:///Volumes/Lexar%20SL300/streaks/lib/domain/entities/message.dart): Modela la mensajería interna.

2. **Repositorios Abstractos (`lib/domain/repositories`)**: Interfaces abstractas que actúan como contratos de persistencia. Define la firma de las operaciones válidas del sistema, pero no cómo se ejecutan. Por ejemplo, en [post_repository.dart](file:///Volumes/Lexar%20SL300/streaks/lib/domain/repositories/post_repository.dart):

```dart
abstract class PostRepository {
  Stream<List<Post>> watchFeedPosts();
  Stream<List<Post>> watchUserPosts(String userId);
  Future<void> createPost(String imageUrl, String caption);
  Future<void> toggleLike(String postId);
  Future<void> deletePost(String postId);
}
```

Al obligar al resto de la aplicación a comunicarse mediante este contrato, aseguramos que la capa de presentación consuma abstracciones, haciendo invisible el almacenamiento real de datos.

---

### Página 26: Implementación Práctica del Acceso a Datos (Data Layer)
La capa de **Datos** (`lib/data`) contiene las implementaciones reales de los repositorios abstractos definidos en el Dominio. Es aquí donde se realiza la integración directa con el SDK de Firebase (Authentication y Firestore).

En la subcarpeta `lib/data/repositories`, encontramos los archivos de implementación concretos, por ejemplo [post_repository_impl.dart](file:///Volumes/Lexar%20SL300/streaks/lib/data/repositories/post_repository_impl.dart), el cual implementa `PostRepository`. 

Esta capa asume la responsabilidad de:
* **Conectarse con el origen físico de los datos**: Usa las referencias de `FirebaseFirestore.instance` y realiza consultas a colecciones específicas.
* **Transformar y mapear modelos NoSQL**: La base de datos relacional orientada a documentos Firestore trabaja con mapas serializados (`Map<String, dynamic>`). Esta capa procesa los documentos crudos (`DocumentSnapshot`) y los convierte en entidades fuertemente tipadas del dominio mediante constructores de mapeo como `Post.fromMap(...)`.
* **Tratar excepciones específicas de red**: Captura errores propios de los servicios Firebase (ej. cuotas superadas, fallos de permisos de red) y los convierte en excepciones tipadas del dominio para ser interpretadas por los controladores visuales sin acoplar la UI a la sintaxis del framework de Google.

---

### Página 27: La Interfaz de Usuario y los Estados Visuales (Presentation Layer)
La capa de **Presentación** (`lib/presentation`) maneja la interacción directa con el usuario final de Streaks. Esta capa está estructurada bajo el patrón arquitectónico MVVM (Model-View-ViewModel), utilizando Flutter para las Vistas e inyectores reactivos de Riverpod para los Modelos de Vista.

La capa está dividida físicamente en tres directorios principales:
1. **`lib/presentation/screens`**: Representa las páginas principales de la aplicación (vistas completas con ciclo de vida del árbol de widgets). Entre ellas destacan:
   * [profile_screen.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/screens/profile_screen.dart): Maneja el feed del usuario propio y la visualización de hábitos.
   * [user_profile_screen.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/screens/user_profile_screen.dart): Renderiza perfiles ajenos con sus publicaciones.
2. **`lib/presentation/widgets`**: Componentes atómicos reutilizables diseñados para dotar de dinamismo e interactividad visual a la app. 
   * [image_preview_popup.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/widgets/image_preview_popup.dart): Alberga la lógica de previsualización táctil, capturando interacciones avanzadas como el doble toque para dar estrellas y renderizando la animación de partículas mediante un controlador gráfico local (`AnimationController`).
3. **`lib/presentation/providers`**: Representa los ViewModels/Controladores del sistema. Almacenan y exponen el estado actual de las vistas a través de abstracciones reactivas.

---

### Página 28: Inyección de Dependencias y Desacoplamiento Eficiente con Riverpod
Para cumplir rigurosamente el Principio de Inversión de Dependencias (DIP) sin introducir un contenedor de inyección complejo e invasivo, la aplicación aprovecha el sistema de proveedores jerárquicos de **Riverpod**.

En el sistema, los repositorios reales no se instancian directamente en la UI. En su lugar, se exponen como proveedores globales de solo lectura:

```dart
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});
```

Cualquier controlador de la presentación que necesite operar sobre publicaciones, no referencia al constructor de la base de datos de datos, sino que solicita la dependencia usando el contenedor de Riverpod. Por ejemplo, en [feed_providers.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/providers/feed_providers.dart):

```dart
final toggleLikeProvider = FutureProvider.family<void, String>((ref, postId) async {
  final repository = ref.read(postRepositoryProvider);
  return repository.toggleLike(postId);
});
```

**Ventaja de Testeo Unitario**: En entornos de pruebas unitarias (`test/`), es posible simular la persistencia sobrepasando la implementación del proveedor de la siguiente forma, sin tocar una sola línea de código del frontend:

```dart
final container = ProviderContainer(
  overrides: [
    postRepositoryProvider.overrideWithValue(MockPostRepository()),
  ],
);
```

---

### Página 29: Arquitectura de Controladores y Modelado de Estado de la Vista (ViewModel)
El flujo de control de Streaks sigue un ciclo de vida cerrado unidireccional y reactivo. La vista nunca altera el estado del modelo directamente; en su lugar, delega eventos en los controladores inyectados de Riverpod.

El flujo básico de interacción se estructura de la siguiente manera:
1. **Acción del Usuario (UI)**: El usuario pulsa dos veces en la foto de progreso. El componente `PreviewOverlayWidget` captura el evento en su `GestureDetector` e invoca la llamada a la acción asociada.
2. **Delegación de Evento (Provider)**: La vista ejecuta el callback de interacción (ej. `onLike`), el cual apunta a una función de actualización manejada por un `Notifier` de Riverpod.
3. **Persistencia (Repository/Data)**: El Notificador de estado invoca al `PostRepository` inyectado para realizar el `toggleLike(postId)` en Firestore.
4. **Respuesta Asíncrona**: El servidor procesa la escritura y actualiza el documento.
5. **Reacción Automática (Stream)**: El canal de datos activo (`StreamProvider`) detecta el nuevo snapshot del documento modificado y propaga el estado reconstruyendo los widgets suscritos de forma automática.

```
+-----------------------------------------------------+
|                  PRESENTATION LAYER                 |
|   +-----------------------+                         |
|   |   Widget de la Vista  |                         |
|   | (ConsumerWidget / UI) | <===================+   |
|   +-----------------------+                     |   |
|               | (Doble toque / Evento)          |   |
|               v                                 |   |
|   +-----------------------+                     |   |
|   |  Notifier / Provider  |                     |   |
|   |      (ViewModel)      |                     |   |
|   +-----------------------+                     |   |
|               |                                 |   |
+---------------|---------------------------------|---+
|               | (Usa la interfaz abstracta)     |   |
|               v                                 |   |
|   +-----------------------+                     |   |
|   |    PostRepository     | (Dominio/Contrato)  |   |
|   +-----------------------+                     |   |
|               |                                 |   |
+---------------|---------------------------------|---+
|               v                                 |   |
|   +-----------------------+                     |   |
|   |  PostRepositoryImpl   | (Datos)             |   |
|   +-----------------------+                     |   |
|               |                                 |   |
+---------------|---------------------------------|---+
                v                                 |
    +-----------------------+                     | (Suscripción activa)
    |  Cloud Firestore API  | ====================+ (Stream Snapshot)
    +-----------------------+
```

---

### Página 30: Flujo de Datos Reactivo en Tiempo Real y StreamProvider
El feed social de Streaks requiere reflejar instantáneamente el incremento de estrellas y la subida de publicaciones entre la red de contactos. En lugar de forzar actualizaciones manuales o realizar encuestas repetitivas (*polling*), se aprovecha el patrón reactivo mediante la combinación de `Stream` de Dart y `StreamProvider` de Riverpod.

En el archivo de proveedores del feed, se configura la escucha activa del canal de datos:

```dart
final userPostsStreamProvider = StreamProvider.family<List<Post>, String>((ref, userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.watchUserPosts(userId);
});
```

* **Escucha Activa**: El método `watchUserPosts` del repositorio de datos devuelve un flujo continuo (`Stream<List<Post>>`) mapeado a partir de los `snapshots()` de una consulta parametrizada a la colección de Firestore.
* **Auto-Mantenimiento**: Si otro usuario de la red social otorga una estrella a una publicación, Firestore notifica de forma nativa la modificación a través de la conexión web abierta.
* **Manejo UI Limpio**: La vista simplemente consume el proveedor y utiliza la coincidencia de patrones (*pattern matching*) nativa de los estados asíncronos de Riverpod (`AsyncValue`), lo que automatiza y limpia la gestión de estados de carga, éxito y error:

```dart
userPostsAsync.when(
  data: (posts) => ListView.builder(itemCount: posts.length, ...),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => Text('Error al cargar feed: $err'),
);
```

---

### Página 31: Gestión de Caché Local (Caching) y Persistencia Offline en Firestore
Un factor crítico de calidad en la memoria de prácticas de una app móvil es el comportamiento del software en entornos con conectividad inestable o nula. En Streaks, la persistencia offline se resuelve mediante el aprovechamiento de la base de datos local y la caché de documentos de Firebase Firestore.

Al inicializar la aplicación, la base de datos se configura para habilitar la persistencia persistente fuera de línea (*Offline Persistence*). Esto altera el flujo tradicional de la capa de datos:

1. **Lectura de Caché Prioritaria**: Cuando la aplicación solicita el feed de fotos mediante el repositorio, Firestore devuelve inmediatamente los registros almacenados en su caché SQLite local en el dispositivo. Esto permite una velocidad de renderizado instantánea.
2. **Sincronización en Background**: Paralelamente, el SDK establece la conexión de red en segundo plano para verificar si existen actualizaciones en el servidor. Si se encuentran datos nuevos, el Stream emite un nuevo evento con la información consolidada, actualizando la UI de manera fluida.
3. **Escrituras Offline mediante Concurrencia Optimista**: Cuando el usuario da doble tap a una foto en modo avión, el repositorio procesa la acción de inmediato a nivel local. La UI simula visualmente la adición de la estrella. El SDK encolará internamente la transacción mutacional de red y la ejecutará contra el servidor en la nube en el momento exacto en que la conectividad a Internet sea restaurada.

---

### Página 32: Resumen y Conclusiones del Diseño Arquitectónico
La implantación de Clean Architecture y Riverpod en Streaks ha demostrado aportar grandes ventajas operativas durante el transcurso del desarrollo del proyecto:

* **Separación Efectiva de Responsabilidad**: Ha sido viable rediseñar por completo la capa de presentación (sustituyendo el complejo botón de arrastre por un gesto intuitivo de doble toque en la foto) sin tocar una sola línea de código en la capa de lógica empresarial (`lib/domain`) o en la capa de datos (`lib/data`).
* **Facilidad en la Rotación de Miembros**: En un contexto de desarrollo real de prácticas de empresa, un nuevo programador puede incorporarse y comprender el comportamiento del feed analizando exclusivamente los archivos en `lib/domain` sin necesidad de entender la configuración del entorno de Firebase ni la estructura interna de las vistas complejas de Flutter.
* **Control de Ciclo de Vida**: Riverpod optimiza el consumo de memoria liberando automáticamente el estado de los proveedores cuando la UI deja de consumirlos (haciendo uso del modificador `.autoDispose`). Esto previene fugas de memoria típicas al retener streams activos de red de forma innecesaria.

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
