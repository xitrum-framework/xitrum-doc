Hướng dẫn
========

Chương này giới thiệu ngắn gọn cách tạo và chạy một project Xitrum.
**Việc tạo project được thực hiện với giả định bạn sử dụng Linux và đã cài Java 8.**

Tạo một project Xitrum mới
---------------------------------

Để tạo mới một project Xitrum bạn chỉ cần tải về tập tin
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_:

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Hoặc:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Khởi động project Xitrum
-------------------

Cách chuẩn nhất để build một project Scala là sử dụng
`SBT <https://github.com/harrah/xsbt/wiki/Setup>`_. Các project mới được tạo đã có sẵn SBT 0.13 trong thư mục ``sbt``. Nếu bạn muốn tự cài đặt SBT, bạn có thể xem `hướng dẫn cài đặt <https://github.com/harrah/xsbt/wiki/Setup>`_.

Sử dụng terminal, chuyển đến thư mục của project mới tạo và chạy lệnh ``sbt/sbt fgRun``:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt fgRun

Câu lệnh này sẽ download tất cả :doc:`thư viện liên quan </deps>`, biên dịch toàn bộ project,
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
sách các định tuyến (routers), điều này rất thuận tiện với bạn để viết tài liệu về RESTful APIs của ứng dụng web cho bên thứ 3.

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

Bạn cũng có thể sử dụng `IntelliJ <http://www.jetbrains.com/idea/>`_ như Eclipse để viết code.

IntelliJ có Scala plugin rất tốt, chỉ cần mở project SBT là xong, không cần tạo trước
project file như trường hợp Eclipse ở trên.

Nạp lại tự động (Autoreload)
----------------------------

Bạn có thể thiết lập nạp lại tự động các tập tin .class (hot swap) mà không cần phải khởi động lại chương trình. Tuy nhiên, để tránh gặp phải các vấn đề về hiệu suất cũng như tính ổn định của chương
trình, bạn chỉ nên thiết lập nạp lại tự động các tập tin .class trong quá trình phát triển (development mode).

Chạy project với IDEs
~~~~~~~~~~~~~~~~~~~~~

Trong quá trình phát triển, khi chạy project với các IDE cấp cao như Eclipse hoặc IntelliJ,
code sẽ được tự động nạp lại bởi thiết lập mặc định của IDE.

Chạy project với SBT
~~~~~~~~~~~~~~~~~~~~

Khi bạn chạy project với SBT, bạn cần phải mở 2 cửa sổ dòng lệnh:

* Một để chạy ``sbt/sbt fgRun``. Câu lệnh này để chạy chương trình và tải lại các tập .class khi chúng được thay đổi.
* Một để chạy ``sbt/sbt ~compile``. Mỗi khi bạn thay đổi các file mã nguồn, câu lệnh này sẽ biên dịch mã nguồn thành các file .class.

Thư mục sbt có chứa một tập tin là `agent7.jar <https://github.com/xitrum-framework/agent7>`_.
Tập tin này chịu trách nhiệm tải lại các tập tin .class trong thư mục hiện hành (và các thư mục con).
Nếu nhìn vào đoạn mã ``sbt/sbt``, bạn sẽ thấy tùy chọn ``-javaagent:agent7.jar``.

DCEVM
~~~~~

Thông thường JVM chỉ cho phép thay đổi nội dung của một method. Bạn có thể sử dụng
`DCEVM <https://github.com/dcevm/dcevm>`_, một biến thể mã nguồn mở của máy ảo Java HotSpot
VM cho phép bạn định nghĩa lại không hạn chế các class đã được tải.

Bạn có thể cài DCEVM bằng 2 cách:

* Sử dụng bản `Patch <https://github.com/dcevm/dcevm/releases>`_ với bản Java đã được cài đặt sẵn trên máy của bạn.

* Cài đặt một bản `prebuilt <http://dcevm.nentjes.com/>`_ (cách dễ dàng hơn).

Nếu bạn chọn cách sử dụng Patch:

* Bạn có thể kích hoạt DCEVM chạy vĩnh viễn.
* Hoặc sử dụng JVM thay thế ("alternative" JVM). Trong trường hợp này, để chạy DCEVM bạn cần chạy câu lệnh ``java`` với tùy chọn ``-XXaltjvm=dcevm``.
  Ví dụ, bạn cần thêm tùy chọn ``-XXaltjvm=dcevm`` vào câu lệnh ``sbt/sbt``.

Nếu bạn sử dụng IDE như Eclipse hoặc IntelliJ, bạn cần thiết lập IDE để sử dụng DCEVM (mà không phải JVM mặc định) để chạy project.

Nếu bạn sử dụng SBT, bạn cần cài đặt biến môi trường ``PATH`` với đường dẫn câu lệnh ``java`` từ DCEVM (không phải bản JVM mặc định). Bạn vẫn có thể cần đến ``javaagent`` trên đây, bởi vì mặc dù DCEVM hỗ trợ các tiện ích khi sửa đổi class, bản thân nó không thể tự tải lại các class.

Để có thêm thông tin chi tiết bạn có thể tham khảo `DCEVM - A JRebel free alternative <http://javainformed.blogspot.jp/2014/01/jrebel-free-alternative.html>`_.

Danh sách các tập tin bị bỏ qua
------------------------------

Thông thường, những những tập tin này nên được `bỏ qua <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_
(không commit lên SVN hoặc Git repository):

::

  .*
  log
  project/project
  project/target
  target
  tmp
