Tutorial
========

Phần này trình bày một ngắn gọn cách tạo và chạy một project Xitrum.
**Việc tạo project được thực hiện với giả định bạn sử dụng Linux và đã cài Java.**

Tạo một project Xitrum mới
---------------------------------

Để tạo một project Xitrum mới bạn chỉ cần tải về tập tin  
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_:

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Hoặc:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Chạy project Xitrum
-------------------

Cách chuẩn nhất để build một project Scala là sử dụng
`SBT <https://github.com/harrah/xsbt/wiki/Setup>`_. Các project mới được tạo đã có sẵn SBT 0.13 trong thư mục
``sbt``. Nếu bạn muốn tự cài ``SBT``, bạn có thể xem hướng dẫn tại `đây <https://github.com/harrah/xsbt/wiki/Setup>`_.

Sử dụng terminal, chuyển đến thư mục của project mới tạo và chạy lệnh ``sbt/sbt run``:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run

Câu lệnh này sẽ download tất cả :doc:`dependencies </deps>`, biên dịch toàn bộ project,
và khởi động web server qua class ``quickstart.Boot``. Trong cửa sổ dòng lệnh Terminal,
bạn sẽ thấy tất cả các định tuyến:

::

  [INFO] Load routes.cache or recollect routes...
  [INFO] Normal routes:
  GET  /  quickstart.action.SiteIndex
  [INFO] SockJS routes:
  xitrum/metrics/channel  xitrum.metrics.XitrumMetricsChannel  websocket: true, cookie_needed: false
  [INFO] Error routes:
  404  quickstart.action.NotFoundError
  500  quickstart.action.ServerError
  [INFO] Xitrum routes:
  GET        /webjars/swagger-ui/2.0.17/index                            xitrum.routing.SwaggerUiVersioned
  GET        /xitrum/xitrum.js                                           xitrum.js
  GET        /xitrum/metrics/channel                                     xitrum.sockjs.Greeting
  GET        /xitrum/metrics/channel/:serverId/:sessionId/eventsource    xitrum.sockjs.EventSourceReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/htmlfile       xitrum.sockjs.HtmlFileReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/jsonp          xitrum.sockjs.JsonPPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/jsonp_send     xitrum.sockjs.JsonPPollingSend
  WEBSOCKET  /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocket
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr            xitrum.sockjs.XhrPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_send       xitrum.sockjs.XhrSend
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_streaming  xitrum.sockjs.XhrStreamingReceive
  GET        /xitrum/metrics/channel/info                                xitrum.sockjs.InfoGET
  WEBSOCKET  /xitrum/metrics/channel/websocket                           xitrum.sockjs.RawWebSocket
  GET        /xitrum/metrics/viewer                                      xitrum.metrics.XitrumMetricsViewer
  GET        /xitrum/metrics/channel/:iframe                             xitrum.sockjs.Iframe
  GET        /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketGET
  POST       /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketPOST
  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

Khi khởi động, tất cả các định tuyến (routers) sẽ được kiểm tra và lưu vào log. Bạn đã có luôn danh
sách các định tuyến (routers), điều này rất thuận tiện với bạn để viết tài liệu về RESTful APIs của ứng dụng web
cho bên thứ 3.

Truy cập đến đường dẫn http://localhost:8000/ hoặc https://localhost:4430/ bằng trình duyệt web. Trong cửa sổ
dòng lệnh bạn sẽ thấy thông tin của các yêu cầu (request):

::

  [INFO] GET quickstart.action.SiteIndex, 1 [ms]

Import một project Xitrum vào Eclipse
-------------------------------------

Bạn có thể `sử dụng Eclipse để viết code Scala <http://scala-ide.org/>`_.

Sử dụng cửa sổ dòng lệnh và từ thư mục của project Xitrum chạy lệnh sau:

::

  sbt/sbt eclipse

file ``.project`` cho Eclipse sẽ được tạo với thông tin trong file ``build.sbt``.
Sau đó chạy Eclipse và import project.

Import một project Xitrum vào IntelliJ
--------------------------------------

