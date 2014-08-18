Логирование
===========

Использование объекта xitrum.Log
--------------------------------

Везде вы можете использовать напрямую:

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

Использование трейта xitrum.Log
-------------------------------

Если вам важно сообщать дополнительную информацию о том какой класс генерирует
информационные сообщения, используйте наследование он xitrum.Log

::

  package my_package
  import xitrum.Log

  object MyModel extends Log {
    log.debug("My debug msg")
    log.info("My info msg")
    ...
  }

В файле log/xitrum.log вы увидите сообщение ``MyModel``.

Контролеры Xitrum наследуют xitrum.Log и предоставляют метод ``log``.
В любом контроллере вы можете писать:

::

  log.debug("Hello World")

Проверка уровня логирования
---------------------------

``xitrum.Log`` основан на `SLF4S <http://slf4s.org/>`_ (`API <http://slf4s.org/api/1.7.7/>`_),
который в свою очередь на `SLF4J <http://www.slf4j.org/>`_.

Обычно, перед выполнением сложных вычислений которые будут отправлены в лог, выполняют
проверку уровня логирования что бы избежать не нужных вычислений.

`SLF4S автоматически выполняет эти проверки <https://github.com/mattroberts297/slf4s/blob/master/src/main/scala/org/slf4s/Logger.scala>`_,
поэтому нет нужды их выполнять самому.

До Xitrum 3.13+:

::

  if (log.isTraceEnabled) {
    val result = heavyCalculation()
    log.trace("Output: {}", result)
  }

Теперь:

::

  log.trace(s"Output: #{heavyCalculation()}")

Настройка уровня и способов логирования
---------------------------------------

В build.sbt есть строчка:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.1.2"

Что означает использовать `Logback <http://logback.qos.ch/>`_.
Конфигурационный файл Logback - ``config/logback.xml``.

Вы можете заменить Logback любой другой реализацией `SLF4J <http://www.slf4j.org/>`_.

Использование Fluentd
---------------------

`Fluentd <http://www.fluentd.org/>`_ очень популярная система сбора логов. Вы можете
настроить Logback так что бы отправлять логи (возможно из нескольких мест) на Fluentd сервер.

Первое, добавьте библиотеку `logback-more-appenders <https://github.com/sndyuk/logback-more-appenders>`_
в ваш проект:

::

  libraryDependencies += "org.fluentd" % "fluent-logger" % "0.2.11"

  resolvers += "Logback more appenders" at "http://sndyuk.github.com/maven"

  libraryDependencies += "com.sndyuk" % "logback-more-appenders" % "1.1.0"

Затем исправьте конфигурацию ``config/logback.xml``:

::

  ...

  <appender name="FLUENT" class="ch.qos.logback.more.appenders.DataFluentAppender">
    <tag>mytag</tag>
    <label>mylabel</label>
    <remoteHost>localhost</remoteHost>
    <port>24224</port>
    <maxQueueSize>20000</maxQueueSize>  <!-- Позволяет экономить память если сервер выключен -->
  </appender>

  <root level="DEBUG">
    <appender-ref ref="FLUENT"/>
    <appender-ref ref="OTHER_APPENDER"/>
  </root>

  ...
