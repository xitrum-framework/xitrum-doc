Dependencies
============

This chapter lists all dependency libraries that Xitrum uses so that in
your Xitrum project, you can use them directly if you want.

* `Scala <http://www.scala-lang.org/>`_:
   Xitrum is written in Scala language.
* `Netty <https://netty.io/>`_:
   For async HTTP(S) server. Many features in Xitrum are based on those in Netty,
   like WebSocket and zero copy file serving.
* `Hazelcast <http://hazelcast.com/>`_:
   For distributing caches, server side sessions, and message queues.
* `Akka <http://akka.io/>`_:
   For SockJS. Akka itself has this interesting dependency which is also used by Xitrum:
   `Typesafe Config <https://github.com/typesafehub/config>`_.
* `Scalate <http://scalate.fusesource.org/>`_, `Scalamd <https://github.com/chirino/scalamd>`_:
   For view template.
* `Rhino <https://developer.mozilla.org/en-US/docs/Rhino>`_:
   For Scalate to compile CoffeeScript to JavaScript.
* `JSON4S <https://github.com/json4s/json4s>`_:
   For parsing and generating JSON data.
* `Javassist <http://www.csg.ci.i.u-tokyo.ac.jp/~chiba/javassist/>`_, `Sclasner <https://github.com/ngocdaothanh/sclasner>`_:
   For scanning HTTP routes in controller classes in .class and .jar files.
* `Scaposer <https://github.com/ngocdaothanh/scaposer>`_:
   For i18n.
* `Commons Lang <http://commons.apache.org/lang/>`_:
   For escaping JSON data.
* `Twitter Chill <https://github.com/twitter/chill>`_:
   For serializing and deserializing cookies and sessions.
   Chill is based on
   `Kryo <http://code.google.com/p/kryo/>`_,
   `Objenesis <http://code.google.com/p/objenesis/>`_,
   `Bijection <https://github.com/twitter/bijection>`_,
   `ASM <http://asm.ow2.org/>`_,
   `Commons Codec <http://commons.apache.org/proper/commons-codec/>`_,
   `Paranamer <http://paranamer.codehaus.org/>`_,
   `ReflectASM <http://code.google.com/p/reflectasm/>`_,
   `Uncommons Maths <http://maths.uncommons.org/>`_.
* `SLF4J <http://www.slf4j.org/>`_, `Logback <http://logback.qos.ch/>`_:
   For logging.