Bạn cũng có thể sử dụng `IntelliJ <http://www.jetbrains.com/idea/>`_ như Eclipse để viết code, 
IntelliJ cũng hỗ trợ rất tốt cho Scala.

Để tạo một project chạy trên IDEA, cũng từ thư mục của project Xitrum, sử dụng lệnh:

::

  sbt/sbt gen-idea

Autoreload
----------

Bạn có thể autoreload các tập tin .class (hot swap) mà không cần phải khởi động lại chương 
trình. Tuy nhiên, để tránh gặp phải các vấn đề về hiệu suất cũng như tính ổn định của chương
trình, bạn chỉ nên autoreload các tập tin .class trong quá trình phát triển (development mode).

Chạy project với IDEs
~~~~~~~~~~~~~~~~~~~~~

Trong quá trình phát triển, khi bạn chạy project với các IDE như Eclipse hoặc IntelliJ,
mặc định các IDE sẽ tự động tải lại mã nguồn.

Chạy project với SBT
~~~~~~~~~~~~~~~~~~~~

Khi bạn chạy project với SBT, bạn cần phải mở 2 cửa sổ dòng lênh:

* Một để chạy ``sbt/sbt run``. Câu lệnh này để chạy trương trình và tải lại các tập .class khi chúng
  được thay đổi.
* Một để chạy ``sbt/sbt ~compile``. Câu lệnh này để biên dịch mã nguồn thành các tập .class.

Trong thư mục ``sbt``, có một tập tin `agent7.jar <https://github.com/xitrum-framework/agent7>`_.
Tập tin này chịu trách nhiệm tải lại các tập .class trong thư mục và các thư mục con.
Nếu bạn thấy đoạn script ``sbt/sbt``, bạn sẽ thấy tùy chọn như ``-javaagent:agent7.jar``.

DCEVM
~~~~~

Thông thường JVM chỉ cho phép thay đổi nội dung của một method. Bạn có thể sử dụng
`DCEVM <https://github.com/dcevm/dcevm>`_, một biến thể mã nguồn mở của máy ảo Java HotSpot
VM cho phép bạn thoải mái định nghĩa lại các class đã được tải.

Bạn có thể cài DCEVM bằng 2 cách:

* Sử dụng bản `Patch <https://github.com/dcevm/dcevm/releases>`_ với bản Java đã được cài đặt sẵn trên máy của bạn. 

* Cài đặt một bản `prebuilt <http://dcevm.nentjes.com/>`_ (cách dễ dàng hơn).

Nếu bạn chọn cách sử dụng Patch:

* Bạn có thể chạy DCEVM chạy mãi mãi.
* Hoặc sử dụng như một JVM khác. Trong trường hợp này, để chạy DCEVM bạn cần chạy câu lệnh ``java`` với tùy chọn ``-XXaltjvm=dcevm``. 
  Ví dụ, bạn cần thêm tùy chọn ``-XXaltjvm=dcevm`` vào câu lệnh ``sbt/sbt``.

Nếu bạn sử dụng IDE như Eclipse hoặc IntelliJ, bạn cần cài đặt IDE để sử dụng DCEVM (không phải JVM mặc định) để chạy project.

Nếu bạn sử dụng SBT, bạn cần cài đặt biến môi trường ``PATH`` với đường dẫn câu lệnh ``java`` từ DCEVM (không phải bản JVM mặc định). Bạn vẫn có thể cần đến  ``javaagent`` trên đây, bởi vì mặc dù DCEVM hỗ trợ các tiện ích khi sửa đổi các class, nó không thể tự tải lại các class.

Để có thêm thông tin chi tiết bạn có thể tham khảo `DCEVM - A JRebel free alternative <http://javainformed.blogspot.jp/2014/01/jrebel-free-alternative.html>`_.

Danh sách các tập tin bị bỏ qua
------------------------------

Thông thường, những những tập tin này nên được `bỏ qua <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_
(không commited đến các repository SVN or Git):

::

  .*
  log
  project/project
  project/target
  target
  tmp
