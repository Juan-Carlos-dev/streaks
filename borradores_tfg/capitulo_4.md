# CAPÍTULO 4: DISEÑO DEL SISTEMA Y ARQUITECTURA

En este capítulo se detalla el diseño arquitectónico seleccionado para la aplicación **Streaks**. Se describe de manera rigurosa la estructura de capas elegida bajo los principios de **Clean Architecture**, la justificación técnica de la gestión de estados con **Riverpod** y la integración reactiva con **Firebase**. El principal objetivo de este diseño es garantizar la modularidad, testeabilidad, escalabilidad y robustez del software desarrollado durante el periodo de prácticas.

---

## 4.1. Fundamentación Teórica del Diseño Arquitectónico (Clean Architecture y SOLID)

El desarrollo de aplicaciones móviles modernas exige una arquitectura que aísle la lógica del negocio de los cambios tecnológicos constantes en las interfaces de usuario o en los proveedores de servicios en la nube. En la aplicación **Streaks**, se ha implementado **Clean Architecture** (Arquitectura Limpia) para estructurar el código fuente en capas concéntricas bien definidas.

```
       +---------------------------------------------------+
       | Capa de Presentación (UI / Screens / Widgets)      |
       |  +---------------------------------------------+  |
       |  | Capa de Datos (Implementaciones / Firebase) |  |
       |  |  +---------------------------------------+  |  |
       |  |  | Capa de Dominio (Entidades / Repos)   |  |  |
       |  |  |                                       |  |  |
       |  |  +---------------------------------------+  |  |
       |  +---------------------------------------------+  |
       +---------------------------------------------------+
```

La regla fundamental de esta arquitectura es la **Regla de Dependencia**: las dependencias del código fuente solo pueden apuntar hacia adentro. Las capas externas son detalles de implementación que pueden ser sustituidos sin alterar el núcleo.

### Aplicación de los Principios SOLID en Streaks:
* **Principio de Responsabilidad Única (SRP)**: Cada clase, widget y proveedor tiene una única responsabilidad bien acotada. Por ejemplo, la clase `ImagePreviewWrapper` se encarga exclusivamente de la detección gestual del preview, abstrayéndose de la lógica de recuperación de datos.
* **Principio de Abierto/Cerrado (OCP)**: Las clases están abiertas a la extensión pero cerradas a la modificación. Se pueden añadir nuevos tipos de hábitos o filtros sin alterar las interfaces principales.
* **Principio de Inversión de Dependencias (DIP)**: Los módulos de alto nivel (Dominio) no dependen de módulos de bajo nivel (Datos/Firebase). Ambos dependen de abstracciones. La capa de presentación y la capa de datos dependen de las interfaces definidas en la capa de dominio.

---

## 4.2. Análisis Detallado del Núcleo del Sistema (Domain Layer)

La capa de **Dominio** (`lib/domain`) es la más interna de la aplicación. Está escrita exclusivamente en Dart puro, aislada por completo de dependencias de Flutter, bases de datos o frameworks. Contiene la lógica esencial del negocio y los modelos conceptuales.

### 4.2.1. Entidades del Dominio (`lib/domain/entities`)
Son los objetos de negocio que modelan los datos de la aplicación.
* **Post (`post.dart`)**: Modela una publicación del feed social. Encapsula las propiedades de la imagen, el usuario creador, el pie de foto, la fecha de creación, el recuento de estrellas y la lista de usuarios que han marcado la publicación.
* **User (`user.dart`)**: Modela el perfil del usuario, controlando los datos personales, el índice del gradiente visual elegido y las estadísticas de seguidores.
* **Habit (`habit.dart`)**: Modela los hábitos diarios y semanales que el usuario monitoriza, sus rachas y fechas de cumplimiento.
* **Message (`message.dart`)**: Define la estructura de los chats entre usuarios.

