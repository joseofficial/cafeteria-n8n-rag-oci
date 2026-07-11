# ☕ SoftKafe AI Agent - Challenge Alura

## 📖 Descripción General del Proyecto
Este proyecto es un Agente de Inteligencia Artificial Autónomo desarrollado como solución final para el "Challenge Alura Agente". Actúa como el asistente virtual oficial de **SoftKafe**, una cafetería de especialidad. 

El agente no es un simple chatbot de preguntas y respuestas; tiene la capacidad operativa de gestionar la atención al cliente de principio a fin operando directamente desde Telegram. Puede leer el menú en formato PDF utilizando técnicas RAG (Retrieval-Augmented Generation), mantener el contexto de la conversación, y utilizar herramientas externas de forma autónoma para agendar, modificar y cancelar reservas de mesas, guardando los datos estructurados en una base de datos relacional y programando eventos en Google Calendar.

## 🏗️ Arquitectura de la Solución
La solución está construida sobre una arquitectura de flujos de trabajo basados en nodos (n8n), alojada en la nube, y dividida en tres motores principales:

1. **Motor de Ingestión RAG (Flujo 1):** Procesa el documento PDF del menú y las reglas de la cafetería, lo divide en fragmentos (chunks), los convierte en vectores (Embeddings) y los almacena en PostgreSQL utilizando la extensión `pgvector`.
2. **Cerebro y Orquestador (Flujo 2):** Un agente inteligente (OpenAI) conectado a Telegram. Utiliza memoria persistente en base de datos (`Postgres Chat Memory`) e invoca herramientas dinámicas (Function Calling) para:
   * Buscar similitudes semánticas en el menú.
   * Ejecutar sentencias SQL (`INSERT`, `UPDATE`, `DELETE`) para la gestión del CRUD de reservas.
   * Conectarse mediante OAuth2 a la API de Google Calendar para reflejar las citas.
3. **Cron Job Notificador (Flujo 3):** Un proceso automatizado diario que cruza husos horarios, consulta la base de datos por los clientes que tienen reservas al día siguiente, y les envía un recordatorio proactivo por Telegram.

## 🛠️ Tecnologías y Herramientas Utilizadas
* **n8n (Self-Hosted):** Plataforma de automatización y orquestación del flujo y del Agente de IA.
* **Docker:** Utilizado para la contenerización del entorno, asegurando que n8n y la base de datos se ejecuten de manera aislada, consistente y fácilmente replicable.
* **Terraform:** Herramienta de Infraestructura como Código (IaC) empleada para aprovisionar y gestionar los recursos de forma automatizada y versionada.
* **Oracle Cloud Infrastructure (OCI):** Servidor en la nube donde se encuentra desplegada la solución en producción.
* **PostgreSQL + pgvector:** Base de datos principal utilizada tanto como Vector Store (almacenamiento semántico) como Base de Datos Relacional (gestión de reservas e historiales de chat).
* **OpenAI API (gpt-4o-mini):** Modelo de Lenguaje de Gran Escala (LLM) principal que actúa como el cerebro del agente y orquestador de herramientas.
* **Google Gemini API:** Modelo utilizado para la generación de Embeddings del RAG.
* **Telegram Bot API:** Interfaz de usuario (Front-end) para la interacción con los clientes.
* **Google Calendar API:** Plataforma de visualización operativa para la administración de la cafetería.

## 🛠️ Evidencias de Deploy en OCI
* **Enlace de la aplicación:** http://137.131.183.37:5678
* **Enlace de la aplicación autofirmado temporal por cloudflare:** https://descending-sporting-billing-internationally.trycloudflare.com/home/workflows
* **Observación:** Se utiliza de esta forma porque Telegram por motivo de seguridad necesita responder a enlaces seguras firmados.
## 🚀 Instrucciones para ejecutar el proyecto

### Prerrequisitos:
* Una instancia activa de n8n.
* Una base de datos PostgreSQL con la extensión `pgvector` habilitada.
* Tokens de acceso para: Telegram Bot, OpenAI, Gemini y Credenciales OAuth2 de Google.

### Pasos de Instalación:
1. Clonar este repositorio.
2. Ejecutar los scripts SQL proporcionados en los comentarios del código para crear las tablas `reservas` y `n8n_chat_histories` en PostgreSQL.
3. Importar los archivos `.json` ubicados en la carpeta `flujos` dentro de tu instancia de n8n.
4. Configurar y autenticar las credenciales dentro de n8n para PostgreSQL, OpenAI, Gemini, Telegram y Google Calendar.
5. Ejecutar manualmente el **Flujo 1** una sola vez para ingestar el documento fuente en la base de datos vectorial.
6. Activar (Toggle a *Active*) el **Flujo 2** y el **Flujo 3**.
7. ¡El bot ya está listo para recibir mensajes en Telegram!

## 💬 Ejemplos de Interacción del Agente

A continuación, se muestran ejemplos reales de cómo el Agente entiende la intención del usuario y decide usar diferentes herramientas:

**Ejemplo 1: Búsqueda de información (RAG)**
> **Usuario:** ¿Qué opciones de café frío tienen y cuáles son sus precios?
> **Agente:** ¡Hola! En SoftKafe tenemos estas deliciosas opciones para refrescarte:
> • Iced Latte - $4.00
> • Cold Brew - $4.50
> • Frappuccino de Mocha - $5.00
> ¿Te gustaría que te agende una mesa para venir a probarlos?

**Ejemplo 2: Agendamiento y ejecución de Tools**
> **Usuario:** Quiero agendar una mesa para mañana a las 15:00 para 4 personas por favor. Mi nombre es Carlos.
> **Agente:** *(Ejecuta las herramientas registra_agendamiento y registra_calendario de forma paralela)* > ¡Listo, Carlos! Tu reserva para 4 personas ha sido confirmada para mañana a las 15:00 horas. Te esperamos en SoftKafe. ☕

**Ejemplo 3: Edición y contexto de Memoria**
> **Usuario:** Oye, respecto a mi reserva de mañana, ¿puedes cambiarla para 6 personas en lugar de 4?
> **Agente:** *(Lee el ID de Telegram y busca la reserva original para hacer el UPDATE)*
> ¡Claro que sí, Carlos! He modificado tu reserva de mañana a las 15:00 y ahora está lista para 6 personas. ¡Nos vemos!

## ☁️ Evidencia del Deploy en OCI
El bot se encuentra en producción y puede ser probado en este enlace:
🔗 https://t.me/alurasbot

*Puedes visualizar la evidencia gráfica del servidor corriendo y las pruebas de bases de datos en la carpeta `/evidencias` de este repositorio.*