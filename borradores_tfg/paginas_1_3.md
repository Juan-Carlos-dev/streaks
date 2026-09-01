# PROYECTO DE FIN DE CICLO

**I.E.S. [NOMBRE DEL INSTITUTO]**  
**DEPARTAMENTO DE INFORMÁTICA Y COMUNICACIONES**  
**CICLO FORMATIVO DE GRADO SUPERIOR EN DESARROLLO DE APLICACIONES MULTIPLATAFORMA (DAM)**

***

## DESARROLLO DE UNA RED SOCIAL DE PRODUCTIVIDAD Y SEGUIMIENTO DE HÁBITOS BASADA EN GAMIFICACIÓN
### "STREAKS: CONECTANDO EL PROGRESO PERSONAL A TRAVÉS DE LA INTERACCIÓN MÓVIL REACTIVA"

***

**Autor:** [Tu Nombre y Apellidos]  
**Tutor:** [Nombre del Tutor/a]  
**Fecha:** [Año / Convocatoria]  

***
<!-- PÁGINA 2 -->
\newpage

### AGRADECIMIENTOS
A mi familia, por su apoyo incondicional durante todo el transcurso de mis estudios de Formación Profesional y por infundir en mí la perseverancia para culminar este proyecto.

A mi tutor/a de Proyecto de Fin de Ciclo, por su valiosa orientación técnica, su paciencia y sus oportunas correcciones a lo largo del diseño e implementación del software.

A mis compañeros de ciclo formativo, con quienes compartí largas noches de laboratorio, discusiones de código y aprendizajes que perdurarán más allá de las aulas.

***

### RESUMEN
El presente Proyecto de Fin de Ciclo documenta el diseño, la arquitectura y el desarrollo de **Streaks**, una aplicación móvil multiplataforma orientada al seguimiento de hábitos cotidianos enriquecida mediante un componente de interacción social y gamificación en tiempo real. La proliferación de herramientas de productividad a menudo carece de un factor determinante para la adherencia a largo plazo: el refuerzo social. Streaks solventa esta carencia integrando un feed de publicaciones visuales de progreso diario con mecanismos avanzados de interacción gestual.

El desarrollo del software se apoya en el framework **Flutter** y el lenguaje **Dart**, adoptando los principios de la **Clean Architecture** (Arquitectura Limpia) para segregar rigurosamente la lógica de negocio de la infraestructura. La gestión del estado se articula mediante el framework **Riverpod**, garantizando la inmutabilidad y la inyección de dependencias segura en tiempo de compilación. Como backend, se emplea la suite de servicios en la nube de **Firebase** (Firestore, Authentication y Storage), ofreciendo sincronización de datos fluida en tiempo real basada en flujos de datos (*streams*). Entre las aportaciones técnicas de este proyecto destaca la implementación de gestos táctiles contextuales de alta fidelidad, como la detección geométrica de colisiones en pantalla para la barra flotante de interacción (mecanismo *drag-to-like*), así como una arquitectura de persistencia resiliente frente a limitaciones de redes o errores del servidor de identidad.

**Palabras clave:** Flutter, Dart, Clean Architecture, Riverpod, NoSQL, Firestore, Gamificación, Productividad, Interacción Gestual, Mobile Dev.

***

### ABSTRACT
This final vocational training project documents the design, architecture, and development of **Streaks**, a cross-platform mobile application tailored for tracking daily habits, enhanced through a real-time social interaction and gamification framework. The proliferation of digital productivity tools often lacks a decisive factor for long-term user adherence: social reinforcement. Streaks addresses this limitation by merging a visual feed of daily progress with advanced gestural interaction mechanisms.

The software development is built on the **Flutter** framework and **Dart** language, incorporating **Clean Architecture** guidelines to decouple business logic from infrastructure. State management is organized via **Riverpod**, ensuring state immutability and compile-time safe dependency injection. A cloud-native backend is achieved using **Firebase** (Firestore, Authentication, and Storage), providing real-time data sync through reactive streams. Key technical contributions of this project include high-fidelity contextual gestures, such as screen collision geometry algorithms for the floating interaction bar (the *drag-to-like* mechanism), as well as a resilient data persistence workflow designed to handle network limitations or identity server errors.

**Keywords:** Flutter, Dart, Clean Architecture, Riverpod, NoSQL, Firestore, Gamification, Productivity, Gestural Interaction, Mobile Dev.

***
<!-- PÁGINA 3 -->
\newpage

## ÍNDICE GENERAL

* **CAPÍTULO 1: INTRODUCCIÓN Y OBJETIVOS** .............................................................. Págs. 4 - 8
  * 1.1 Contexto y Motivación del Proyecto ................................................................ Pág. 4
  * 1.2 Planteamiento del Problema ........................................................................... Pág. 5
  * 1.3 Objetivos Generales y Específicos ................................................................... Pág. 6
  * 1.4 Alcance y Límites del Proyecto ........................................................................ Pág. 7
  * 1.5 Metodología de Desarrollo Adoptada ................................................................ Pág. 8
    * 1.5.1 Planificación Temporal y Asignación de Horas (Gantt) ................................. Pág. 8
* **CAPÍTULO 2: ESTADO DEL ARTE Y MARCO TECNOLÓGICO** .................................. Págs. 9 - 15
  * 2.1 Ecosistemas Móviles: Nativo vs. Multiplataforma .............................................. Pág. 9
  * 2.2 Estudio del Ecosistema de Flutter y Dart ......................................................... Pág. 10
  * 2.3 Paradigmas de Gestión de Estado: Riverpod, Provider y BLoC ......................... Pág. 12
  * 2.4 Análisis del Backend: Arquitecturas Servidor Propias vs. BaaS (Firebase) ........ Pág. 14