### 4.2.2. Interfaces de Repositorio (`lib/domain/repositories`)
Los repositorios actúan como mediadores entre la lógica de dominio y los orígenes de datos externos. En el dominio se definen únicamente los contratos conceptuales. Por ejemplo, en [post_repository.dart](file:///Volumes/Lexar%20SL300/streaks/lib/domain/repositories/post_repository.dart):

```dart
abstract class PostRepository {
  Stream<List<Post>> watchFeedPosts();
  Stream<List<Post>> watchUserPosts(String userId);
  Future<void> createPost(String imageUrl, String caption);
  Future<void> toggleLike(String postId);
  Future<void> deletePost(String postId);
}
```

---

## 4.3. Implementación Práctica del Acceso a Datos (Data Layer)

La capa de **Datos** (`lib/data`) rodea a la capa de dominio e implementa de manera concreta sus contratos de repositorio, sirviendo como canal de comunicación directo con las API y servicios en la nube de Firebase.

### 4.3.1. Clases de Implementación (`lib/data/repositories`)
Esta capa depende de dependencias externas como `cloud_firestore` y `firebase_auth`. Por ejemplo, en [post_repository_impl.dart](file:///Volumes/Lexar%20SL300/streaks/lib/data/repositories/post_repository_impl.dart), implementamos `PostRepository` de la siguiente forma:

```dart
class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PostRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<Post>> watchFeedPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> toggleLike(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Usuario no autenticado');

    final postRef = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) throw Exception('Publicación no encontrada');

      final likedBy = List<String>.from(snapshot.data()?['likedBy'] ?? []);
      final userId = currentUser.uid;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }

      transaction.update(postRef, {
        'likedBy': likedBy,
        'likesCount': likedBy.length,
      });
    });
  }
  
  // Implementación del resto de métodos...
}
```

### 4.3.2. Mapeo e Integración NoSQL
Firestore almacena la información estructurada en mapas clave-valor (`Map<String, dynamic>`). Para asegurar el tipado fuerte y la mantenibilidad, los métodos del repositorio implementan conversores que procesan la información de los `DocumentSnapshot` y devuelven colecciones tipadas de objetos del dominio (`List<Post>`), aislando la sintaxis de Firebase del resto de la aplicación.

---

## 4.4. La Interfaz de Usuario y los Estados Visuales (Presentation Layer)

La capa de **Presentación** (`lib/presentation`) es la encargada de dibujar los componentes visuales en pantalla e interpretar las interacciones táctiles del usuario. Se estructura mediante el patrón MVVM y contiene:

1. **Pantallas (`screens/`)**: Vistas que ocupan todo el espacio del dispositivo y reaccionan al estado expuesto por los proveedores. 
   * [profile_screen.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/screens/profile_screen.dart) dibuja el feed de publicaciones del propio usuario y su panel de hábitos.
   * [user_profile_screen.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/screens/user_profile_screen.dart) renderiza la vista pública de otros usuarios del sistema.
2. **Componentes Visuales (`widgets/`)**: Elementos visuales reutilizables.
   * [image_preview_popup.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/widgets/image_preview_popup.dart) administra de manera controlada el overlay emergente para visualizar imágenes a gran escala y procesa el doble toque para dar estrellas y cerrar la previsualización.
3. **Manejadores de Estado (`providers/`)**: Actúan como ViewModels lógicos, exponiendo la información de los repositorios en forma de flujos de datos síncronos o asíncronos consumibles directamente por los widgets de Flutter.

---

## 4.5. Inyección de Dependencias y Desacoplamiento Eficiente con Riverpod

En lugar de instanciar clases concretas de la capa de datos dentro del árbol de widgets, se utiliza un patrón de Inyección de Dependencias mediante proveedores declarativos de **Riverpod**.

Los repositorios se exponen de forma global como interfaces inyectables:

```dart
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl();
});
```

Cuando un ViewModel de la capa de presentación necesita consultar o modificar datos, no realiza llamadas estáticas ni acopla clases de persistencia, sino que solicita la abstracción resolviendo el proveedor:

```dart
final toggleLikeProvider = FutureProvider.family<void, String>((ref, postId) async {
  final repository = ref.read(postRepositoryProvider);
  return repository.toggleLike(postId);
});
```

Este desacoplamiento facilita la creación de pruebas de integración y unitarias de la interfaz gráfica de usuario. Es posible anular el proveedor en un entorno de pruebas inyectando una clase simulada (`MockPostRepository`) sin realizar conexiones reales a servidores externos ni bases de datos activas.

---

## 4.6. Arquitectura de Controladores y Modelado de Estado de la Vista (ViewModel)

El flujo de control de datos en Streaks se rige por un principio de **Flujo Unidireccional de Datos (UDF)**. Esto significa que la UI no modifica directamente el estado interno ni la base de datos de manera directa; todo cambio viaja en un ciclo único y controlado:

```
[ Gesto de Usuario ] ---> [ Invocación de Acción ] ---> [ Capa de Repositorios (Data) ]
       ^                                                                |
       |                                                                v
[ Redibujado de UI ] <--- [ Stream de Proveedores ] <--- [ Actualización en Firestore ]
```

### Proceso de Ejemplo (Dar Estrella mediante Doble Toque):
1. **Acción**: El usuario realiza un doble toque en la imagen emergente dentro de la ventana de previsualización.
2. **Controlador**: El widget llama a la función expuesta por el Notificador (`widget.onLike!`).
3. **Persistencia**: Se ejecuta el método `toggleLike` a través del repositorio concreto inyectado, enviando una petición asíncrona a Firestore.
4. **Respuesta**: Cloud Firestore procesa la transacción de forma segura y actualiza el contador de likes en su servidor en la nube.
5. **Notificación**: Al actualizarse el documento, el Stream activo notifica a Riverpod, reconstruyendo el estado del widget y redibujando la pantalla con el contador incrementado y el icono de la estrella relleno.

---

## 4.7. Flujo de Datos Reactivo en Tiempo Real y StreamProvider

Para implementar un feed social verdaderamente reactivo y sin esperas, Streaks no solicita actualizaciones manuales. En su lugar, consume los canales en tiempo real de Firestore mapeándolos en `StreamProvider` de Riverpod.

En el archivo de estado del feed [feed_providers.dart](file:///Volumes/Lexar%20SL300/streaks/lib/presentation/providers/feed_providers.dart), se define el flujo:

```dart
final feedPostsProvider = StreamProvider<List<Post>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.watchFeedPosts();
});
```

En la capa de visualización, la lectura se realiza de forma limpia y declarativa mediante el método `when` del estado del proveedor:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final postsAsync = ref.watch(feedPostsProvider);

  return postsAsync.when(
    data: (posts) => ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    ),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => Center(child: Text('Error: $error')),
  );
}
```

Gracias al uso del modificador `.autoDispose` en los proveedores dinámicos, Riverpod se encarga de cerrar de forma automática el canal de escucha abierto (`StreamSubscription`) cuando el usuario navega fuera de la pantalla del feed, protegiendo al dispositivo móvil de fugas de memoria y reduciendo el consumo de batería y datos de red.

---

## 4.8. Gestión de Caché Local (Caching) y Persistencia Offline en Firestore

Dado que los dispositivos móviles sufren frecuentemente de cortes temporales en su conectividad a Internet, se ha configurado el SDK de Firestore para habilitar la persistencia de datos local offline de manera persistente.

Este mecanismo modifica el ciclo tradicional de acceso a los datos:
1. **Velocidad de Carga Instantánea**: Al abrir la aplicación o acceder al perfil del usuario, el repositorio lee en primera instancia los datos directamente de la base de datos de caché SQLite interna del teléfono móvil. La UI carga los datos inmediatamente.
2. **Sincronización Silenciosa**: Al recuperar la conexión a Internet, el SDK descarga las actualizaciones más recientes y actualiza el `Stream` para redibujar la vista con los datos más recientes.
3. **Escrituras Optimistas**: Al dar una estrella a un post sin conexión, la interfaz gráfica simula el éxito de la operación. El repositorio guarda localmente la transacción pendiente y la sincroniza con los servidores remotos de Google una vez restablecida la red, asegurando una experiencia de usuario ininterrumpida y resiliente.

---

## 4.9. Resumen y Conclusiones del Diseño Arquitectónico

La adopción de Clean Architecture en combinación con Riverpod ha demostrado ser la solución técnica idónea para el desarrollo de Streaks durante la realización de las prácticas de desarrollo de software:

* **Desacoplamiento Estricto**: Ha permitido separar la interfaz de usuario de las integraciones de la base de datos. Modificar el comportamiento de la previsualización de imágenes (cambiando el arrastre físico por un doble toque interactivo) se resolvió de forma aislada en la capa de presentación sin alterar las consultas de red ni el modelo de datos.
* **Mantenibilidad Académica y Profesional**: Cumplir estrictamente la regla de dependencias garantiza un código limpio, estructurado y documentable, permitiendo a cualquier desarrollador comprender el flujo lúdico de la aplicación analizando únicamente la capa conceptual del dominio.
* **Eficiencia de Recursos**: La combinación de Streams nativos y la inyección declarativa de Riverpod reduce sustancialmente el número de peticiones a la base de datos NoSQL, minimizando los costes operativos y maximizando la autonomía del terminal móvil.
