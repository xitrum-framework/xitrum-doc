Dependencies
============

Thư viện Dependency
-------------------

Xitrum bao gồm một vài thư viện. Trong Xiturm project, bạn có thẻ sử dụng chúng
một cách trực tiếp.

.. image:: ../img/deps.png

Các dependency chính:

* `Scala <http://www.scala-lang.org/>`_:
  Xitrum được viết bằng ngôn ngữ Scala.
* `Netty <https://netty.io/>`_:
  Với async HTTP(S) server. Nhiều tính năng trong Xitrum dựa trên Netty như 
  WebSocket và cung cấp tệp bằng zero copy.
* `Akka <http://akka.io/>`_:
  Với SockJS. Akka phụ thuộc vào `Typesafe Config <https://github.com/typesafehub/config>`_,
  Typesafe Config lại được sử dụng trong Xitrum.

Các dependencies khác:

* `Commons Lang <http://commons.apache.org/lang/>`_:
  Để escaping dữ liệu JSON.
* `Glokka <https://github.com/xitrum-framework/glokka>`_:
  Để clustering SockJS actors.
* `JSON4S <https://github.com/json4s/json4s>`_:
  Để phân tích và tạo dữ liệu JSON. JSON4S phụ thuộc 
  `Paranamer <http://paranamer.codehaus.org/>`_.
* `Rhino <https://developer.mozilla.org/en-US/docs/Rhino>`_:
  Để Scalate cho việc biên dịch CoffeeScript thành JavaScript.
* `Sclasner <https://github.com/xitrum-framework/sclasner>`_:
  For scanning HTTP routes in action classes in .class and .jar files.
* `Scaposer <https://github.com/xitrum-framework/scaposer>`_:
  For i18n.
* `Twitter Chill <https://github.com/twitter/chill>`_:
  Để serializing và deserializing cookie và sessions.
  Chill dựa trên `Kryo <http://code.google.com/p/kryo/>`_.
* `SLF4S <http://slf4s.org/>`_, `Logback <http://logback.qos.ch/>`_:
  Để logging.

`Skeleton project mới của Xitrum<https://github.com/xitrum-framework/xitrum-new>`_'
bao gồm các công cụ sau:

* `scala-xgettext <https://github.com/xitrum-framework/scala-xgettext>`_:
  Để :doc:`trích chuỗi i18n </i18n>` từ tệp .scala files khi biên dịch chúng.
* `xitrum-package <https://github.com/xitrum-framework/xitrum-package>`_:
  Để :doc:`đóng gói project </deploy>`, sẵn sàng cho việc deploy trên production 
  server.
* `Scalive <https://github.com/xitrum-framework/scalive>`_:
  Để két nối Scala console đến một tiến trình JVM đang chạy phục vụ gỡ lỗi trực tiếp.

Các project liên quan
---------------------

Demos:

* `xitrum-new <https://github.com/xitrum-framework/xitrum-new>`_:
  Xitrum new project skeleton.
* `xitrum-demos <https://github.com/xitrum-framework/xitrum-demos>`_:
  Bản demo các tính năng của Xitrum.
* `xitrum-placeholder <https://github.com/xitrum-framework/xitrum-placeholder>`_:
  Bản demo API lấy hình ảnh.
* `comy <https://github.com/xitrum-framework/comy>`_:
  Bản demo service rút ngon URL.
* `xitrum-multimodule-demo <https://github.com/xitrum-framework/xitrum-multimodule-demo>`_:
  Ví dụ về tạo project multimodule `SBT <http://www.scala-sbt.org/>`_.

Plugins:

* `xitrum-scalate <https://github.com/xitrum-framework/xitrum-scalate>`_:
  Đây là template engine mặc định của Xitrum, preconfigured trong
  `Xitrum new project skeleton <https://github.com/xitrum-framework/xitrum-new>`_.
  Bạn có thể thay nó bằng các template engine khác, hoặc loại bỏ hoàng toàn nó
  nếu project của bạn không cần bất kì template engine nào. Nó phụ thuộc vào
  `Scalate <http://scalate.fusesource.org/>`_ và
  `Scalamd <https://github.com/chirino/scalamd>`_.
* `xitrum-hazelcast <https://github.com/xitrum-framework/xitrum-hazelcast>`_:
  Để clustering cache và session tại server.
* `xitrum-ko <https://github.com/xitrum-framework/xitrum-ko>`_:
  Cung cấp một số helper cho `Knockoutjs <http://knockoutjs.com/>`_.

Các project khác:

* `xitrum-doc <https://github.com/xitrum-framework/xitrum-doc>`_:
  mã nguồn của `Xitrum Guide <http://xitrum-framework.github.io/guide.html>`_.
* `xitrum-hp <https://github.com/xitrum-framework/xitrum-framework.github.io>`_:
  mã nguồn của `Xitrum Homepage <http://xitrum-framework.github.io/>`_.