Async response
==============

Danh sách các method responding thông thường:

* ``respondView``: respond tệp view, có hoặc không có layout.
* ``respondInlineView``: respond template đã được nhúng(không tách rời các tệp template), có  
  hoặc không có layout.
* ``respondText("hello")``: respond một string, không có layout
* ``respondHtml("<html>...</html>")``: như trên, với content type đặt là "text/html"
* ``respondJson(List(1, 2, 3))``: convert Scala object thành JSON object sau đó respond
* ``respondJs("myFunction([1, 2, 3])")``
* ``respondJsonP(List(1, 2, 3), "myFunction")``: kết hợp cả 2 method ở trên
* ``respondJsonText("[1, 2, 3]")``
* ``respondJsonPText("[1, 2, 3]", "myFunction")``
* ``respondBinary``: respond một mảng byte
* ``respondFile``: send một tệp trực tiếp từ đĩa với tốc độ cao, sử dụng
  `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_
  (aka send-file)
* ``respondEventSource("data", "event")``

Xitrum không tự động gửi bất kỳ response nào.
Bạn phải gọi method ``respondXXX`` ở trên để gửi response.
Nếu bạn không gọi ``respondXXX``, Xitrum sẽ giữ kết nối HTTP, và bạn có thể
gọi ``respondXXX`` sau.

Để kiểm tra kết nối còn mở hay không, gọi ``channel.isOpen``.
Bạn cũng có thể sử dụng ``addConnectionClosedListener``:

::

  addConnectionClosedListener {
    // The connection has been closed
    // Unsubscribe from events, release resources etc.
  }

Vì tính năng async response không được gửi ngay lập tức.
``respondXXX`` trả về
`ChannelFuture <http://netty.io/4.0/api/io/netty/channel/ChannelFuture.html>`_.
Bạn có thể sử dụng nó để thực hiện action khi response đã thực sự được gửi đi.

Ví dụ, bạn muốn đóng kết nối sau khi response đã được gửi đi:

::

  import io.netty.channel.{ChannelFuture, ChannelFutureListener}

  val future = respondText("Hello")
  future.addListener(new ChannelFutureListener {
    def operationComplete(future: ChannelFuture) {
      future.getChannel.close()
    }
  })

hoặc ngắn hơn:

::

  respondText("Hello").addListener(ChannelFutureListener.CLOSE)

WebSocket
---------

::

  import scala.runtime.ScalaRunTime
  import xitrum.annotation.WEBSOCKET
  import xitrum.{WebSocketAction, WebSocketBinary, WebSocketText, WebSocketPing, WebSocketPong}

  @WEBSOCKET("echo")
  class EchoWebSocketActor extends WebSocketAction {
    def execute() {
      // Here you can extract session data, request headers etc.
      // but do not use respondText, respondView etc.
      // To respond, use respondWebSocketXXX like below.

      log.debug("onOpen")

      context.become {
        case WebSocketText(text) =>
          log.info("onTextMessage: " + text)
          respondWebSocketText(text.toUpperCase)

        case WebSocketBinary(bytes) =>
          log.info("onBinaryMessage: " + ScalaRunTime.stringOf(bytes))
          respondWebSocketBinary(bytes)

        case WebSocketPing =>
          log.debug("onPing")

        case WebSocketPong =>
          log.debug("onPong")
      }
    }

    override def postStop() {
      log.debug("onClose")
      super.postStop()
    }
  }

Một actor sẽ được tạo khi có một request. Actor sẽ được dừng lại khi một trong các điều kiện sau
xảy ra:

* Kết nối bị đóng.
* WebSocket close frame được nhận hoặc gửi đi

Sử dụng các method sau để gửi WebSocket frames:

* ``respondWebSocketText``
* ``respondWebSocketBinary``
* ``respondWebSocketPing``
* ``respondWebSocketClose``

Không có respondWebSocketPong, vì Xitrum sẽ tự động gửi pong frame
khi nó nhận được ping frame.

Để lấy URL cho WebSocket action ở trên:

::

  // Probably you want to use this in Scalate view etc.
  val url = webSocketAbsUrl[EchoWebSocketActor]

SockJS
------

`SockJS <https://github.com/sockjs/sockjs-client>`_ là một thư viện trình duyệt
JavaScript cung cấp một WebSocket-like object, dành cho các trình duyệt không hỗ
trợ WebSocket. Đầu tiên SockJS thử sử dụng WebSocket. Nếu không thành công, nó có thể sử dụng một số cách nhưng vẫn đưa về sử dụng WebSocket-like object.

Nếu bạn muốn làm việc với WebSocket API trên mọi trình duyệt, bạn nên sử dụng 
SockJS và tránh sử dụng trực tiếp WebSocket directly.

::

  <script>
    var sock = new SockJS('http://mydomain.com/path_prefix');
    sock.onopen = function() {
      console.log('open');
    };
    sock.onmessage = function(e) {
      console.log('message', e.data);
    };
    sock.onclose = function() {
      console.log('close');
    };
  </script>