* **CAPÍTULO 3: ANÁLISIS DE REQUISITOS Y MODELADO** ........................................... Págs. 16 - 23
  * 3.1 Especificación de Requisitos Funcionales y No Funcionales ............................... Pág. 16
  * 3.2 Diagramas de Casos de Uso y Escenarios Críticos ............................................ Pág. 18
  * 3.3 Diseño de Base de Datos NoSQL: Modelo de Documentos y Subcolecciones ... Pág. 20
  * 3.4 Reglas de Seguridad e Integridad en el Almacenamiento en la Nube ................ Pág. 22
* **CAPÍTULO 4: DISEÑO DEL SISTEMA Y ARQUITECTURA** ........................................... Págs. 24 - 32
  * 4.1 Principios de Clean Architecture Aplicados en Flutter ...................................... Pág. 24
  * 4.2 Desacoplamiento de Módulos: Capas de Presentación, Dominio y Datos ........... Pág. 26
  * 4.3 Flujo de Datos Unidireccional y Gestión Inmutable de Estado ............................. Pág. 29
  * 4.4 Inyección de Dependencias Mediante Riverpod Providers ................................... Pág. 31
* **CAPÍTULO 5: IMPLEMENTACIÓN DE MÓDULOS CRÍTICOS** ........................................... Págs. 33 - 43
  * 5.1 Algoritmo de Detección de Colisiones Geométricas para Gestos Táctiles .......... Pág. 33
  * 5.2 Filtros Reactivos en Cliente para Relaciones Dirigidas de Seguidores .............. Pág. 38
  * 5.3 Lógica Resiliente de Sincronización de Perfiles y Autenticación ......................... Pág. 41
* **CAPÍTULO 6: PLAN DE PRUEBAS Y VALIDACIÓN** ................................................... Págs. 44 - 47
  * 6.1 Estrategia de Pruebas Unitarias y de Componentes Visuales ............................. Pág. 44
  * 6.2 Benchmarking de Rendimiento y Consumo de Recursos del Motor Impeller ...... Pág. 46
* **CAPÍTULO 7: CONCLUSIÓN Y TRABAJO FUTURO** .................................................... Págs. 48 - 50
  * 7.1 Evaluación del Cumplimiento de los Objetivos Propuestos ................................. Pág. 48
  * 7.2 Viabilidad Económica y Costes Estimados del Despliegue ................................. Pág. 49
    * 7.2.3 Presupuesto de Desarrollo Inicial y Amortización ........................................... Pág. 49
  * 7.3 Hoja de Ruta e Innovaciones del Trabajo Futuro ............................................. Pág. 50
  * 7.4 Bibliografía y Webgrafía ..................................................................................... Pág. 50
* **ANEXO: MANUALES DE USUARIO Y DESPLIEGUE** .................................................. Pág. 51
  * A.1 Manual de Usuario ............................................................................................ Pág. 51
  * A.2 Manual de Despliegue e Instalación .................................................................. Pág. 53
  * A.3 Galería de Capturas de Pantalla de la Interfaz y Funcionamiento .................... Pág. 55

---

## ÍNDICE DE FIGURAS
* **Figura 1.1**: Diagrama General de Capas de Clean Architecture en Flutter .................... Pág. 24
* **Figura 2.1**: Flujo Unidireccional del Estado mediante Riverpod y UI ............................ Pág. 29
* **Figura 3.1**: Diagrama de Flujo del Algoritmo del Gesto Drag-to-Like ............................ Pág. 34
* **Figura 3.2**: Esquema de Detección de Colisiones con Cajas Geométricas ..................... Pág. 36
* **Figura 4.1**: Esquema Entidad-Relación NoSQL de Documentos de Firestore ................... Pág. 21
* **Figura 5.1**: Diagrama de Gantt del Cronograma del Proyecto ........................................ Pág. 8
* **Figura A.1**: Panel de Perfil de Usuario y Configuración del Sistema ........................... Pág. 51
* **Figura A.2**: Formulario Reactivo para la Creación de Hábitos ....................................... Pág. 51
* **Figura A.3**: Feed Social Interactivo con Publicaciones del Usuario ............................... Pág. 52
* **Figura A.4**: Vista del Calendario Horizontal con Historial Semanal ............................. Pág. 52
* **Figura A.5**: Pantalla de Adición y Configuración de un Nuevo Hábito ........................... Pág. 55
* **Figura A.6**: Barra Superior del Calendario Reactivo e Historial ................................... Pág. 55
* **Figura A.7**: Listado de Publicaciones de Usuarios en Tiempo Real ............................. Pág. 56
* **Figura A.8**: Vista de Perfil Personal y Lista de Ajustes ................................................ Pág. 56
* **Figura A.9**: Vista de un Perfil Ajeno con Acciones Sociales ........................................ Pág. 56
* **Figura A.10**: Pantalla de Captura y Gestión de Errores de Aserción ............................. Pág. 57

---

## ÍNDICE DE TABLAS
* **Tabla 1.1**: Comparativa General de Frameworks Móviles Multiplataforma ...................... Pág. 9
* **Tabla 2.1**: Tabla de Requisitos Funcionales del Sistema .............................................. Pág. 16
* **Tabla 2.2**: Tabla de Requisitos No Funcionales de Streaks ............................................ Pág. 17
* **Tabla 3.1**: Costes Mensuales Estimados de la Infraestructura en Google Cloud .............. Pág. 49
* **Tabla 3.2**: Planificación de Horas por Fases y Sprints .................................................. Pág. 8
* **Tabla 3.3**: Amortización de Hardware y Recursos Tecnológicos ...................................... Pág. 49
* **Tabla 3.4**: Presupuesto Económico Consolidado ............................................................. Pág. 49
