Dependencies
============

Dependency libraries
--------------------

Xitrum includes some libraries. In your Xitrum project, you can use them
directly if you want.

.. image:: ../img/deps.png

Main dependencies:

* `Scala <http://www.scala-lang.org/>`_:
  Xitrum is written in Scala language.
* `Netty <https://netty.io/>`_:
  For async HTTP(S) server. Many features in Xitrum are based on those in Netty,
  like WebSocket and zero copy file serving.
* `Akka <http://akka.io/>`_:
  For SockJS. Akka depends on `Typesafe Config <https://github.com/typesafehub/config>`_,
  which is also used by Xitrum.

Other dependencies:

* `Commons Lang <http://commons.apache.org/lang/>`_:
  For escaping JSON data.
* `Glokka <https://github.com/xitrum-framework/glokka>`_:
  For clustering SockJS actors.
* `JSON4S <https://github.com/json4s/json4s>`_:
  For parsing and generating JSON data. JSON4S depends on
  `Paranamer <http://paranamer.codehaus.org/>`_.
* `Rhino <https://developer.mozilla.org/en-US/docs/Rhino>`_:
  For Scalate to compile CoffeeScript to JavaScript.
* `Sclasner <https://github.com/xitrum-framework/sclasner>`_:
  For scanning HTTP routes in action classes in .class and .jar files.
* `Scaposer <https://github.com/xitrum-framework/scaposer>`_:
  For i18n.
* `Twitter Chill <https://github.com/twitter/chill>`_:
  For serializing and deserializing cookies and sessions.
  Chill is based on `Kryo <http://code.google.com/p/kryo/>`_.
* `SLF4S <http://slf4s.org/>`_, `Logback <http://logback.qos.ch/>`_:
  For logging.

`Xitrum new project skeleton <https://github.com/xitrum-framework/xitrum-new>`_
includes these tools:

* `scala-xgettext <https://github.com/xitrum-framework/scala-xgettext>`_:
  For :doc:`extracting i18n strings </i18n>` from your .scala files when you compile them.
* `xitrum-package <https://github.com/xitrum-framework/xitrum-package>`_:
  For :doc:`packaging your project </deploy>`, ready to deploy to production server.
* `Scalive <https://github.com/xitrum-framework/scalive>`_:
  For connecting a Scala console to a running JVM process for live debugging.

Related projects
----------------

Demos:

* `xitrum-new <https://github.com/xitrum-framework/xitrum-new>`_:
  Xitrum new project skeleton.
* `xitrum-demos <https://github.com/xitrum-framework/xitrum-demos>`_:
  Demos features in Xitrum.
* `xitrum-placeholder <https://github.com/xitrum-framework/xitrum-placeholder>`_:
  Demos APIs that return images.
* `comy <https://github.com/xitrum-framework/comy>`_:
  Demos a simple URL shortening service.
* `xitrum-multimodule-demo <https://github.com/xitrum-framework/xitrum-multimodule-demo>`_:
  Example about creating multimodule `SBT <http://www.scala-sbt.org/>`_ project.

Plugins:

* `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_:
  This is the default template engine in Xitrum, preconfigured in
  `Xitrum new project skeleton <https://github.com/xitrum-framework/xitrum-new>`_.
  You can replace it with other template engines, or totally remove it if your
  project doesn't need any template engine. It depends on
  `Scalate <http://scalate.fusesource.org/>`_ and
  `Scalamd <https://github.com/chirino/scalamd>`_.
* `xitrum-hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_:
  For clustering cache and server side sessions.
* `xitrum-ko <https://github.com/xitrum-framework/xitrum-ko>`_:
  Provides some convenient helpers for `Knockoutjs <http://knockoutjs.com/>`_.

Other projects:

* `xitrum-doc <https://github.com/xitrum-framework/xitrum-doc>`_:
  Source code of the `Xitrum Guide <http://xitrum-framework.github.io/guide/en/index.html>`_.
* `xitrum-hp <https://github.com/xitrum-framework/xitrum-framework.github.io>`_:
  Source code of the `Xitrum Homepage <http://xitrum-framework.github.io/>`_.
