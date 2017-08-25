Log
===

Use object xitrum.Log directly
------------------------------

From anywhere, you can call like this directly:

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

Use trait xitrum.Log
--------------------

If you want to have the information about where (which class) the log has been
made, you should extend trait xitrum.Log:

::

  package my_package
  import xitrum.Log

  object MyModel extends Log {
    log.debug("My debug msg")
    log.info("My info msg")
    ...
  }

In file log/xitrum.log you will see that the log messages comes from ``MyModel``.

Xitrum actions extend trait xitrum.Log, so in actions, you can do write:

::

  log.debug("Hello World")

Don't have to check log level before logging
--------------------------------------------

``xitrum.Log`` is based on `SLF4S <http://slf4s.org/>`_ (`API <http://slf4s.org/api/1.7.7/>`_),
which is in turn based on `SLF4J <http://www.slf4j.org/>`_.

Traditionally, before doing a heavy calculation to get a result to log, you have
to check log level to avoid wasting CPU to do the calculation.

`SLF4S automatically does the check <https://github.com/mattroberts297/slf4s/blob/master/src/main/scala/org/slf4s/Logger.scala>`_,
so you don't have to do the check yourself.

Before (this code doesn't work for the current Xitrum 3.13+ any more):

::

  if (log.isTraceEnabled) {
    val result = heavyCalculation()
    log.trace("Output: {}", result)
  }

Now:

::

  log.trace(s"Output: #{heavyCalculation()}")

Config log level, log output file etc.
--------------------------------------

In build.sbt, there's a line like this:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.1.2"

This means that `Logback <http://logback.qos.ch/>`_ is used by default.
Logback config file is at ``config/logback.xml``.

You may replace Logback with any other implementation of `SLF4J <http://www.slf4j.org/>`_.

Log to Fluentd
--------------

`Fluentd <http://www.fluentd.org/>`_ is a very popular log collector. You can
configure Logback to send log (maybe from many places) to a Fluentd server.

First, add `logback-more-appenders <https://github.com/sndyuk/logback-more-appenders>`_
library to your project:

::

  libraryDependencies += "org.fluentd" % "fluent-logger" % "0.2.11"

  resolvers += "Logback more appenders" at "http://sndyuk.github.com/maven"

  libraryDependencies += "com.sndyuk" % "logback-more-appenders" % "1.1.0"

Then, in ``config/logback.xml``:

::

  ...

  <appender name="FLUENT" class="ch.qos.logback.more.appenders.DataFluentAppender">
    <tag>mytag</tag>
    <label>mylabel</label>
    <remoteHost>localhost</remoteHost>
    <port>24224</port>
    <maxQueueSize>20000</maxQueueSize>  <!-- Save to memory when remote server is down -->
  </appender>

  <root level="DEBUG">
    <appender-ref ref="FLUENT"/>
    <appender-ref ref="OTHER_APPENDER"/>
  </root>

  ...
