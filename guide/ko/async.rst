비동기 응답
================

Action에서 클라이언트로 응답을 반환하려면 다음 방법을 사용합니다

* ``respondView``: 레이아웃 파일을 사용 또는 사용하지 않고、View의 템플릿 파일을 보냅니다
* ``respondInlineView``: 레이아웃 파일을 사용 또는 사용하지 않고、인라인 작성된 템플릿을 보냅니다
* ``respondText("hello")``: 레이아웃 파일을 사용하지 않고 텍스트를 보냅니다
* ``respondHtml("<html>...</html>")``: 위와 같이 contentType을 "text/html"로 보냅니다
* ``respondJson(List(1, 2, 3))``: Scala 객체를 JSON 으로 변환하여、contentType을 "application/json"으로 보냅니다
* ``respondJs("myFunction([1, 2, 3])")`` contentType을 "application/javascript"으로 보냅니다
* ``respondJsonP(List(1, 2, 3), "myFunction")``: 위 두가지 조합을 JSONP 으로 보냅니다
* ``respondJsonText("[1, 2, 3]")``: contentType 을 "application/javascript" 으로 보냅니다
* ``respondJsonPText("[1, 2, 3]", "myFunction")``: `respondJs` 、 `respondJsonText` 의 두가지 조합을 JSONP로 보냅니다
* ``respondBinary``: 바이트 배열로 보냅니다
* ``respondFile``: 디스크에서 파일을 직접 보냅니다. `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_ 를 사용하기 때문에 빠릅니다.
* ``respondEventSource("data", "event")``: 청크 응답을 보냅니다

Xitrum 은 자동으로 어떤 특정한 응답을 하지 않습니다.스스로 응답을 ``respondXXX`` 형식으로 명시해야 합니다.
``respondXXX`` 을 호출하지 않을경우 Xitrum 은 HTTP 연결을 유지 하기때문에 , 나중에 ``respondXXX`` 형식의 호출문이 필요합니다.

연결이 open 상태로 되어 있는지 확인하려면 ``channel.isOpen`` 을 호출하면 됩니다.``addConnectionClosedListener``
를 사용해도 무방합니다.

::

  addConnectionClosedListener {
    // 연결이 해제되었습니다.
    // 이벤트로부터 자원을 해제합니다.
  }

비동기 이므로 응답을 바로 전송하지 않습니다.``respondXXX`` 의 반환값은
`ChannelFuture <http://netty.io/4.0/api/io/netty/channel/ChannelFuture.html>`_
를 사용합니다.이것을 통해 실제로 전송되는 콜백을 지정할 수 있습니다.

예를 들어, 응답의 전송후에 연결을 해제하려면:

::

  import io.netty.channel.{ChannelFuture, ChannelFutureListener}

  val future = respondText("Hello")
  future.addListener(new ChannelFutureListener {
    def operationComplete(future: ChannelFuture) {
      future.getChannel.close()
    }
  })

더 짧은 예:

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
      // 여기에서 세션데이터, 요청해더 등을 추출할 수 있지만
      // respondText 나 respondView를 사용하면 안됩니다.
      // 응답하려면 다음과 같이 respondWebSocketXXX를 사용하세요.

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

요청이 올때 위의 액터가 생성됩니다. 그리고 다음의 경우 중단됩니다:

* 연결이 끊긴경우
* WebSocket의 close 프레임이 수신되거나 전송되었을때

WebSocket 프레임을 전송하는 경우:

* ``respondWebSocketText``
* ``respondWebSocketBinary``
* ``respondWebSocketPing``
* ``respondWebSocketClose``

``respondWebSocketPong`` 은 없습니다.Xitrum이 ping 을 수신하게 되면 자동으로 pong 프레임을 전송하기 때문입니다.

위의 WebSocket 액션의 URL 을 얻으려면:

::

  // Scalate 템플릿 파일을 사용하기 원한다면
  val url = absWebSocketUrl[EchoWebSocketActor]

SockJS
------

`SockJS <https://github.com/sockjs/sockjs-client>`_ 은 WebSocket을 지원하지 않는 브라우저를 위한
 WebSocket 과 같은 API를 제공하는 JavaScript라이브러리 입니다. SockJS는 먼저 WebSocket를 시도해보고
 실패할경우 다른 방법들을 통해 WebSocket과 같은 라이브러리들을 사용하게 됩니다

 만약, 모든 브라우저에서 WebSocket API를 사용하고 싶다면, SockJS 을 사용하되 WebSocket을 직접 사용하지 마세요.

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

Xitrum 은 SockJS의 JavsScript 파일을 내포하고 있습니다.
뷰 템플릿에서 다음과 같이 사용하면 됩니다:

::

  ...
  html
    head
      != jsDefaults
  ...

SockJS는 `server counterpart <https://github.com/sockjs/sockjs-protocol>`_ 를 필요로 하지 않습니다.
Xitrum이 자동으로 제공합니다.

