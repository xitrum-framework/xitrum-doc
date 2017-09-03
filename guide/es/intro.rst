Introduction
============

::

  +--------------------+
  |      Clients       |
  +--------------------+
            |
  +--------------------+
  |       Netty        |
  +--------------------+
  |       Xitrum       |
  | +----------------+ |
  | | HTTP(S) Server | |
  | |----------------| |
  | | Web framework  | |  <- Akka, Hazelcast -> Otras instancias
  | +----------------+ |
  +--------------------+
  |   Tu aplicación    |
  +--------------------+

Xitrum es un framework web de scala, asíncrono y agrupable (clustered), provee fusión de server HTTP(s)
que se ejecuta sobre `Netty <http://netty.io/>`_ y `Akka <http://akka.io/>`_.

Dicho por `un usuario <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_:

  Wow, este es un cuerpo de trabajo realmente impresionante, posiblemente el mas completo
  framework de scala, a parte de Lift (pero mucho mas fácil de utilizar).

  `Xitrum <http://xitrum-framework.github.io/>`_ es realemente un framework web full stack,
  Todos los principios están cubierno, incluyendo el WTF-am-I-on-the-moon(Que demonios, estoy en la luna),
  con extras como ETags, identificadores de caché de archivos estáticos y
  compresión de automática en gzip. Seguimiento en el convertidor JSON incorporado,
  intersecciones antes/durante/después, de los siguientes ámbitos request/session/cookie/flash,
  Validación integrada (servidor & lado del cliente, bonita), capa de caché
  incorporada (`Hazelcast <http://www.hazelcast.org/>`_), i18n GNU gettext, Netty (con Nginx, hello,
  realmente rápido), etc. y te quedas como que, wow.

Características
--------

* Typesafe, en la esencia de Scala. Todas las APIs tratan de ser, lo mas posible como typesafe.
* Async, en la esencia Netty. Tu consulta al procesar una acción no tiene que
  responder inmediatamente. Largo polling, respuestas por partes (streaming), WebSocket,
  y SockJS son soportados.
* Rápida construcción HTTP y HTTPS servidor web basado en `Netty <http://netty.io/>`_
  (HTTPS puede user el engine de java o el engine nativo OpenSSL).
  El servir archivos estáticos en Xitrum tiene una velocidad `similar a esta de Nginx <https://gist.github.com/3293596>`_.
* Caché extensivo del lado del cliente y el servidor para respuestas rápidas.
  En el lado de servidor, los archivos pequeños son cacheados en memoria, y los archivos grande son
  enviados usando el "zero copy" de NIO.
  En la capa de framework web, tu puede declarar página, acciçon, y caché de objeto
  al estilo de Rails.
  `Todas las mejores práctigas de google <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_
  como los GET condicionales que son aplicados por la caché del lado del cliente.
  También puede forzar los navegadores para que siempre envié un request al servidor para revalidar la caché antes usarla.
* `Rango de consultas <http://en.wikipedia.org/wiki/Byte_serving>`_ soportadas
  para archivos estáticos. Servir archivos de vídeos para smartphones requiere esta característica.
  Tu puede pausar/readninar la descarga de archivos.
* `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_ soportado.
* Las rutas son automáticamente recolectadas por JAX-RS
  y Rails Engines. No tienes que declarar todas las rutas en un solo luar.
  Esta carácterística fué pensada como rutas distribuidas. Tu puedes conectar una aplicación dentro de otra.
  ¡Si tu tienes un motor de un blog, tu puede empaquetar esto dentro de un archivo JAR, entonces podrás meter
  ese archivo JAR dentro de otra aplicación y esa aplicación automáticamente tendrá ese motor de blog!
  El routing se puede definir de dos formas: tu puedes regresar las URLs ruta invesa(reverse routing) en una forma typesafe.
  Tu puedes documentar rutas usando `Swagger Doc <http://swagger.wordnik.com/>`_.
* Las clases y rutas son automáticamente recargadas en el modo de desarrollador.
* Las vistas pueden ser escrits por separado usando un archivo template
  `Scalate <http://scalate.fusesource.org/>`_  o en Scala inline XML. Ambos son typesafe.
* Sessiones, pueden ser almacenada en cookies (mas escalable) o en un cluster de `Hazelcast <http://www.hazelcast.org/>`_ (mas seguro).
  Hazelcast también proporciona caché distibuída in-process (así de rápido y fácil de usar).
  Tu no tienes que separar los servidores de caché. lo mísmo para la característica pubsub (publición/subscipción) en Akka.
* `La validación de jQuery <http://jqueryvalidation.org/>`_ es integrada para el lado del navegador y
  validación del lado del servidor.
* i18n usando `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_.
  La extracción de textos de traducción es hecha automáticamente.
  Tu notiees que lidiar manualmente con un archivo de propiedades.
  Puedes usar herramientas poderosas como `Poedit <http://www.poedit.net/screenshots.php>`_
  para traducción y combinar traducciones.
  gettext no es como la mayoría de soluciones, ambas formas, singulares y plural son soportadas.

Xitrum trata de cubrir el espacio entre `Scalatra <https://github.com/scalatra/scalatra>`_
y `Lift <http://liftweb.net/>`_: mas poderoso que Scalatra y mas fácil de usar
que Lift. Puedes crear fácilmente APIs RESTful y postbacks (petición de post a la misma página del formulario). `Xitrum <http://xitrum-framework.github.io/>`_
es primero-controlador como Scalatra, no
`primero-vista <http://www.assembla.com/wiki/show/liftweb/View_First>`_ como en Lift.
Muchas personas están familiarizadas con el estilo primero-controlador.

Ver :doc:`Proyectos relacionados </deps>` para una lista de demos, plugins y mas.

Contribuidores.
------------

`Xitrum <http://xitrum-framework.github.io/>`_ es `open source <https://github.com/xitrum-framework/xitrum>`_,
Por favor, únete a nuestro `grupo de Google <http://groups.google.com/group/xitrum-framework>`_.

Contributors are listed in the order of their
`first contribution <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_.

(*): Miembros del core actualmente activos.

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/earldouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
