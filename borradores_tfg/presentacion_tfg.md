# Guion y Diapositivas para la Presentación del TFG: Streaks

Este documento contiene la estructura detallada de las diapositivas y las **notas de orador (guion)** cronometradas para una presentación de **5 a 10 minutos**. Está diseñado para destacar el valor técnico y la justificación metodológica del proyecto ante el tribunal.

---

## Estructura Temporal Estimada (Total: ~7.5 minutos)

```mermaid
gantt
    title Distribución de Tiempo de la Presentación (7.5 minutos)
    dateFormat  m:s
    axisFormat %M:%S
    
    Diapo 1: Portada y Concepto : active, d1, 00:00, 00:45
    Diapo 2: Motivación y Problema : d2, after d1, 01:15
    Diapo 3: Flutter y Motor de Renderizado : d3, after d2, 01:15
    Diapo 4: Arquitectura Limpia (Clean) : d4, after d3, 01:15
    Diapo 5: Gestión de Estado (Riverpod) : d5, after d4, 01:15
    Diapo 6: Persistencia y Modelo Económico : d6, after d5, 01:15
    Diapo 7: Conclusión y Cierre : d7, after d6, 00:40
```

---

### Diapositiva 1: Portada e Introducción (0:00 - 0:45)

#### 🎨 Diseño de la Diapositiva
*   **Fondo**: Oscuro premium con el gradiente característico de la app *Streaks* (naranja a morado).
*   **Elementos Visuales**: Logo de la aplicación (*Streaks*) en alta resolución al lado izquierdo.
*   **Texto Principal**: 
    *   **Título**: *STREAKS: Red Social Reactiva de Productividad y Control de Hábitos*
    *   **Subtítulo**: *Proyecto de Fin de Ciclo - Técnico Superior en Desarrollo de Aplicaciones Multiplataforma (DAM)*
    *   **Autor**: Juan Carlos [...]

#### 🗣️ Notas del Orador
> *"Buenos días a todos los miembros del tribunal. Mi nombre es Juan Carlos y hoy tengo el placer de presentarles **Streaks**, una plataforma móvil diseñada y desarrollada para abordar uno de los mayores desafíos en el software de productividad personal: la consistencia y la retención del usuario a través de la psicología conductual y el compromiso social o 'social accountability'."*
>
> **[Tiempo acumulado: 0:45]**

---

### Diapositiva 2: La Motivación y el Problema (El "Por Qué") (0:45 - 2:00)

#### 🎨 Diseño de la Diapositiva
*   **Layout**: Distribución en dos columnas.
*   **Columna Izquierda (El Problema)**: 
    *   🔴 **Abandono masivo**: Más del 70% de usuarios desinstalan las apps de hábitos en el primer mes.
    *   🔴 **Aislamiento funcional**: Apps tradicionales en silos cerrados (interacción solo con una base de datos local fría).
    *   🔴 **Monotonía**: Registro clásico basado en simples "checkboxes" de texto sin narrativa visual.
*   **Columna Derecha (La Solución - Streaks)**:
    *   🟢 **Compromiso Social (*Social Accountability*)**: Compartir el esfuerzo diario actúa como catalizador psicológico.
    *   🟢 **Registro Narrativo e Imagen**: Un hábito se valida con una captura fotográfica real de progreso (lectura, gimnasio, estudio).
    *   🟢 **Historial de Rachas (*Streaks*)**: Gamificación social estructurada donde la persistencia se hace visible.

#### 🗣️ Notas del Orador
> *"El punto de partida del proyecto nace del análisis del comportamiento humano. Siguiendo teorías como el 'bucle de habituación' de James Clear en *Hábitos Atómicos*, sabemos que el mantenimiento de un hábito requiere motivación y recompensa. Sin embargo, las aplicaciones actuales en las tiendas oficiales fallan: son herramientas solitarias e individuales. Si no registras un hábito, a nadie le importa, lo que conduce a un abandono del 70% antes del primer mes.*
> 
> *Streaks resuelve esto integrando la productividad con dinámicas de red social. La hipótesis fundamental es que la visibilidad pública de las rachas de progreso y la retroalimentación en tiempo real de una comunidad reducen drásticamente la tasa de deserción."*
>
> **[Tiempo acumulado: 2:00]**

