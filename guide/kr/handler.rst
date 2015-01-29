Netty 핸들러
===========

이번 챕터는 숙련자용으로, Xitrum을 보통으로 사용하시는분은 읽지 않아도 됩니다
이해를 위해서는 `Netty <http://netty.io/>`_ 를 반드시 숙지해야 합니다.

`Rack <http://en.wikipedia.org/wiki/Rack_(Web_server_interface)>`_ 、
`WSGI <http://en.wikipedia.org/wiki/Web_Server_Gateway_Interface>`_ 、
`PSGI <http://en.wikipedia.org/wiki/PSGI>`_ 는 미들웨어 아키텍처가 있습니다.
Xitrum은 `Netty <http://netty.io/>`_ 를 기본으로 하고 같은 핸들러를 사용합니다
핸들러를 생성하여 추가할 수 있고 채널의 파이프라인을 수정하여, 케이스별 서버의 성능을 극대화 할 수 있습니다.

이 장의 설명:

* Netty 핸들러 구조
* Xitrum이 제공하는 핸들러와 기본순서
* 핸들러를 생성하고 수정하는 방법

Netty 핸들러 구조
-------------------

각각의 커넥션은, 채널 파이프라인이 있고 IO 데이터를 조작합니다
채널 파이프 라인은 여러개의 핸들러로 구성되어 있고, 두가지의 핸들러 종류가 있습니다:

* 인바운드(Inbound): 요청방향 클라이언트 -> 서버
* 아웃바운(Inbound): 응답방향 서버 -> 클라이언트

`ChannelPipeline <http://netty.io/4.0/api/io/netty/channel/ChannelPipeline.html>`_
은 여기에서 더 자세한 정보를 얻을 수 있습니다.

::

                                                 I/O Request
                                            via Channel or
                                        ChannelHandlerContext
                                                      |
  +---------------------------------------------------+---------------+
  |                           ChannelPipeline         |               |
  |                                                  \|/              |
  |    +---------------------+            +-----------+----------+    |
  |    | Inbound Handler  N  |            | Outbound Handler  1  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  |               |                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler N-1 |            | Outbound Handler  2  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  .               |
  |               .                                   .               |
  | ChannelHandlerContext.fireIN_EVT() ChannelHandlerContext.OUT_EVT()|
  |        [ method call]                       [method call]         |
  |               .                                   .               |
  |               .                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler  2  |            | Outbound Handler M-1 |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  |               |                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler  1  |            | Outbound Handler  M  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  +---------------+-----------------------------------+---------------+
                  |                                  \|/
  +---------------+-----------------------------------+---------------+
  |               |                                   |               |
  |       [ Socket.read() ]                    [ Socket.write() ]     |
  |                                                                   |
  |  Netty Internal I/O Threads (Transport Implementation)            |
  +-------------------------------------------------------------------+

핸들러의 수정
------------------

Xitrum 서버가 구동될때
`ChannelInitializer <http://netty.io/4.0/api/io/netty/channel/ChannelInitializer.html>`_
를 설정할 수 있습니다ㄷ:

::

  import xitrum.Server

  object Boot {
    def main(args: Array[String]) {
      Server.start(myChannelInitializer)
    }
  }

HTTPS서버의 경우, Xitrum은 자동으로 SSL 핸들러를 파이프라인 앞에 준비합니다.
Xitrum 핸들러를 파이프라인에서 재사용이 가능합니다.

Xitrum 핸들러
------------------------

`xitrum.handler.DefaultHttpChannelInitializer <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/handler/ChannelInitializer.scala>`_
를 참고하세요.

공유가능한 핸들러（다중연결에서 공유된 같은 인스턴스들）
``DefaultHttpChannelInitializer`` 개체위에 존재하며 수정된 파이프 라인을 통하여 사용하기 원하는 어플리케이션에 쉽게 사용이 가능합니다.
이 어플리케이션들은 기본 핸들러의 집합입니다

예를들어, 어플리케이션이 자신의 디스패쳐를 사용하고(Xitrum의 라우팅/디스패쳐가 아닌) Xitrum의 빠른 정적파일만 사용한다면, 
다음의 핸들러만 사용하면 됩니다.

인바운드(Inbound):

* ``HttpRequestDecoder``
* ``PublicFileServer``
* 자신의 dispatcher

아웃바운드(Outbound):

* ``HttpResponseEncoder``
* ``ChunkedWriteHandler``
* ``XSendFile``
