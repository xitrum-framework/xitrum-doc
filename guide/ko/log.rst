로그
====

xitrum.Log 오브젝트를 바로 사용하기
-------------------------------------

어디서든지, 다음과 같이 직접 호출할 수 있습니다.

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

xitrum.Log trait 사용하기
--------------------------------

만약, 로그가 사용된 위치(클래스)를 알고 싶다면, xitrum.log를 확장하면 됩니다.

::

  package my_package
  import xitrum.Log

  object MyModel extends Log {
    log.debug("My debug msg")
    log.info("My info msg")
    ...
  }

``log/xitrum.log`` 파일에서  ``MyModel`` 로 부터 나오는 로그 메세지를 확인할 수 있습니다

Xitrum 액션은 xitrum.Log를 확장하고 있어서, 어느 액션에서도 다음과 같이 사용할 수 있습니다.

::

  log.debug("Hello World")

로깅하기 전에 로그레벨을 체크하지 않아도 됩니다
----------------------------------------

``xitrum.Log`` 는 `SLF4S <http://slf4s.org/>`_ (`API <http://slf4s.org/api/1.7.7/>`_) 를 바탕으로 합니다,
SLF4S `SLF4J <http://www.slf4j.org/>`_ 위에 구축되어 있습니다.

전통적으로, 로그 결과를 확인하기 전에 계산으로 인한 과도한 CPU사용을 방지하기 위해, 로그레벨을 체크하였지만
`SLF4S의 자동체크 <https://github.com/mattroberts297/slf4s/blob/master/src/main/scala/org/slf4s/Logger.scala>`_ 기능이 있어서
일부러 체크 할 필요가 없습니다.


이전버전 (이 코드는 3.13 이후로는 동작하지 않습니다):

::

  if (log.isTraceEnabled) {
    val result = heavyCalculation()
    log.trace("Output: {}", result)
  }

현재:

::

  log.trace(s"Output: #{heavyCalculation()}")

로그레벨 및 출력파일 조정 
-------------------

build.sbt 파일에 다음과 같은 라인이 있습니다:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.1.2"

이것의 의미는 `Logback <http://logback.qos.ch/>`_ 을 기본으로 사용한다는 뜻입니다.
Logback의 설정파일은  ``config/logback.xml`` 에 있습니다.

Logback을 `SLF4J <http://www.slf4j.org/>`_ 으로 교체 할 수도 있습니다.


Fluentd 에 로그를 출력
--------------------

매우 대중적인 `Fluentd <http://www.fluentd.org/>`_ 로그 수집장치가 있습니다.
Logback을 수정하여 로그를 Fluentd 서버로 전송(여러곳에서 전송된)할 수 있습니다.

먼저, `logback-more-appenders <https://github.com/sndyuk/logback-more-appenders>`_ 라이브러리를 추가합니다:

::

  libraryDependencies += "org.fluentd" % "fluent-logger" % "0.2.11"

  resolvers += "Logback more appenders" at "http://sndyuk.github.com/maven"

  libraryDependencies += "com.sndyuk" % "logback-more-appenders" % "1.1.0"

그리고 ``config/logback.xml`` 파일을 수정합니다:

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
