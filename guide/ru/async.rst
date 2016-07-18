Асинхронная обработка запросов
==============================

Основные методы для отправки ответа сервером:

* ``respondView``: при ответе использует шаблон ассоциированный с контроллером
* ``respondInlineView``: при ответе использует шаблон переданный как аргумент
* ``respondText("hello")``: ответ строкой "plain/text"
* ``respondHtml("<html>...</html>")``: ответ строкой "text/html"
* ``respondJson(List(1, 2, 3))``: преобразовать Scala объект в JSON и ответить
* ``respondJs("myFunction([1, 2, 3])")``
* ``respondJsonP(List(1, 2, 3), "myFunction")``: совмещение предыдущих двух
* ``respondJsonText("[1, 2, 3]")``
* ``respondJsonPText("[1, 2, 3]", "myFunction")``
* ``respondBinary``: ответ массивом байт
* ``respondFile``: переслать файл с использованием техники `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_  (aka send-file)
* ``respondEventSource("data", "event")``

Xitrum автоматически не осуществляет отправку ответа клиенту. Вы должны явно вызвать один из методов ``respondXXX``
что бы отправить ответ клиенту. Если вы не вызовете метод``respondXXX``, Xitrum будет поддерживать HTTP соединение,
до тех пор пока не будет вызван метод ``respondXXX``.

Что бы убедиться что соединение открыто используйте метод ``channel.isOpen``.
Вы можете использовать добавить слушателя используя метод ``addConnectionClosedListener``:

::

  addConnectionClosedListener {
    // Соединение было закрыто
    // Необходимо освободить ресурсы
  }

Ввиду асинхронной природы, ответ сервера не посылается немедленно.
``respondXXX`` возвращает экземпляр `ChannelFuture <http://netty.io/4.0/api/io/netty/channel/ChannelFuture.html>`_.
Его можно использовать для выполнения действий в момент кода ответ будет действительно отправлен.

Например, если вы хотите закрыть подключение сразу после отправки запроса:

::

  import io.netty.channel.{ChannelFuture, ChannelFutureListener}

  val future = respondText("Hello")
  future.addListener(new ChannelFutureListener {
    def operationComplete(future: ChannelFuture) {
      future.getChannel.close()
    }
  })

Или проще:

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

Актор будет создан при открытии подключения. И остановлен когда:

* Соединение будет разорвано
* WebSocket закроет подключение

Используйте следующие методы для отправки WebSocket сообщений (frame):

* ``respondWebSocketText``
* ``respondWebSocketBinary``
* ``respondWebSocketPing``
* ``respondWebSocketClose``

Метод respondWebSocketPong не предусмотрен, потому что Xitrum автоматически отправляет "pong" сообщение в ответ на "ping".

Для получения ссылки на контроллер:

::

  val url = absWebSocketUrl[EchoWebSocketActor]

SockJS
------

`SockJS <https://github.com/sockjs/sockjs-client>`_ предоставляет JavaScript объект
эмитирующий поддержку WebSocket, для браузеров которые не поддерживают этот стандарт.
SockJS пытается использовать WebSocket если он доступен в браузере. В другом случае
будет создан эмитирующий объект.

Если вы хотите использовать WebSocket API во всех браузерах, то следует использовать
SockJS вместо WebSocket.

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

Xitrum включает файл SockJS по умолчанию.
В шаблоне следует написать:

::

  ...
  html
    head
      != jsDefaults
  ...

SockJS подразумевает наличие части реализации `на сервере <https://github.com/sockjs/sockjs-protocol>`_.
Xitrum автоматически ее реализует:

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

Актор будет создан при открытии новой SockJS сессии. И остановлен когда сессия будет закрыта.

Для отправки SockJS сообщений используйте методы:

* ``respondSockJsText``
* ``respondSockJsClose``

`Рекомендации по реализации <https://github.com/sockjs/sockjs-node#various-issues-and-design-considerations>`_:

::

  Обычно использование кук не подходит для SockJS. Если вам нужна авторизация внутри сессии, то
  для каждой страницы присвойте токен и используйте его в SockJS сессии, для валидации на серверной стороне.
  В сущности это повторение механизма куки для SockJS.

Подробнее о настройке кластера SockJS, смотрите раздел :doc:`Кластерезация с Akka </cluster>`.

Chunked ответ
-------------

Для отправки `chunked ответа <http://en.wikipedia.org/wiki/Chunked_transfer_encoding>`_:

1. Вызовите метод ``setChunked``
2. Отправляйте данные методами ``respondXXX``, столько раз сколько нужно
3. Последний ответ отправьте методом ``respondLastChunk``

Chunked ответы имеют множество применений. Например, когда нужно генерировать большой
документ который не помещается в памяти, вы можете генерировать этот документ частями
и отправлять их последовательно:

::

  // "Cache-Control" загаловок будет установлен в:
  // "no-store, no-cache, must-revalidate, max-age=0"
  //
  // Важно "Pragma: no-cache" привязывается к запросу, а не к ответу:
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

Замечания:

* Заголовки отправляются при первом вызове ``respondXXX``.
* Опционально, вы можете отправить дополнительные заголовки с вызовом метода ``respondLastChunk``
* :doc:`Кэш страницы и контроллера </cache>` не может быть использован совместно с chunked ответами.

Используя chunked ответ вместе с ``ActorAction``, легко реализовать
`Facebook BigPipe <http://www.cubrid.org/blog/dev-platform/faster-web-page-loading-with-facebook-bigpipe/>`_.

Бесконечный iframe
~~~~~~~~~~~~~~~~~~

Chunked ответ `может быть использован <http://www.shanison.com/2010/05/10/stop-the-browser-%E2%80%9Cthrobber-of-doom%E2%80%9D-while-loading-comet-forever-iframe/>`_
для реализации `Comet <http://en.wikipedia.org/wiki/Comet_%28programming%29>`_.

Страница которая включает iframe:

::

  ...
  <script>
    var functionForForeverIframeSnippetsToCall = function() {...}
  </script>
  ...
  <iframe width="1" height="1" src="path/to/forever/iframe"></iframe>
  ...

Контроллер который последовательно отправляет ``<script>``:

::

  // Подготовка к вечному iframe

  setChunked()

  // Необходимо отправить например "123" для некоторых браузеров
  respondText("<html><body>123", "text/html")

  // Большинство клиентов (даже curl!) не выполняют тело <script> немедленно,
  // необходимо отправить около 2KB данных что бы обойти эту проблему
  for (i <- 1 to 100) respondText("<script></script>\n")

Позднее, когда вам нужно отправить данные браузеру, просто используйте шаблон:

::

  if (channel.isOpen)
    respondText("<script>parent.functionForForeverIframeSnippetsToCall()</script>\n")
  else
    // Соединение было закрыто, необходимо освободить ресурсы
    // Вы можете использовать так же ``addConnectionClosedListener``.

Event Source
~~~~~~~~~~~~

Смотри http://dev.w3.org/html5/eventsource/

Event Source ответ, это специальный тип chunked ответа.
Данные должны быть в кодировке UTF-8.

Для ответа в формате event source, используйте метод ``respondEventSource`` столько раз сколько нужно.

::

  respondEventSource("data1", "event1")  // Имя события "event1"
  respondEventSource("data2")            // Имя события устанавливается в "message" по умолчанию