---

### Diapositiva 3: Ecosistema Tecnológico: Flutter y Dart (2:00 - 3:15)

#### 🎨 Diseño de la Diapositiva
*   **Layout**: Gráfico comparativo de arquitecturas visuales y compilación.
*   **Conceptos Clave**:
    *   **Renderizado Directo por GPU**: Flutter dibuja cada píxel en su propio lienzo (*Canvas*) utilizando C++ y el motor **Impeller** (iOS/Android), sin depender de los componentes nativos pesados del sistema operativo (a diferencia de React Native y su *bridge* interpretado).
    *   **Tasa de Refresco**: Fluidez nativa estable a 60-120 FPS.
    *   **Dart VM & Compilación Dual**:
        *   **JIT (Just-In-Time)**: Para el ciclo de desarrollo (*Hot Reload* en menos de un segundo).
        *   **AOT (Ahead-Of-Time)**: Compilación directa a código binario nativo ARM para optimizar batería y rendimiento en producción.

#### 🗣️ Notas del Orador
> *"Para materializar este concepto reactivo, realizamos una evaluación crítica de tecnologías. Descartamos el desarrollo nativo dual por su alto coste y React Native por la latencia que introduce su puente de JavaScript al procesar gestos en tiempo real.*
> 
> *Seleccionamos **Flutter** por su paradigma de renderizado directo: dibuja cada píxel en un Canvas del sistema a través de aceleración por GPU. Esto nos asegura animaciones a 60 FPS estables. Además, el lenguaje **Dart** nos permite trabajar en tiempo de desarrollo con compilación Just-In-Time (Hot Reload casi instantáneo) y compilar a binario de máquina Ahead-Of-Time para producción, eliminando sobrecargas de rendimiento."*
>
> **[Tiempo acumulado: 3:15]**

---

### Diapositiva 4: Organización de Software: Arquitectura Limpia (3:15 - 4:30)

#### 🎨 Diseño de la Diapositiva
*   **Visual**: Diagrama de capas concéntricas (Clean Architecture) implementado en Streaks.
*   **Capas Explicadas**:
    1.  `lib/presentation`: Widgets de Flutter, controladores y estado reactivo.
    2.  `lib/domain`: Entidades puras y casos de uso (reglas del negocio, lógica inmutable de hábitos y rachas). **Cero dependencias del framework gráfico.**
    3.  `lib/data`: Repositorios y fuentes de datos (llamadas NoSQL Firebase, persistencia local caché).
*   **Beneficios**: Desacoplamiento total, testabilidad (inyección de `MockRepositories` para pruebas), robustez ante cambios externos.

#### 🗣️ Notas del Orador
> *"La calidad técnica y escalabilidad del código se han garantizado estructurando la app bajo **Clean Architecture**. Dividimos el sistema en tres capas concéntricas:*
> 
> *En el núcleo se encuentra la capa de **Dominio**, que alberga las reglas de negocio de los hábitos y es completamente independiente de frameworks externos. A su alrededor, la capa de **Datos** se encarga de la comunicación remota con la nube y la persistencia local. Finalmente, la capa de **Presentación** contiene la UI táctil. Este aislamiento estricto facilita la testabilidad y el mantenimiento; por ejemplo, podemos inyectar fuentes de datos simuladas en las pruebas unitarias sin tocar una sola línea de la interfaz gráfica."*
>
> **[Tiempo acumulado: 4:30]**

---

### Diapositiva 5: Gestión de Estado Reactivo con Riverpod (4:30 - 5:45)

#### 🎨 Diseño de la Diapositiva
*   **Visual**: Diagrama del flujo de datos unidireccional (UDF) reactivo.
*   **¿Por qué Riverpod y no alternativas?**:
    *   **Vs. Provider**: Riverpod saca los proveedores fuera del árbol de widgets. Es 100% seguro contra excepciones en tiempo de ejecución de tipo `ProviderNotFoundException`.
    *   **Vs. BLoC**: Evita la verbosidad excesiva (*boilerplate code*) de eventos y estados para un desarrollo ágil de un solo programador.
    *   **Reactividad en Tiempo Real**: Sincronización directa con Streams de Firestore (`StreamProvider`).
    *   **Optimización de Memoria**: Uso de `.autoDispose` para liberar recursos de memoria del dispositivo al salir de una pantalla.

