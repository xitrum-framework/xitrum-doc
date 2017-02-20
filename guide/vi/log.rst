Log
===

Sử dụng trực tiếp đối tượng xitrum.Log
--------------------------------------

Từ bất kỳ đâu, bạn có thể gọi một cách trực tiếp như sau:

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

Sử dụng trait xitrum.Log
------------------------

Nếu bạn muốn biết log tạo bởi class nào, bạn nên kế thừa trait xitrum.Log:

::

  package my_package
  import xitrum.Log

  object MyModel extends Log {
    log.debug("My debug msg")
    log.info("My info msg")
    ...
  }

Trong tệp log/xitrum.log bạn sẽ thấy log message đến từ ``MyModel``.

Xitrum action kế thừa trait xitrum.Log, vì thế trong action, bạn có thể viết:

::

  log.debug("Hello World")

Không phải kiểm tra log level trước khi log
-------------------------------------------

``xitrum.Log`` dựa trên `SLF4S <http://slf4s.org/>`_ (`API <http://slf4s.org/api/1.7.7/>`_),
``SLFS4`` lại được xây dựng trên `SLF4J <http://www.slf4j.org/>`_.

Thông thường, trước khi thực thi một phép tính lớn để log result, bạn phải kiểm tra log level
để hạn chế lãng phí CPU cho phép tính.

`SLF4S tự động thực hiện việc kiểm tra <https://github.com/mattroberts297/slf4s/blob/master/src/main/scala/org/slf4s/Logger.scala>`_,
do đó bạn không cần phải tự kiểm tra.

Trước đó (đoạn mã này không còn chạy với bản Xitrum hiện tại 3.13+):

::

  if (log.isTraceEnabled) {
    val result = heavyCalculation()
    log.trace("Output: {}", result)
  }

Hiện tại:

::

  log.trace(s"Output: #{heavyCalculation()}")

Cấu hình log level
------------------

Trong tệp build.sbt, có một dòng như sau:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.1.2"

Dòng này có nghĩa rằng : mặc định `Logback <http://logback.qos.ch/>`_ được sử dụng.
Tệp cấu hình Logback nằm tại ``config/logback.xml``.

Bạn có thể thay thế Logback bằng bất kì implementation nào khác của `SLF4J <http://www.slf4j.org/>`_.

Log vào Fluentd
--------------

`Fluentd <http://www.fluentd.org/>`_ là một bộ thu thập log phổ biến. Bạn có thể
cấu hình Logback để gửi log (từ nhiều nơi) đến một Fluentd server.

Đầu tiên, thêm thư viện `logback-more-appenders <https://github.com/sndyuk/logback-more-appenders>`_
vào trong project:

::

  libraryDependencies += "org.fluentd" % "fluent-logger" % "0.2.11"

  resolvers += "Logback more appenders" at "http://sndyuk.github.com/maven"

  libraryDependencies += "com.sndyuk" % "logback-more-appenders" % "1.1.0"

Sau đó trong tập tin ``config/logback.xml``:

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
