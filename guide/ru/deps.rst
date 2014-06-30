Зависимости
===========

Библиотеки
----------

Xitrum использует некоторые библиотеки. Вы можете использовать их напрямую
если захотите.

.. image:: ../img/deps.png

Главные зависимости:

* `Scala <http://www.scala-lang.org/>`_:
  Xitrum написан на языке программирования Scala.
* `Netty <https://netty.io/>`_:
  В качестве асинхронного HTTP(S) сервера.
  Многие возможности Xitrum используют Netty,
  например WebSocket и zero copy.
* `Akka <http://akka.io/>`_:
  Для SockJS. Akka зависит от `Typesafe Config <https://github.com/typesafehub/config>`_,
  который так же используется в Xitrum.

Другие зависимости:

* `Commons Lang <http://commons.apache.org/lang/>`_:
  Для экранирования JSON данных.
* `Glokka <https://github.com/xitrum-framework/glokka>`_:
  Для кластеризация акторов SockJS.
* `JSON4S <https://github.com/json4s/json4s>`_:
  Для разбора и генерации JSON данных. JSON4S зависит от
  `Paranamer <http://paranamer.codehaus.org/>`_.
* `Rhino <https://developer.mozilla.org/en-US/docs/Rhino>`_:
  В Scalate для компиляции CoffeeScript в JavaScript.
* `Sclasner <https://github.com/xitrum-framework/sclasner>`_:
  Для поиска HTTP маршрутов в контроллерах, .class и .jar файлах.
* `Scaposer <https://github.com/xitrum-framework/scaposer>`_:
  Для интернационализации.
* `Twitter Chill <https://github.com/twitter/chill>`_:
  Для сериализации и десериализации куки и сессий.
  Chill базируется на `Kryo <http://code.google.com/p/kryo/>`_.
* `SLF4S <http://slf4s.org/>`_, `Logback <http://logback.qos.ch/>`_:
  Для логирования.

`Шаблон пустого проекта Xitrum <https://github.com/xitrum-framework/xitrum-new>`_
включает утилиты:

* `scala-xgettext <https://github.com/xitrum-framework/scala-xgettext>`_:
  :doc:`Извелечение сообщений </i18n>` из .scala файлов во время компиляции.
* `xitrum-package <https://github.com/xitrum-framework/xitrum-package>`_:
  Для :doc:`подготовки проекта к развертыванию </deploy>` на сервере.
* `Scalive <https://github.com/xitrum-framework/scalive>`_:
  Для подключения Scala консоли к JVM процессу для живой отладки.

Связанные проекты
-----------------

Демо проекты:

* `xitrum-new <https://github.com/xitrum-framework/xitrum-new>`_:
  Шаблон пустого проекта Xitrum.
* `xitrum-demos <https://github.com/xitrum-framework/xitrum-demos>`_:
  Демонстрационный проект возможностей Xitrum.
* `xitrum-placeholder <https://github.com/xitrum-framework/xitrum-placeholder>`_:
  Демонстрационный проекта RESTful API который возвращает изображения.
* `comy <https://github.com/xitrum-framework/comy>`_:
  Демонстрационный проект: короткие ссылки.
* `xitrum-multimodule-demo <https://github.com/xitrum-framework/xitrum-multimodule-demo>`_:
  Пример мульти модульного `SBT <http://www.scala-sbt.org/>`_ проекта.

Проекты:

* `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_:
  Стандартный шаблонизатор для Xitrum, подключенный в
  `шаблонном проекте <https://github.com/xitrum-framework/xitrum-new>`_.
  Вы можете заменить его другим шаблонизатором, или вообще убрать если вам 
  не нужен шаблонизатор. Он зависит от
  `Scalate <http://scalate.fusesource.org/>`_ и
  `Scalamd <https://github.com/chirino/scalamd>`_.
* `xitrum-hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_:
  Для кластеризации кэша и сессии на стороне сервера.
* `xitrum-ko <https://github.com/xitrum-framework/xitrum-ko>`_:
  Предоставляет дополнительные возможности для `Knockoutjs <http://knockoutjs.com/>`_.

Другие проекты:

* `xitrum-doc <https://github.com/xitrum-framework/xitrum-doc>`_:
  Исходный код `учебника Xitrum <http://xitrum-framework.github.io/guide/en/index.html>`_.
* `xitrum-hp <https://github.com/xitrum-framework/xitrum-framework.github.io>`_:
  Исходный код `домашней страниц Xitrum <http://xitrum-framework.github.io/>`_.