#### 🗣️ Notas del Orador
> *"En aplicaciones móviles reactivas de tiempo real, controlar el estado (los datos que cambian en pantalla) es sumamente complejo. Evaluamos opciones y nos decantamos por **Riverpod**.*
> 
> *A diferencia del clásico Provider recomendado históricamente por Google, Riverpod declara sus estados de forma global, logrando una seguridad del 100% en tiempo de compilación. No puede fallar la app en runtime por no encontrar un proveedor. Su integración con flujos de datos asíncronos nos permite refrescar el feed social de Streaks automáticamente. Además, implementamos el modificador 'autoDispose' para liberar automáticamente la memoria consumida por los perfiles consultados al salir de la pantalla, evitando fugas de memoria."*
>
> **[Tiempo acumulado: 5:45]**

---

### Diapositiva 6: Persistencia y Viabilidad Económica (5:45 - 7:00)

#### 🎨 Diseño de la Diapositiva
*   **Visual**: Gráfico comparativo de Spark vs. Blaze y tabla resumen de costes (10.000 MAUs).
*   **Datos Clave**:
    *   **Consistencia Offline**: Persistencia y escrituras diferidas en caché local de Cloud Firestore ante cortes de red.
    *   **Plan Spark (Gratuito)**: Cubre el 100% del desarrollo y producción inicial (< 1.000 usuarios activos mensuales).
    *   **Plan Blaze (Pago por Uso)**: Escalado a 10.000 usuarios mensuales estimados en **~76,22 USD/mes**.
    *   **Decisión Arquitectónica Clave**: El 92% del coste proviene del ancho de banda por descarga de imágenes pesadas en Firebase Storage. Se implementó una **caché local en cliente** para mitigar la facturación.

#### 🗣️ Notas del Orador
> *"Para el backend, aprovechamos el ecosistema NoSQL de **Firebase**. El diseño soporta tolerancia a fallos offline: si el usuario pierde la conexión, Firestore escribe en su base de datos local y sincroniza automáticamente las operaciones en la nube al recuperar la red.*
> 
> *En cuanto a viabilidad económica, modelamos cuantitativamente los costes. Con menos de 1.000 usuarios mensuales, operamos a coste cero bajo el Plan Spark de Firebase. Al simular una escala de 10.000 usuarios activos mensuales en el Plan Blaze, estimamos un coste mensual de 76 dólares. El análisis reveló que el mayor impacto financiero proviene de las descargas de imágenes en Storage. Por ello, tomamos la decisión técnica de programar una caché local en los terminales de los clientes, optimizando el ancho de banda y garantizando la viabilidad económica del proyecto."*
>
> **[Tiempo acumulado: 7:00]**

---

### Diapositiva 7: Conclusiones, Demo y Cierre (7:00 - 7:45)

#### 🎨 Diseño de la Diapositiva
*   **Layout**: Tarjetas de objetivos logrados.
*   **Métricas de Desarrollo**:
    *   ⏱️ **150 horas de trabajo** planificadas en 6 Sprints ágiles quincenales.
    *   ✅ Objetivos académicos e industriales cumplidos al 100%.
*   **Futuras Líneas**: Integración con *wearables*, analíticas predictivas basadas en IA y migración a arquitecturas multi-backend.
*   **Cierre**: *"Muchas gracias por su atención. Quedo a su entera disposición para responder a sus preguntas."*

#### 🗣️ Notas del Orador
> *"Para finalizar, el desarrollo de Streaks se completó en un ciclo de 150 horas estructurado en 6 sprints ágiles. Hemos cumplido todos los objetivos marcados, creando una arquitectura móvil sólida y ergonómica.*
> 
> *Como trabajo futuro, planeamos integrar lecturas de sensores corporales y expandir el backend. Les agradezco enormemente su atención y quedo a disposición del tribunal para responder a cualquier pregunta o iniciar una breve demostración física de la aplicación. Muchas gracias."*
>
> **[Tiempo acumulado: 7:45]**