Xitrum bao gồm các tệp JavaScript của SockJS.
Trong view template, chỉ cần viết như sau:

::

  ...
  html
    head
      != jsDefaults
  ...

SockJS đòi hỏi một `server counterpart <https://github.com/sockjs/sockjs-protocol>`_.
Xitrum sẽ tự động cung cấp.

::

  import xitrum.{Action, SockJsAction, SockJsText}
  import xitrum.annotation.SOCKJS

  @SOCKJS("echo")
  class EchoSockJsActor extends SockJsAction {
    def execute() {
      // To respond, use respondSockJsXXX like below

      log.info("onOpen")

      context.become {
        case SockJsText(text) =>
          log.info("onMessage: " + text)
          respondSockJsText(text)
      }
    }

    override def postStop() {
      log.info("onClose")
      super.postStop()
    }
  }

Một actor sẽ được tạo khi có một SockJS session mới. Nó sẽ dừng lại khi SockJS session này
đóng lại.

Sử dụng các method sau để gửi các send SockJS frames:

* ``respondSockJsText``
* ``respondSockJsClose``

Xem `Various issues and design considerations <https://github.com/sockjs/sockjs-node#various-issues-and-design-considerations>`_:

::

  Về cơ bản, cookie không phù hợp với mô hình SockJS. Nếu bạn muốn authorize cho một
  session, cũng cấp một token đặc biệt trên một page, gửi chúng như những thứ đầu tiên
  qua kết nối SockJS và validate nó ở server. Về cơ bản thì đây là cách thức hoạt động của  
  cookie

Để cấu hình SockJS clustering, xem :doc:`Clustering với Akka </cluster>`.

Chunked response
----------------

Để gửi `chunked response <http://en.wikipedia.org/wiki/Chunked_transfer_encoding>`_:

1. Gọi ``setChunked``
2. Gọi ``respondXXX`` bao nhiêu lần bạn muốn
3. Cuối cùng, gọi ``respondLastChunk``

Chunked response có nhiều use cases. Ví dụ, khi bạn cần generate một tệp CSV lớn hơn bộ nhớ, bạn có thể generate chunk by chunk và gửi chúng khi bạn generate:

::

  // "Cache-Control" header will be automatically set to:
  // "no-store, no-cache, must-revalidate, max-age=0"
  //
  // Note that "Pragma: no-cache" is linked to requests, not responses:
  // http://palizine.plynt.com/issues/2008Jul/cache-control-attributes/
  setChunked()

  val generator = new MyCsvGenerator

  generator.onFirstLine { line =>
    if (channel.isOpen) respondText(header, "text/csv")
  }

  generator.onNextLine { line =>
    if (channel.isOpen) respondText(line)
  }

  generator.onLastLine { line =>
    if (channel.isOpen) {
      respondText(line)
      respondLastChunk()
    }
  }

  generator.generate()

Ghi nhớ:

* Header được gửi ở lần gọi ``respondXXX`` đầu tiên.
* Bạn có thể gửi các optional trailing header tại ``respondLastChunk``
* :doc:`Page và action cache </cache>` không thế sử dụng với chunked response.

Với việc sử dụng chunked response cùng với ``ActorAction``, bạn có thể dễ dàng implement
`Facebook BigPipe <http://www.cubrid.org/blog/dev-platform/faster-web-page-loading-with-facebook-bigpipe/>`_.

Forever iframe
~~~~~~~~~~~~~~

Chunked response `có thể được sử dụng <http://www.shanison.com/2010/05/10/stop-the-browser-%E2%80%9Cthrobber-of-doom%E2%80%9D-while-loading-comet-forever-iframe/>`_
cho `Comet <http://en.wikipedia.org/wiki/Comet_%28programming%29>`_.

Page nhúng iframe:

::

  ...
  <script>
    var functionForForeverIframeSnippetsToCall = function() {...}
  </script>
  ...
  <iframe width="1" height="1" src="path/to/forever/iframe"></iframe>
  ...

Action respond ``<script>`` snippets mãi mãi:

::

  // Prepare forever iframe

  setChunked()

  // Need something like "123" for Firefox to work
  respondText("<html><body>123", "text/html")

  // Most clients (even curl!) do not execute <script> snippets right away,
  // we need to send about 2KB dummy data to bypass this problem
  for (i <- 1 to 100) respondText("<script></script>\n")

Sau đo, bất cứ khi nào bạn muốn truyền dữ liệu đến trình duyệt, chỉ cần gửi một snippet:

::

  if (channel.isOpen)
    respondText("<script>parent.functionForForeverIframeSnippetsToCall()</script>\n")
  else
    // The connection has been closed, unsubscribe from events etc.
    // You can also use ``addConnectionClosedListener``.

Event Source
~~~~~~~~~~~~

Xem http://dev.w3.org/html5/eventsource/

Event Source response là một loại chunked response đặc biệt.
Dữ liệu phải là kiểu UTF-8.

Để respond event source, gọi ``respondEventSource``.

::

  respondEventSource("data1", "event1")  // Event name is "event1"
  respondEventSource("data2")            // Event name is set to "message" by default