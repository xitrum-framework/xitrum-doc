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
  | | Web framework  | |  <- Akka, Hazelcast -> Other instances
  | +----------------+ |
  +--------------------+
  |      Your app      |
  +--------------------+

Xitrum is an async and clustered Scala web framework and HTTP(S) server fusion
on top of `Netty <http://netty.io/>`_ and `Akka <http://akka.io/>`_.

From `a user <https://groups.google.com/group/xitrum-framework/msg/d6de4865a8576d39>`_:

  Wow, this is a really impressive body of work, arguably the most
  complete Scala framework outside of Lift (but much easier to use).

  `Xitrum <http://xitrum-framework.github.io/>`_ is truly a full stack web framework, all the bases are covered,
  including wtf-am-I-on-the-moon extras like ETags, static file cache
  identifiers & auto-gzip compression. Tack on built-in JSON converter,
  before/around/after interceptors, request/session/cookie/flash scopes,
  integrated validation (server & client-side, nice), built-in cache
  layer (`Hazelcast <http://www.hazelcast.org/>`_), i18n a la GNU gettext, Netty (with Nginx, hello
  blazing fast), etc. and you have, wow.

Features
--------

* Typesafe, in the spirit of Scala. All the APIs try to be as typesafe as possible.
* Async, in the spirit of Netty. Your request proccessing action does not have
  to respond immediately. Long polling, chunked response (streaming), WebSocket,
  and SockJS are supported.
* Fast built-in HTTP and HTTPS web server based on `Netty <http://netty.io/>`_
  (HTTPS can use Java engine or native OpenSSL engine).
  Xitrum's static file serving speed is `similar to that of Nginx <https://gist.github.com/3293596>`_.
* Extensive client-side and server-side caching for faster responding.
  At the web server layer, small files are cached in memory, big files are sent
  using NIO's zero copy.
  At the web framework layer you have can declare page, action, and object cache
  in the Rails style.
  `All Google's best practices <http://code.google.com/speed/page-speed/docs/rules_intro.html>`_
  like conditional GET are applied for client-side caching.
  You can also force browsers to always send request to server to revalidate cache before using.
* `Range requests <http://en.wikipedia.org/wiki/Byte_serving>`_ support
  for static files. Serving movie files for smartphones requires this feature.
  You can pause/resume file download.
* `CORS <http://en.wikipedia.org/wiki/Cross-origin_resource_sharing>`_ support.
* Routes are automatically collected in the spirit of JAX-RS
  and Rails Engines. You don't have to declare all routes in a single place.
  Think of this feature as distributed routes. You can plug an app into another app.
  If you have a blog engine, you can package it as a JAR file, then you can put
  that JAR file into another app and that app automatically has blog feature!
  Routing is also two-way: you can recreate URLs (reverse routing) in a typesafe way.
  You can document routes using `Swagger Doc <http://swagger.wordnik.com/>`_.
* Classes and routes are automatically reloaded in development mode.
* Views can be written in a separate `Scalate <http://scalate.fusesource.org/>`_
  template file or Scala inline XML. Both are typesafe.
* Sessions can be stored in cookies (more scalable) or clustered `Hazelcast <http://www.hazelcast.org/>`_ (more secure).
  Hazelcast also gives in-process (thus faster and simpler to use) distribued cache,
  you don't need separate cache servers. The same is for pubsub feature in Akka.
* `jQuery Validation <http://jqueryvalidation.org/>`_ is integrated
  for browser side and server side validation.
* i18n using `GNU gettext <http://en.wikipedia.org/wiki/GNU_gettext>`_.
  Translation text extraction is done automatically.
  You don't have to manually mess with properties files.
  You can use powerful tools like `Poedit <http://www.poedit.net/screenshots.php>`_
  for translating and merging translations.
  gettext is unlike most other solutions, both singular and plural forms are supported.

Xitrum tries to fill the spectrum between `Scalatra <https://github.com/scalatra/scalatra>`_
and `Lift <http://liftweb.net/>`_: more powerful than Scalatra and easier to
use than Lift. You can easily create both RESTful APIs and postbacks. `Xitrum <http://xitrum-framework.github.io/>`_
is controller-first like Scalatra, not
`view-first <http://www.assembla.com/wiki/show/liftweb/View_First>`_ like Lift.
Most people are familliar with controller-first style.

See :doc:`related projects </deps>` for a list of demos, plugins etc.

Contributors
------------

`Xitrum <http://xitrum-framework.github.io/>`_ is `open source <https://github.com/xitrum-framework/xitrum>`_,
please join its `Google group <http://groups.google.com/group/xitrum-framework>`_.

Contributors are listed in the order of their
`first contribution <https://github.com/xitrum-framework/xitrum/graphs/contributors>`_.

(*): Currently active core members.

* `Ngoc Dao (*) <https://github.com/ngocdaothanh>`_
* `Linh Tran <https://github.com/alide>`_
* `James Earl Douglas <https://github.com/earldouglas>`_
* `Aleksander Guryanov <https://github.com/caiiiycuk>`_
* `Takeharu Oshida (*) <https://github.com/georgeOsdDev>`_
* `Nguyen Kim Kha <https://github.com/kimkha>`_
* `Michael Murray <https://github.com/murz>`_
