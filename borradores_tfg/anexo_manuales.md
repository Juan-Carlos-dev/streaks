# ANEXO: MANUALES DE USUARIO Y DESPLIEGUE

Este anexo contiene la documentación de explotación necesaria para el uso de la aplicación móvil **Streaks** desde el punto de vista del usuario final, así como la guía técnica de instalación, configuración y compilación del software para evaluadores y personal técnico.

---

## A.1. Manual de Usuario

La aplicación móvil **Streaks** está diseñada con una interfaz interactiva y minimalista centrada en la facilidad de uso. A continuación se detallan las operaciones principales del sistema.

### A.1.1. Registro de Cuenta e Inicio de Sesión
1. **Acceso Inicial**: Al abrir la aplicación por primera vez, el usuario se encuentra con la pantalla de autenticación.
2. **Registro**: Si no dispone de cuenta, debe pulsar en *"¿No tienes cuenta? Regístrate"*. Se le solicitará introducir una dirección de correo electrónico válida y una contraseña de al menos 6 caracteres.
3. **Inicio de Sesión**: Una vez registrado, puede iniciar sesión de forma instantánea. El sistema mantendrá la sesión iniciada de manera persistente localmente mediante tokens de Firebase Auth.

*(Captura de Pantalla recomendada: `assets/manual/auth_screen.png` - Pantalla de login limpia con gradientes en azul oscuro y campos reactivos de texto).*

### A.1.2. Configuración Avanzada del Perfil
El perfil de usuario es su carta de presentación ante la comunidad:
1. Acceda a la pestaña de **Perfil** en la barra de navegación inferior.
2. Pulse sobre el botón **Editar Perfil**.
3. Modifique su nombre de visualización, su biografía o seleccione un gradiente personalizado para su avatar.
4. Pulse **Guardar**. El sistema actualizará de manera atómica el perfil del usuario en Firestore y propagará los cambios a todas sus publicaciones e interacciones.

![Configuración del Perfil de Usuario](../assets/manual/perfil_usuario.png)
*Figura A.1: Panel de perfil de usuario y configuración del sistema.*

### A.1.3. Creación y Gestión de Hábitos
1. En la pantalla principal de hábitos, pulse el botón flotante **"+"** (Añadir Hábito).
2. Introduzca el título de la meta (ej. *"Estudiar DAM 2h"*, *"Gimnasio"*).
3. Seleccione la frecuencia (diaria o días seleccionados) y guarde.
4. **Marcar como Completado**: En la pantalla de hábitos verá el listado. Puede deslizar el interruptor o marcar el círculo del hábito. Al hacerlo, su racha (*streak*) se incrementará de forma automática y se calculará el porcentaje mensual de consistencia.

![Formulario de Creación de Hábito](../assets/manual/nuevo_habito.png)
*Figura A.2: Formulario reactivo para la creación y parametrización de nuevos hábitos.*

### A.1.4. Visualización del Feed Social e Interacción Táctil Drag-to-Like
Esta es la funcionalidad estrella de la aplicación, diseñada para el refuerzo comunitario:
1. Acceda al **Feed Social** (primera pestaña).
2. Verá las fotografías de progreso diario subidas por las personas que sigue.
3. **Gesto Double-Tap**: Al pulsar dos veces rápidamente sobre una imagen, aparecerá una estrella en pantalla y se guardará automáticamente un "like" de motivación.
4. **Mecanismo Drag-to-Like**: 
   * Pulse de forma prolongada sobre la publicación.
   * Se desplegará una barra flotante de reacciones en la parte inferior de la pantalla.
   * Arrastre el dedo sin levantarlo de la pantalla hacia el botón de estrella.
   * Al aproximar el dedo, sentirá una respuesta háptica en el dispositivo confirmando que la estrella ha sido "capturada" por la colisión geométrica. Levante el dedo para confirmar la reacción.

![Feed Social de la Comunidad](../assets/manual/feed_social.png)
*Figura A.3: Feed social interactivo con publicaciones de hábitos del usuario.*

### A.1.5. Visualización del Historial en el Calendario de Desplazamiento Infinito
1. En la parte superior de la pantalla principal se ubica el **Calendario Horizontal**.
2. Puede realizar un gesto de deslizamiento horizontal a la izquierda o derecha de forma fluida (lazy scroll) para consultar cualquier día del año pasado o futuro.
3. Al seleccionar un día del calendario, la interfaz se refrescará para reflejar el estado exacto de los hábitos en esa fecha específica.

![Calendario de Desplazamiento Infinito](../assets/manual/calendario.png)
*Figura A.4: Vista del calendario horizontal con historial semanal de hábitos.*

---

## A.2. Manual de Despliegue e Instalación