::

  import xitrum.{Action, SockJsAction, SockJsText}
  import xitrum.annotation.SOCKJS

  @SOCKJS("echo")
  class EchoSockJsActor extends SockJsAction {
    def execute() {
      // 응답을 위해, 아래에 respondSockJSXXX를 사용합니다

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

액터 새로운 SockJS 세션이 만들어질때 생겨나고 SockJS세션이 닫힐때 종료합니다.

SockJS 프레임으로 보내려면:

* ``respondSockJsText``
* ``respondSockJsClose``

`SockJs주의사항 <https://github.com/sockjs/sockjs-node#various-issues-and-design-considerations>`_:

::

  기본적으로 쿠키는 SockJS 모델과 맞지가 않습니다. 세션인증을 하려면 고유의 토큰을 SockJS를
  통해 서버측에서 검증을 해야 합니다. 이것이 본질적으로 쿠키의 작동원리 입니다

SockJS클러스터링을 수정하려면 :doc:`Akka 클러스터링 </cluster>`을 참고하세요.

Chunk응답
--------

`Chunk응답 <http://en.wikipedia.org/wiki/Chunked_transfer_encoding>`_ 을 보내려면:

1. ``setChunked`` 호출
2. ``respondXXX`` 호출（필요한 만큼）
3. 마지막으로 ``respondLastChunk`` 호출

Chunk응답은 많은 유스케이스를 가지고 있습니다. 예를들어, 메모리에 맞지 않는 매우큰 CSV파일을 생성할때
Chunk별로 생성해서 보낼수 있습니다.

::

  // "Cache-Control" 헤더가 자동으로 세팅됩니다:
  // 「no-store, no-cache, must-revalidate, max-age=0」
  //
  // 덧붙여서 "Pragma: no-cache" 는 응답이 아닌 요청에 링크됩니다:
  // http://palizine.plynt.com/issues/2008Jul/cache-control-attributes/
  setChunked()

  val generator = new MyCsvGenerator

  generator.onFirstLine { line =>
    val future = respondText(header, "text/csv")
    future.addListener(new ChannelFutureListener {
      def operationComplete(future: ChannelFuture) {
        if (future.isSuccess) generator.next()
      }
    }
  }

  generator.onNextLine { line =>
    val future = respondText(line)
    future.addListener(new ChannelFutureListener {
      def operationComplete(future: ChannelFuture) {
        if (future.isSuccess) generator.next()
      }
    })
  }

  generator.onLastLine { line =>
    val future = respondText(line)
    future.addListener(new ChannelFutureListener {
      def operationComplete(future: ChannelFuture) {
        if (future.isSuccess) respondLastChunk()
      }
    })
  }

  generator.generate()

주의:

* 헤더는 ``respondXXX`` 을 먼저 요청합니다.
* 마지막 헤더 옵션을 ``respondLastChunk`` 에 설정할 수 있습니다.
* :doc:`페이지와 액션캐쉬 </cache>` 는 chunk 응답으로 사용할 수 없습니다.

Chunk응답을  ``ActorAction`` 과 함께 사용하려면
`Facebook BigPipe <http://www.cubrid.org/blog/dev-platform/faster-web-page-loading-with-facebook-bigpipe/>`_
을 통해 쉽게 구현할수 있습니다.

무한iframe
~~~~~~~~~~~

청크 응답은 `Comet <http://en.wikipedia.org/wiki/Comet_%28programming%29>`_
 을 `사용할 수 있습니다 <http://www.shanison.com/2010/05/10/stop-the-browser-%E2%80%9Cthrobber-of-doom%E2%80%9D-while-loading-comet-forever-iframe/>`_

iframe을 포함한 페이지:

::

  ...
  <script>
    var functionForForeverIframeSnippetsToCall = function() {...}
  </script>
  ...
  <iframe width="1" height="1" src="path/to/forever/iframe"></iframe>
  ...

무한 ``<script>`` 생성하는 페이지:

::

  // 준비

  setChunked()

  // Firefox를 동작하기 위해 "123" 등을 사용
  respondText("<html><body>123", "text/html")

  // curl을 포함한 대부분의 클라이언트는 script를 미리보기로 바로 사용할 수 없음.
  // 2KB의 더미 데이터를 바로 보내볼 필요가 있음.
  for (i <- 1 to 100) respondText("<script></script>\n")

나중에 실제 데이터를 브라우저에 보내려면, 미리보기를 보내면 된다:

::

  if (channel.isOpen)
    respondText("<script>parent.functionForForeverIframeSnippetsToCall()</script>\n")
  else
    // 연결이 종료되고, 이벤트가 해제됨
    // ``addConnectionClosedListener`` 을 사용할수 있음.

Event Source
~~~~~~~~~~~~

참고: http://dev.w3.org/html5/eventsource/

Event Source는 특별한 경우 chunk응답을 보냄.
데이터는 UTF-8 이어야 함.

Event Source를 응답하려면 ``respondEventSource`` 호출（필요한 만큼）:

::

  respondEventSource("data1", "event1")  // event1의 이벤트 이름
  respondEventSource("data2")            // message라는 이벤트 이름으로 기본설정됨