Esta sección detalla los pasos para compilar y desplegar la aplicación **Streaks** en un entorno de desarrollo o producción local a partir de su código fuente.

### A.2.1. Requisitos Previos del Sistema
Antes de proceder a la instalación del proyecto, asegúrese de tener instalados los siguientes componentes:
1. **Flutter SDK (versión >= 3.19.0)**: Descargado y configurado en las variables de entorno de su sistema operativo.
2. **Dart SDK**: Integrado por defecto con la instalación de Flutter.
3. **Android Studio** (con SDK de Android y emulador configurado) y/o **Xcode** (para entornos macOS que requieran pruebas en iOS).
4. **Firebase CLI**: Herramienta de consola de Firebase instalada y autenticada (`npm install -g firebase-tools` y `firebase login`).
5. Conectividad física a un terminal móvil con el modo de depuración USB activado.

### A.2.2. Paso 1: Clonar y Descargar Dependencias
Abra su terminal de consola, navegue al directorio donde desea ubicar el proyecto y ejecute los siguientes comandos:

```bash
# Descargar las dependencias declaradas en el archivo pubspec.yaml
flutter pub get
```

### A.2.3. Paso 2: Configuración del Proyecto Firebase
La app requiere de una instancia propia de Firebase. Siga estos pasos para enlazarla:
1. Acceda a [Firebase Console](https://console.firebase.google.com/) y cree un nuevo proyecto llamado `streaks-app`.
2. Habilite los siguientes servicios en el menú lateral:
   * **Authentication**: Habilite el proveedor de *Correo electrónico/Contraseña*.
   * **Cloud Firestore**: Cree una base de datos en modo producción y seleccione una ubicación regional de su preferencia.
   * **Cloud Storage**: Habilite el almacenamiento de archivos multimedia por defecto.
3. Descargue e integre los archivos de configuración nativos:
   * **Android**: Genere el archivo `google-services.json` desde la sección de configuración de la app en Firebase Console y colóquelo en la ruta del proyecto: `android/app/google-services.json`.
   * **iOS**: Genere el archivo `GoogleService-Info.plist` y colóquelo en la ruta del proyecto: `ios/Runner/GoogleService-Info.plist` utilizando Xcode para vincular el archivo al árbol de compilación.
4. Alternativamente, puede automatizar este proceso utilizando FlutterFire CLI:
   ```bash
   # Activar globalmente el CLI de FlutterFire
   dart pub global activate flutterfire_cli
   
   # Configurar la app de forma guiada para Android e iOS
   flutterfire configure --project=streaks-app
   ```

### A.2.4. Paso 3: Ejecución en Modo Desarrollo
Para ejecutar la aplicación en caliente con la tecnología Hot Reload activa:
1. Inicie su emulador o conecte su dispositivo físico.
2. Verifique la conexión mediante el comando:
   ```bash
   flutter devices
   ```
3. Ejecute la aplicación con el comando:
   ```bash
   flutter run
   ```

### A.2.5. Paso 4: Compilación para Producción (Instalables)

#### Compilar para Android (generar archivo APK)
Para distribuir la aplicación directamente en dispositivos Android sin pasar por Google Play Store:
```bash
flutter build apk --release
```
El archivo resultante se generará en la ruta:  
`build/app/outputs/flutter-apk/app-release.apk`

*Si prefiere generar un paquete App Bundle optimizado para subir a Google Play Console:*
```bash
flutter build appbundle
```

#### Compilar para iOS (generar paquete IPA)
*Si el entorno es macOS con Xcode configurado y se cuenta con una suscripción de desarrollador activa:*
```bash
flutter build ipa --export-method development
```
El paquete final comprimido se generará en el subdirectorio `build/ios/archive/` listo para ser subido a TestFlight o distribuido de forma ad-hoc.

---

## A.3. Galería de Capturas de Pantalla de la Interfaz y Funcionamiento

A continuación, se detalla el catálogo visual de la aplicación móvil **Streaks**. Cada una de estas imágenes ilustra una parte fundamental de la lógica del sistema, los componentes visuales interactivos y la experiencia de usuario (UX) implementada bajo las pautas de diseño del sistema.

### A.3.1. Formulario de Creación de Hábito
La interfaz de creación de hábitos está diseñada para minimizar la carga cognitiva del usuario mediante controles reactivos directos:

![Formulario de Creación de Hábito](../assets/manual/nuevo_habito.png)
*Figura A.5: Pantalla de adición y configuración de un nuevo hábito en Streaks.*

* **Detalles de la Interfaz**:
  * **Nombre del hábito**: Campo de texto interactivo con foco automático e indicaciones visuales claras en caso de validación vacía.
  * **Configuración visual**: Selector de iconos en formato rejilla y selector de color para identificar de forma unívoca la racha en la pantalla principal.
  * **Días de la semana**: Selector múltiple circular (`L | M | M | J | V | S | D`) para programar la recurrencia periódica de la meta.
  * **Barra de navegación inferior**: Acceso instantáneo a las secciones principales (*Inicio*, *Stats*, *Calendario*, *Perfil*), manteniendo al usuario siempre contextualizado.

### A.3.2. Calendario de Desplazamiento Infinito
El componente de calendario horizontal es una de las piezas clave en la visualización histórica de la aplicación:

![Calendario de Desplazamiento Infinito](../assets/manual/calendario.png)
*Figura A.6: Barra superior del calendario reactivo para la consulta de hábitos históricos.*

* **Detalles de la Interfaz**:
  * **Componente de Scroll Horizontal**: Barra superior que implementa un desplazamiento perezoso (*lazy row*), lo que permite al usuario navegar por los días del año de forma fluida y sin caídas de framerate.
  * **Indicadores Visuales de Estado**: Cada círculo numérico destaca de forma sutil el día actual y refleja mediante gradientes el porcentaje global de hábitos cumplidos en la fecha correspondiente.
  * **Sincronización de Datos**: Al pulsar un día determinado, el estado global de la aplicación se actualiza atómicamente, refrescando el listado de hábitos inferiores mediante un flujo reactivo provisto por Riverpod.

### A.3.3. Feed de Actividad Social
La gamificación comunitaria de Streaks se apoya en el Feed Social, donde los usuarios comparten sus progresos reales:

![Feed Social de la Comunidad](../assets/manual/feed_social.png)
*Figura A.7: Listado de publicaciones de usuarios activos de la comunidad en tiempo real.*

* **Detalles de la Interfaz**:
  * **Estructura del Feed**: Las publicaciones de los usuarios seguidos se listan cronológicamente. Cada publicación muestra el avatar del creador, el nombre, el hábito asociado (ej. *"Programando más"*, *"Programando mi app"*) y la estampa temporal relativa (ej. *"hace 23 minutos"*).
  * **Soporte Multimedia**: Integración con Firebase Storage para la carga progresiva de imágenes del progreso del hábito con efecto visual de difuminado (*fade-in*) durante la carga del buffer.
  * **Acciones de Interacción**: Los iconos de reacción rápida en la parte inferior de cada tarjeta permiten un refuerzo inmediato.

### A.3.4. Perfiles de Usuario y Ajustes del Sistema
El perfil del usuario consolida la información pública y proporciona acceso a los ajustes de la cuenta:

| Perfil Personal y Ajustes | Perfil de Otros Miembros (Social) |
| :---: | :---: |
| ![Perfil Propio](../assets/manual/perfil_usuario.png) | ![Perfil Ajeno](../assets/manual/perfil_ajeno.png) |
| *Figura A.8: Vista de perfil personal y lista de ajustes.* | *Figura A.9: Vista de un perfil ajeno con acciones sociales.* |

* **Detalles del Perfil Propio (Figura A.8)**:
  * **Identificación del Usuario**: Cabecera con avatar personalizado y estadísticas de socialización (*Seguidores* y *Siguiendo*).
  * **Opciones de Configuración**: Lista interactiva para personalizar el widget de iOS, cambiar contraseña, gestionar recordatorios e inicio de sesión persistente.
* **Detalles del Perfil de Terceros (Figura A.9)**:
  * **Acciones Sociales**: Botón destacado de *"Seguir/Dejar de seguir"* que modifica de forma instantánea la relación bidireccional en Firestore.
  * **Acción de Mensajería**: Acceso directo al chat privado mediante el botón *"Mensaje"*, inicializando un canal reactivo de comunicación mediante WebSockets/Stream Firestore.

### A.3.5. Gestión de Excepciones en Tiempo de Ejecución (Robustez del Sistema)
Como parte del plan de control de calidad y pruebas unitarias, se ha implementado un sistema resiliente ante fallos de desbordamiento de datos:

![Gestión de Excepciones](../assets/manual/gestion_errores.png)
*Figura A.10: Pantalla de captura y gestión de errores de aserción en fase de depuración.*

* **Detalles de la Interfaz**:
  * **Resiliencia ante Fallos**: La captura ilustra la gestión controlada de una excepción de rango (`RangeError (index): Invalid value`) durante el procesamiento asíncrono de índices.
  * **Comportamiento en Producción**: El sistema intercepta estos errores mediante `FlutterError.onError` redirigiendo el flujo hacia una vista de recuperación amigable en lugar de provocar el cierre inesperado (*crash*) de la aplicación.
  * **Trazabilidad**: Los logs se envían automáticamente de manera offline a la base de datos local y se sincronizan cuando hay conectividad a través de Crashlytics.
